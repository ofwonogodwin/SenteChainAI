// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./CreditScoreRegistry.sol";
import "./SenteBadge.sol";

/**
 * @title LendingPool
 * @dev Manages lending pool operations including deposits, loans, and repayments
 * @notice This contract integrates with CreditScoreRegistry for credit checks
 */
contract LendingPool is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    // State variables
    IERC20 public immutable usdcToken;
    CreditScoreRegistry public immutable creditRegistry;
    SenteBadge public senteBadge;
    
    // Pool parameters
    uint256 public constant INTEREST_RATE = 10; // 10% annual interest (simplified)
    uint256 public constant MIN_CREDIT_SCORE = 60; // Minimum score to borrow
    uint256 public constant MAX_LOAN_AMOUNT = 1000 * 10**6; // 1000 USDC (6 decimals)
    uint256 public constant MIN_LOAN_AMOUNT = 10 * 10**6; // 10 USDC
    uint256 public constant LOAN_DURATION = 30 days;
    uint256 public constant REPAYMENT_GRACE_PERIOD = 7 days;
    
    // Pool statistics
    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public totalRepaid;
    
    struct Loan {
        uint256 amount;              // Principal amount
        uint256 interestAmount;      // Interest to be paid
        uint256 startTime;           // Loan start timestamp
        uint256 dueDate;             // Loan due date
        bool isActive;               // Whether loan is active
        bool isRepaid;               // Whether loan is repaid
        address borrower;            // Borrower address
    }
    
    struct LenderInfo {
        uint256 deposited;           // Total deposited
        uint256 interestEarned;      // Interest earned
        uint256 lastDepositTime;     // Last deposit timestamp
    }
    
    // Mappings
    mapping(address => LenderInfo) public lenders;
    mapping(address => Loan[]) public borrowerLoans;
    mapping(address => uint256) public activeLoanCount;
    
    // Events
    event Deposited(address indexed lender, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed lender, uint256 amount, uint256 timestamp);
    event LoanRequested(
        address indexed borrower,
        uint256 loanId,
        uint256 amount,
        uint256 dueDate
    );
    event LoanRepaid(
        address indexed borrower,
        uint256 loanId,
        uint256 amount,
        uint256 timestamp
    );
    event LoanDefaulted(address indexed borrower, uint256 loanId);
    event BadgeMinted(address indexed borrower, uint256 tokenId);
    
    /**
     * @dev Constructor
     * @param _usdcToken USDC token address
     * @param _creditRegistry CreditScoreRegistry contract address
     */
    constructor(
        address _usdcToken,
        address _creditRegistry
    ) Ownable(msg.sender) {
        require(_usdcToken != address(0), "Invalid USDC address");
        require(_creditRegistry != address(0), "Invalid registry address");
        
        usdcToken = IERC20(_usdcToken);
        creditRegistry = CreditScoreRegistry(_creditRegistry);
    }
    
    /**
     * @notice Set the SenteBadge contract address
     * @param _senteBadge SenteBadge contract address
     */
    function setSenteBadge(address _senteBadge) external onlyOwner {
        require(_senteBadge != address(0), "Invalid badge address");
        senteBadge = SenteBadge(_senteBadge);
    }
    
    /**
     * @notice Deposit USDC into the lending pool
     * @param amount Amount of USDC to deposit
     */
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        
        usdcToken.safeTransferFrom(msg.sender, address(this), amount);
        
        lenders[msg.sender].deposited += amount;
        lenders[msg.sender].lastDepositTime = block.timestamp;
        totalDeposits += amount;
        
        emit Deposited(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @notice Withdraw USDC from the lending pool
     * @param amount Amount of USDC to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(lenders[msg.sender].deposited >= amount, "Insufficient balance");
        
        // Check if pool has enough liquidity
        uint256 availableLiquidity = getAvailableLiquidity();
        require(availableLiquidity >= amount, "Insufficient pool liquidity");
        
        lenders[msg.sender].deposited -= amount;
        totalDeposits -= amount;
        
        usdcToken.safeTransfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @notice Request a loan from the pool
     * @param amount Loan amount requested
     */
    function requestLoan(uint256 amount) external nonReentrant {
        require(amount >= MIN_LOAN_AMOUNT, "Amount too low");
        require(amount <= MAX_LOAN_AMOUNT, "Amount exceeds maximum");
        require(activeLoanCount[msg.sender] == 0, "Active loan exists");
        
        // Check credit score
        uint8 creditScore = creditRegistry.getScore(msg.sender);
        require(creditScore >= MIN_CREDIT_SCORE, "Credit score too low");
        
        // Check pool liquidity
        uint256 availableLiquidity = getAvailableLiquidity();
        require(availableLiquidity >= amount, "Insufficient pool liquidity");
        
        // Calculate loan terms based on credit score
        uint256 interestAmount = calculateInterest(amount, creditScore);
        uint256 dueDate = block.timestamp + LOAN_DURATION;
        
        // Create loan
        Loan memory newLoan = Loan({
            amount: amount,
            interestAmount: interestAmount,
            startTime: block.timestamp,
            dueDate: dueDate,
            isActive: true,
            isRepaid: false,
            borrower: msg.sender
        });
        
        borrowerLoans[msg.sender].push(newLoan);
        uint256 loanId = borrowerLoans[msg.sender].length - 1;
        
        activeLoanCount[msg.sender]++;
        totalBorrowed += amount;
        
        // Record loan in credit registry
        creditRegistry.recordLoan(msg.sender);
        
        // Transfer funds to borrower
        usdcToken.safeTransfer(msg.sender, amount);
        
        emit LoanRequested(msg.sender, loanId, amount, dueDate);
    }
    
    /**
     * @notice Repay an active loan
     * @param loanId ID of the loan to repay
     */
    function repayLoan(uint256 loanId) external nonReentrant {
        require(loanId < borrowerLoans[msg.sender].length, "Invalid loan ID");
        
        Loan storage loan = borrowerLoans[msg.sender][loanId];
        require(loan.isActive, "Loan not active");
        require(!loan.isRepaid, "Loan already repaid");
        require(loan.borrower == msg.sender, "Not loan owner");
        
        uint256 totalRepayment = loan.amount + loan.interestAmount;
        
        // Check if loan is past due date + grace period
        bool isPastGracePeriod = block.timestamp > (loan.dueDate + REPAYMENT_GRACE_PERIOD);
        
        if (isPastGracePeriod) {
            // Mark as defaulted
            loan.isActive = false;
            activeLoanCount[msg.sender]--;
            creditRegistry.recordDefault(msg.sender);
            
            emit LoanDefaulted(msg.sender, loanId);
            revert("Loan defaulted - past grace period");
        }
        
        // Transfer repayment amount
        usdcToken.safeTransferFrom(msg.sender, address(this), totalRepayment);
        
        // Update loan status
        loan.isActive = false;
        loan.isRepaid = true;
        activeLoanCount[msg.sender]--;
        totalRepaid += totalRepayment;
        
        // Distribute interest to lenders proportionally (simplified)
        // In production, implement proper interest distribution mechanism
        
        // Record repayment in credit registry
        creditRegistry.recordRepayment(msg.sender);
        
        emit LoanRepaid(msg.sender, loanId, totalRepayment, block.timestamp);
        
        // Check if eligible for SenteBadge
        _checkAndMintBadge(msg.sender);
    }
    
    /**
     * @notice Calculate interest based on amount and credit score
     * @param amount Principal amount
     * @param creditScore Borrower's credit score
     * @return interest Interest amount to be paid
     */
    function calculateInterest(uint256 amount, uint8 creditScore) 
        public 
        pure 
        returns (uint256) 
    {
        // Better credit score = lower interest rate
        // Score 60-70: 10% interest
        // Score 71-80: 8% interest
        // Score 81-90: 6% interest
        // Score 91-100: 5% interest
        
        uint256 rate;
        if (creditScore >= 91) {
            rate = 5;
        } else if (creditScore >= 81) {
            rate = 6;
        } else if (creditScore >= 71) {
            rate = 8;
        } else {
            rate = 10;
        }
        
        return (amount * rate) / 100;
    }
    
    /**
     * @notice Get available liquidity in the pool
     * @return Available USDC balance
     */
    function getAvailableLiquidity() public view returns (uint256) {
        return usdcToken.balanceOf(address(this));
    }
    
    /**
     * @notice Get all loans for a borrower
     * @param borrower Borrower address
     * @return Array of loans
     */
    function getBorrowerLoans(address borrower) 
        external 
        view 
        returns (Loan[] memory) 
    {
        return borrowerLoans[borrower];
    }
    
    /**
     * @notice Get lender information
     * @param lender Lender address
     * @return LenderInfo struct
     */
    function getLenderInfo(address lender) 
        external 
        view 
        returns (LenderInfo memory) 
    {
        return lenders[lender];
    }
    
    /**
     * @notice Get pool utilization rate
     * @return Utilization rate percentage (0-100)
     */
    function getUtilizationRate() external view returns (uint256) {
        if (totalDeposits == 0) return 0;
        
        uint256 currentBorrowed = totalBorrowed - totalRepaid;
        return (currentBorrowed * 100) / totalDeposits;
    }
    
    /**
     * @dev Check if borrower is eligible for badge and mint
     * @param borrower Address to check
     */
    function _checkAndMintBadge(address borrower) internal {
        if (address(senteBadge) == address(0)) return;
        
        // Check if borrower already has a badge
        if (senteBadge.balanceOf(borrower) > 0) return;
        
        // Get credit profile
        CreditScoreRegistry.CreditProfile memory profile = 
            creditRegistry.getProfile(borrower);
        
        // Mint badge if: 3+ successful repayments and 0 defaults
        if (profile.successfulRepayments >= 3 && profile.defaultedLoans == 0) {
            uint256 tokenId = senteBadge.mintBadge(
                borrower,
                profile.score,
                profile.successfulRepayments
            );
            
            emit BadgeMinted(borrower, tokenId);
        }
    }
    
    /**
     * @notice Emergency withdraw (owner only)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount <= getAvailableLiquidity(), "Insufficient balance");
        usdcToken.safeTransfer(owner(), amount);
    }
}
