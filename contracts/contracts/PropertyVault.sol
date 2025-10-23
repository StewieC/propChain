// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PropertyVault is Ownable, ReentrancyGuard {
    struct Property {
        address tenant;
        uint256 rentAmount;
        uint256 savingsPercentage;
        uint256 lastPaymentTime;
        bool active;
        uint256 totalSaved;
    }

    mapping(uint256 => Property) public properties;
    uint256 public nextPropertyId = 1;
    
    IERC20 public stablecoin;
    uint256 public constant MONTH_IN_SECONDS = 30 days;

    event PropertyCreated(uint256 indexed propertyId, address owner, address tenant, uint256 rent);
    event RentPaid(uint256 indexed propertyId, uint256 amount, uint256 saved);
    event SavingsWithdrawn(uint256 indexed propertyId, uint256 amount);

    constructor(address _stablecoin) Ownable(msg.sender) {
        stablecoin = IERC20(_stablecoin);
    }

    function createProperty(
        address _tenant,
        uint256 _rentAmount,
        uint256 _savingsPercentage
    ) external onlyOwner {
        require(_savingsPercentage <= 100, "Invalid savings %");
        require(_rentAmount > 0, "Rent must be > 0");
        
        uint256 propertyId = nextPropertyId++;
        properties[propertyId] = Property({
            tenant: _tenant,
            rentAmount: _rentAmount,
            savingsPercentage: _savingsPercentage,
            lastPaymentTime: block.timestamp,
            active: true,
            totalSaved: 0
        });

        emit PropertyCreated(propertyId, msg.sender, _tenant, _rentAmount);
    }

    function payRent(uint256 _propertyId) external nonReentrant {
        Property storage prop = properties[_propertyId];
        require(prop.active, "Property inactive");
        require(msg.sender == prop.tenant, "Not tenant");
        require(block.timestamp >= prop.lastPaymentTime + MONTH_IN_SECONDS, "Rent already paid");

        uint256 savingsAmount = (prop.rentAmount * prop.savingsPercentage) / 100;
        uint256 ownerAmount = prop.rentAmount - savingsAmount;

        require(stablecoin.transferFrom(msg.sender, address(this), prop.rentAmount), "Payment failed");
        require(stablecoin.transfer(owner(), ownerAmount), "Owner transfer failed");

        prop.totalSaved += savingsAmount;
        prop.lastPaymentTime = block.timestamp;

        emit RentPaid(_propertyId, prop.rentAmount, savingsAmount);
    }

    function withdrawSavings(uint256 _propertyId) external onlyOwner {
        Property storage prop = properties[_propertyId];
        require(prop.active, "Property inactive");
        
        uint256 amount = prop.totalSaved;
        prop.totalSaved = 0;
        
        require(stablecoin.transfer(owner(), amount), "Withdraw failed");
        emit SavingsWithdrawn(_propertyId, amount);
    }

    function getProperty(uint256 _propertyId) external view returns (Property memory) {
        return properties[_propertyId];
    }
}