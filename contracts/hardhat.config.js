require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.20",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    networks: {
        // Base Sepolia Testnet
        baseSepolia: {
            url: process.env.BASE_SEPOLIA_RPC_URL || "https://sepolia.base.org",
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
            chainId: 84532,
        },
        // Base Mainnet (for production)
        base: {
            url: process.env.BASE_MAINNET_RPC_URL || "https://mainnet.base.org",
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
            chainId: 8453,
        },
        // Local Hardhat network for testing
        hardhat: {
            chainId: 31337,
        },
    },
    etherscan: {
        apiKey: {
            baseSepolia: process.env.BASESCAN_API_KEY || "",
            base: process.env.BASESCAN_API_KEY || "",
        },
        customChains: [
            {
                network: "baseSepolia",
                chainId: 84532,
                urls: {
                    apiURL: "https://api-sepolia.basescan.org/api",
                    browserURL: "https://sepolia.basescan.org"
                }
            },
            {
                network: "base",
                chainId: 8453,
                urls: {
                    apiURL: "https://api.basescan.org/api",
                    browserURL: "https://basescan.org"
                }
            }
        ]
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS === "true",
        currency: "USD",
    },
};
