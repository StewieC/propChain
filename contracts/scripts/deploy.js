const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying PropertyVault...");
  
  // Sepolia USDC address
  const USDC_SEPOLIA = "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238";
  
  const PropertyVault = await hre.ethers.getContractFactory("PropertyVault");
  const propertyVault = await PropertyVault.deploy(USDC_SEPOLIA);
  
  await propertyVault.waitForDeployment();
  const address = await propertyVault.getAddress();
  
  console.log("✅ PropertyVault deployed to:", address);
  console.log("📋 SAVE THIS ADDRESS FOR FRONTEND!");
  console.log("💰 USDC used:", USDC_SEPOLIA);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});