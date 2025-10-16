const hre = require("hardhat");

async function main() {
    console.log("🚀 Starting SenteChainAI contract deployment...\n");

    const [deployer] = await hre.ethers.getSigners();
    console.log("📝 Deploying contracts with account:", deployer.address);

    const balance = await hre.ethers.provider.getBalance(deployer.address);
    console.log("💰 Account balance:", hre.ethers.formatEther(balance), "ETH\n");

    // USDC Token address (Base Sepolia testnet)
    // You may need to deploy a mock USDC or use existing testnet USDC
    const USDC_ADDRESS = process.env.USDC_TOKEN_ADDRESS || "0x036CbD53842c5426634e7929541eC2318f3dCF7e";

    console.log("📄 USDC Token Address:", USDC_ADDRESS, "\n");

    // 1. Deploy CreditScoreRegistry
    console.log("1️⃣  Deploying CreditScoreRegistry...");
    const CreditScoreRegistry = await hre.ethers.getContractFactory("CreditScoreRegistry");
    const creditRegistry = await CreditScoreRegistry.deploy();
    await creditRegistry.waitForDeployment();
    const creditRegistryAddress = await creditRegistry.getAddress();
    console.log("✅ CreditScoreRegistry deployed to:", creditRegistryAddress, "\n");

    // 2. Deploy SenteBadge
    console.log("2️⃣  Deploying SenteBadge...");
    const SenteBadge = await hre.ethers.getContractFactory("SenteBadge");
    const senteBadge = await SenteBadge.deploy();
    await senteBadge.waitForDeployment();
    const senteBadgeAddress = await senteBadge.getAddress();
    console.log("✅ SenteBadge deployed to:", senteBadgeAddress, "\n");

    // 3. Deploy LendingPool
    console.log("3️⃣  Deploying LendingPool...");
    const LendingPool = await hre.ethers.getContractFactory("LendingPool");
    const lendingPool = await LendingPool.deploy(
        USDC_ADDRESS,
        creditRegistryAddress
    );
    await lendingPool.waitForDeployment();
    const lendingPoolAddress = await lendingPool.getAddress();
    console.log("✅ LendingPool deployed to:", lendingPoolAddress, "\n");

    // 4. Configure contracts
    console.log("4️⃣  Configuring contracts...");

    // Set LendingPool as oracle in CreditScoreRegistry
    console.log("   - Granting ORACLE_ROLE to LendingPool...");
    const ORACLE_ROLE = await creditRegistry.ORACLE_ROLE();
    await creditRegistry.grantRole(ORACLE_ROLE, lendingPoolAddress);
    console.log("   ✅ ORACLE_ROLE granted\n");

    // Set SenteBadge contract in LendingPool
    console.log("   - Setting SenteBadge in LendingPool...");
    await lendingPool.setSenteBadge(senteBadgeAddress);
    console.log("   ✅ SenteBadge configured\n");

    // Authorize LendingPool to mint badges
    console.log("   - Authorizing LendingPool to mint badges...");
    await senteBadge.setAuthorizedMinter(lendingPoolAddress, true);
    console.log("   ✅ Minter authorized\n");

    // Summary
    console.log("=".repeat(60));
    console.log("🎉 DEPLOYMENT COMPLETE!");
    console.log("=".repeat(60));
    console.log("\n📋 Contract Addresses:");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("CreditScoreRegistry:", creditRegistryAddress);
    console.log("SenteBadge:         ", senteBadgeAddress);
    console.log("LendingPool:        ", lendingPoolAddress);
    console.log("USDC Token:         ", USDC_ADDRESS);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    console.log("📝 Add these addresses to your frontend .env.local file:");
    console.log(`NEXT_PUBLIC_CREDIT_REGISTRY_ADDRESS=${creditRegistryAddress}`);
    console.log(`NEXT_PUBLIC_SENTE_BADGE_ADDRESS=${senteBadgeAddress}`);
    console.log(`NEXT_PUBLIC_LENDING_POOL_ADDRESS=${lendingPoolAddress}`);
    console.log(`NEXT_PUBLIC_USDC_ADDRESS=${USDC_ADDRESS}\n`);

    console.log("🔍 Verify contracts on BaseScan:");
    console.log(`npx hardhat verify --network baseSepolia ${creditRegistryAddress}`);
    console.log(`npx hardhat verify --network baseSepolia ${senteBadgeAddress}`);
    console.log(`npx hardhat verify --network baseSepolia ${lendingPoolAddress} "${USDC_ADDRESS}" "${creditRegistryAddress}"\n`);

    // Save deployment info
    const fs = require('fs');
    const deploymentInfo = {
        network: hre.network.name,
        chainId: (await hre.ethers.provider.getNetwork()).chainId.toString(),
        deployer: deployer.address,
        timestamp: new Date().toISOString(),
        contracts: {
            CreditScoreRegistry: creditRegistryAddress,
            SenteBadge: senteBadgeAddress,
            LendingPool: lendingPoolAddress,
            USDCToken: USDC_ADDRESS
        }
    };

    fs.writeFileSync(
        'deployment-info.json',
        JSON.stringify(deploymentInfo, null, 2)
    );
    console.log("💾 Deployment info saved to deployment-info.json\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
