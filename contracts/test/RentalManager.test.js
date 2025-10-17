const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RentalManager", function () {
  let PropertyNFT, RentalManager, propertyNFT, rentalManager, owner, renter, stableCoin;
  const monthlyRent = ethers.utils.parseUnits("100", 6); // 100 USDC (6 decimals)
  const deposit = ethers.utils.parseUnits("500", 6); // 500 USDC

  beforeEach(async function () {
    [owner, renter] = await ethers.getSigners();

    // Deploy mock USDC
    const ERC20 = await ethers.getContractFactory("MockERC20");
    stableCoin = await ERC20.deploy("USDC", "USDC", ethers.utils.parseUnits("10000", 6));
    await stableCoin.deployed();

    // Deploy PropertyNFT
    PropertyNFT = await ethers.getContractFactory("PropertyNFT");
    propertyNFT = await PropertyNFT.deploy();
    await propertyNFT.deployed();
    await propertyNFT.mintProperty(owner.address, "ipfs://test");

    // Deploy RentalManager (use mock Aave address for testing)
    RentalManager = await ethers.getContractFactory("RentalManager");
    rentalManager = await RentalManager.deploy(propertyNFT.address, stableCoin.address, owner.address);
    await rentalManager.deployed();

    // Fund renter with USDC
    await stableCoin.transfer(renter.address, ethers.utils.parseUnits("1000", 6));
    await stableCoin.connect(renter).approve(rentalManager.address, ethers.utils.parseUnits("1000", 6));
  });

  it("Should create and pay rent", async function () {
    await rentalManager.createRental(1, renter.address, monthlyRent, deposit, 12);
    await expect(rentalManager.connect(renter).payRent(1))
      .to.emit(rentalManager, "RentPaid")
      .withArgs(1, renter.address, monthlyRent);
    expect((await rentalManager.agreements(1)).active).to.be.true;
  });
});