require('dotenv').config();
require('@nomicfoundation/hardhat-toolbox');

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200, // Optimized for production/gas efficiency, useful for hackathon demo
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: 31337, // Explicit chain ID for local testing
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    enabled: true, // Optional: Adds gas usage reports (useful for optimization)
    currency: 'USD',
  },
};