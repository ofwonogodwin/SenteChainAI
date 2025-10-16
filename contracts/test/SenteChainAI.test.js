const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SenteChainAI Contracts", function () {
    let creditRegistry, lendingPool, senteBadge, mockUSDC;
    let owner, borrower, lender, addr3;

    beforeEach(async function () {
        [owner, borrower, lender, addr3] = await ethers.getSigners();

        // Deploy MockUSDC
        const MockUSDC = await ethers.getContractFactory("MockUSDC");
        mockUSDC = await MockUSDC.deploy();
        await mockUSDC.waitForDeployment();

        // Deploy CreditScoreRegistry
        const CreditScoreRegistry = await ethers.getContractFactory("CreditScoreRegistry");
        creditRegistry = await CreditScoreRegistry.deploy();
        await creditRegistry.waitForDeployment();

        // Deploy SenteBadge
        const SenteBadge = await ethers.getContractFactory("SenteBadge");
        senteBadge = await SenteBadge.deploy();
        await senteBadge.waitForDeployment();

        // Deploy LendingPool
        const LendingPool = await ethers.getContractFactory("LendingPool");
        lendingPool = await LendingPool.deploy(
            await mockUSDC.getAddress(),
            await creditRegistry.getAddress()
        );
        await lendingPool.waitForDeployment();

        // Configure contracts
        const ORACLE_ROLE = await creditRegistry.ORACLE_ROLE();
        await creditRegistry.grantRole(ORACLE_ROLE, await lendingPool.getAddress());
        await lendingPool.setSenteBadge(await senteBadge.getAddress());
        await senteBadge.setAuthorizedMinter(await lendingPool.getAddress(), true);

        // Mint USDC to lender for deposits
        await mockUSDC.mint(lender.address, ethers.parseUnits("10000", 6));
    });

    describe("CreditScoreRegistry", function () {
        it("Should create a new credit profile", async function () {
            await creditRegistry.createProfile(borrower.address, 75);
            const profile = await creditRegistry.getProfile(borrower.address);

            expect(profile.score).to.equal(75);
            expect(profile.isActive).to.equal(true);
        });

        it("Should update credit score", async function () {
            await creditRegistry.createProfile(borrower.address, 70);
            await creditRegistry.updateScore(borrower.address, 80);

            const score = await creditRegistry.getScore(borrower.address);
            expect(score).to.equal(80);
        });

        it("Should record loan and repayment", async function () {
            await creditRegistry.createProfile(borrower.address, 70);
            await creditRegistry.recordLoan(borrower.address);
            await creditRegistry.recordRepayment(borrower.address);

            const profile = await creditRegistry.getProfile(borrower.address);
            expect(profile.totalLoans).to.equal(1);
            expect(profile.successfulRepayments).to.equal(1);
        });

        it("Should check loan eligibility", async function () {
            await creditRegistry.createProfile(borrower.address, 65);

            const eligible = await creditRegistry.isEligibleForLoan(borrower.address, 60);
            expect(eligible).to.equal(true);

            const notEligible = await creditRegistry.isEligibleForLoan(borrower.address, 70);
            expect(notEligible).to.equal(false);
        });
    });

    describe("LendingPool", function () {
        beforeEach(async function () {
            // Create credit profile for borrower
            await creditRegistry.createProfile(borrower.address, 75);

            // Lender deposits USDC
            await mockUSDC.connect(lender).approve(
                await lendingPool.getAddress(),
                ethers.parseUnits("5000", 6)
            );
            await lendingPool.connect(lender).deposit(ethers.parseUnits("5000", 6));
        });

        it("Should allow lender to deposit", async function () {
            const lenderInfo = await lendingPool.getLenderInfo(lender.address);
            expect(lenderInfo.deposited).to.equal(ethers.parseUnits("5000", 6));
        });

        it("Should allow borrower to request loan", async function () {
            const loanAmount = ethers.parseUnits("100", 6);

            await lendingPool.connect(borrower).requestLoan(loanAmount);

            const loans = await lendingPool.getBorrowerLoans(borrower.address);
            expect(loans.length).to.equal(1);
            expect(loans[0].amount).to.equal(loanAmount);
            expect(loans[0].isActive).to.equal(true);
        });

        it("Should reject loan request if credit score too low", async function () {
            await creditRegistry.updateScore(borrower.address, 50);

            await expect(
                lendingPool.connect(borrower).requestLoan(ethers.parseUnits("100", 6))
            ).to.be.revertedWith("Credit score too low");
        });

        it("Should allow loan repayment", async function () {
            const loanAmount = ethers.parseUnits("100", 6);

            await lendingPool.connect(borrower).requestLoan(loanAmount);

            const loans = await lendingPool.getBorrowerLoans(borrower.address);
            const totalRepayment = loans[0].amount + loans[0].interestAmount;

            // Mint USDC to borrower for repayment
            await mockUSDC.mint(borrower.address, totalRepayment);
            await mockUSDC.connect(borrower).approve(
                await lendingPool.getAddress(),
                totalRepayment
            );

            await lendingPool.connect(borrower).repayLoan(0);

            const updatedLoans = await lendingPool.getBorrowerLoans(borrower.address);
            expect(updatedLoans[0].isRepaid).to.equal(true);
            expect(updatedLoans[0].isActive).to.equal(false);
        });

        it("Should calculate interest based on credit score", async function () {
            // High credit score (91+) should get 5% interest
            const highScoreInterest = await lendingPool.calculateInterest(
                ethers.parseUnits("100", 6),
                95
            );
            expect(highScoreInterest).to.equal(ethers.parseUnits("5", 6));

            // Low credit score (60-70) should get 10% interest
            const lowScoreInterest = await lendingPool.calculateInterest(
                ethers.parseUnits("100", 6),
                65
            );
            expect(lowScoreInterest).to.equal(ethers.parseUnits("10", 6));
        });

        it("Should return correct pool utilization rate", async function () {
            const loanAmount = ethers.parseUnits("1000", 6);
            await lendingPool.connect(borrower).requestLoan(loanAmount);

            const utilizationRate = await lendingPool.getUtilizationRate();
            expect(utilizationRate).to.equal(20); // 1000/5000 * 100 = 20%
        });
    });

    describe("SenteBadge", function () {
        it("Should mint badge to authorized borrower", async function () {
            await senteBadge.connect(owner).mintBadge(borrower.address, 85, 5);

            const hasBadge = await senteBadge.hasSenteBadge(borrower.address);
            expect(hasBadge).to.equal(true);

            const balance = await senteBadge.balanceOf(borrower.address);
            expect(balance).to.equal(1);
        });

        it("Should prevent duplicate badges", async function () {
            await senteBadge.connect(owner).mintBadge(borrower.address, 85, 5);

            await expect(
                senteBadge.connect(owner).mintBadge(borrower.address, 90, 6)
            ).to.be.revertedWith("Address already has a badge");
        });

        it("Should prevent transfers (Soulbound)", async function () {
            await senteBadge.connect(owner).mintBadge(borrower.address, 85, 5);

            await expect(
                senteBadge.connect(borrower).transferFrom(borrower.address, addr3.address, 1)
            ).to.be.revertedWith("SenteBadge: Soulbound token cannot be transferred");
        });

        it("Should prevent approvals (Soulbound)", async function () {
            await senteBadge.connect(owner).mintBadge(borrower.address, 85, 5);

            await expect(
                senteBadge.connect(borrower).approve(addr3.address, 1)
            ).to.be.revertedWith("SenteBadge: Soulbound token cannot be approved");
        });

        it("Should return correct badge tier", async function () {
            // Bronze tier
            await senteBadge.connect(owner).mintBadge(borrower.address, 65, 3);
            let badgeData = await senteBadge.getBadgeData(1);
            expect(badgeData.tier).to.equal("Bronze");

            // Gold tier
            await senteBadge.connect(owner).mintBadge(lender.address, 85, 8);
            badgeData = await senteBadge.getBadgeData(2);
            expect(badgeData.tier).to.equal("Gold");
        });
    });

    describe("Integration Tests", function () {
        it("Should complete full lending cycle and mint badge", async function () {
            // Setup
            await creditRegistry.createProfile(borrower.address, 75);
            await mockUSDC.connect(lender).approve(
                await lendingPool.getAddress(),
                ethers.parseUnits("5000", 6)
            );
            await lendingPool.connect(lender).deposit(ethers.parseUnits("5000", 6));

            // Borrower takes and repays 3 loans
            for (let i = 0; i < 3; i++) {
                const loanAmount = ethers.parseUnits("100", 6);
                await lendingPool.connect(borrower).requestLoan(loanAmount);

                const loans = await lendingPool.getBorrowerLoans(borrower.address);
                const loan = loans[i];
                const totalRepayment = loan.amount + loan.interestAmount;

                await mockUSDC.mint(borrower.address, totalRepayment);
                await mockUSDC.connect(borrower).approve(
                    await lendingPool.getAddress(),
                    totalRepayment
                );

                await lendingPool.connect(borrower).repayLoan(i);
            }

            // Check if badge was minted
            const hasBadge = await senteBadge.hasSenteBadge(borrower.address);
            expect(hasBadge).to.equal(true);

            // Check credit score improved
            const finalScore = await creditRegistry.getScore(borrower.address);
            expect(finalScore).to.be.greaterThan(75);
        });
    });
});
