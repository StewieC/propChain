const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Deploy PropertyNFT
  const PropertyNFT = await ethers.getContractFactory("PropertyNFT");
  const propertyNFT = await PropertyNFT.deploy();
  await propertyNFT.deployed();
  console.log("PropertyNFT deployed to:", propertyNFT.address);

  // Deploy MockERC20 (for testing USDC)
  const MockERC20 = await ethers.getContractFactory("MockERC20");
  const stableCoin = await MockERC20.deploy("USDC", "USDC", ethers.utils.parseUnits("10000", 6));
  await stableCoin.deployed();
  console.log("MockERC20 deployed to:", stableCoin.address);

  // Deploy RentalManager (using deployer as mock Aave for now)
  const RentalManager = await ethers.getContractFactory("RentalManager");
  const rentalManager = await RentalManager.deploy(propertyNFT.address, stableCoin.address, deployer.address);
  await rentalManager.deployed();
  console.log("RentalManager deployed to:", rentalManager.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});