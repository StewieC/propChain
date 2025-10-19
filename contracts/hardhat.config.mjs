import { config as dotEnvConfig } from "dotenv";
  import "@nomicfoundation/hardhat-toolbox";
  import "hardhat-gas-reporter";

  dotEnvConfig();

  export default {
    solidity: {
      compilers: [
        {
          version: "0.8.20",
          settings: {
            optimizer: {
              enabled: true,
              runs: 200,
            },
          },
        },
      ],
    },
    networks: {
      hardhat: {
        chainId: 31337,
      },
      sepolia: {
        url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
        accounts: [process.env.PRIVATE_KEY],
      },
    },
    gasReporter: {
      enabled: true,
      currency: "USD",
    },
  };