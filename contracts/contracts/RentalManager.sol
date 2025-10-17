// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PropertyNFT.sol";

interface IAaveLendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}

contract RentalManager is Ownable {
    PropertyNFT public propertyNFT;
    address public stableCoin; // e.g., USDC address on Sepolia
    address public aaveLendingPool; // Aave contract address on Sepolia
    uint256 public constant SAVINGS_PERCENTAGE = 10; // 10% of rent to savings

    // Rental agreement struct
    struct RentalAgreement {
        uint256 propertyId;
        address renter;
        uint256 monthlyRent;
        uint256 deposit;
        uint256 startTime;
        uint256 duration; // in months
        bool active;
    }

    // Map property ID to rental agreement
    mapping(uint256 => RentalAgreement) public agreements;
    // Track payments for immutability
    mapping(uint256 => mapping(uint256 => uint256)) public paymentHistory; // propertyId => timestamp => amount

    constructor(address _propertyNFT, address _stableCoin, address _aaveLendingPool) Ownable(msg.sender) {
        propertyNFT = PropertyNFT(_propertyNFT);
        stableCoin = _stableCoin;
        aaveLendingPool = _aaveLendingPool;
    }

    // Create a rental agreement
    function createRental(
        uint256 propertyId,
        address renter,
        uint256 monthlyRent,
        uint256 deposit,
        uint256 duration
    ) public {
        require(propertyNFT.ownerOf(propertyId) == msg.sender, "Only property owner can create rental");
        require(!agreements[propertyId].active, "Property already rented");
        require(renter != address(0), "Invalid renter address");

        agreements[propertyId] = RentalAgreement({
            propertyId: propertyId,
            renter: renter,
            monthlyRent: monthlyRent,
            deposit: deposit,
            startTime: block.timestamp,
            duration: duration,
            active: true
        });

        // Transfer deposit to contract (escrow)
        require(IERC20(stableCoin).transferFrom(renter, address(this), deposit), "Deposit transfer failed");
        emit RentalCreated(propertyId, renter, monthlyRent, deposit, duration);
    }

    // Pay monthly rent
    function payRent(uint256 propertyId) public payable {
        RentalAgreement storage agreement = agreements[propertyId];
        require(agreement.active, "No active rental");
        require(msg.sender == agreement.renter, "Only renter can pay");
        require(block.timestamp < agreement.startTime + agreement.duration * 30 days, "Rental expired");

        uint256 rent = agreement.monthlyRent;
        uint256 savingsAmount = (rent * SAVINGS_PERCENTAGE) / 100;
        uint256 ownerAmount = rent - savingsAmount;

        // Transfer rent from renter
        require(IERC20(stableCoin).transferFrom(msg.sender, address(this), rent), "Rent transfer failed");

        // Send savings portion to Aave
        IERC20(stableCoin).approve(aaveLendingPool, savingsAmount);
        IAaveLendingPool(aaveLendingPool).deposit(stableCoin, savingsAmount, propertyNFT.ownerOf(propertyId), 0);

        // Send rest to property owner
        require(IERC20(stableCoin).transfer(propertyNFT.ownerOf(propertyId), ownerAmount), "Owner transfer failed");

        // Log payment for immutability
        paymentHistory[propertyId][block.timestamp] = rent;
        emit RentPaid(propertyId, msg.sender, rent);
    }

    // End rental and return deposit
    function endRental(uint256 propertyId) public {
        RentalAgreement storage agreement = agreements[propertyId];
        require(agreement.active, "No active rental");
        require(msg.sender == propertyNFT.ownerOf(propertyId) || msg.sender == agreement.renter, "Unauthorized");

        agreement.active = false;
        require(IERC20(stableCoin).transfer(agreement.renter, agreement.deposit), "Deposit refund failed");
        emit RentalEnded(propertyId);
    }

    // Events for tracking
    event RentalCreated(uint256 indexed propertyId, address indexed renter, uint256 monthlyRent, uint256 deposit, uint256 duration);
    event RentPaid(uint256 indexed propertyId, address indexed renter, uint256 amount);
    event RentalEnded(uint256 indexed propertyId);
}