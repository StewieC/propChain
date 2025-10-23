const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying PropertyVault...");
  
  const USDC_SEPOLIA = "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238";
  
  const PropertyVault = await hre.ethers.getContractFactory("PropertyVault");
  const propertyVault = await PropertyVault.deploy(USDC_SEPOLIA);
  
  await propertyVault.waitForDeployment();
  console.log("✅ PropertyVault deployed to:", await propertyVault.getAddress());
  console.log("📋 SAVE THIS ADDRESS!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});