// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CreditScoreRegistry
 * @dev Stores and manages AI-generated credit scores (SenteScores) on-chain
 * @notice This contract allows authorized AI oracles to update user credit scores
 */
contract CreditScoreRegistry is AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    
    // Credit score range: 0-100
    uint8 public constant MIN_SCORE = 0;
    uint8 public constant MAX_SCORE = 100;
    uint8 public constant DEFAULT_SCORE = 50;
    
    struct CreditProfile {
        uint8 score;                    // Current credit score (0-100)
        uint256 lastUpdated;            // Timestamp of last score update
        uint256 totalLoans;             // Total number of loans taken
        uint256 successfulRepayments;   // Number of successful repayments
        uint256 defaultedLoans;         // Number of defaulted loans
        bool isActive;                  // Whether profile is active
    }
    
    // Mapping from user address to their credit profile
    mapping(address => CreditProfile) public creditProfiles;
    
    // Events
    event ScoreUpdated(
        address indexed user,
        uint8 newScore,
        uint8 oldScore,
        uint256 timestamp
    );
    
    event ProfileCreated(
        address indexed user,
        uint8 initialScore,
        uint256 timestamp
    );
    
    event LoanRecorded(
        address indexed user,
        bool isRepayment,
        uint256 timestamp
    );
    
    /**
     * @dev Constructor grants admin and oracle roles to deployer
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ROLE, msg.sender);
    }
    
    /**
     * @notice Create a new credit profile for a user
     * @param user Address of the user
     * @param initialScore Initial credit score (0-100)
     */
    function createProfile(address user, uint8 initialScore) 
        external 
        onlyRole(ORACLE_ROLE) 
    {
        require(!creditProfiles[user].isActive, "Profile already exists");
        require(initialScore >= MIN_SCORE && initialScore <= MAX_SCORE, "Invalid score");
        
        creditProfiles[user] = CreditProfile({
            score: initialScore,
            lastUpdated: block.timestamp,
            totalLoans: 0,
            successfulRepayments: 0,
            defaultedLoans: 0,
            isActive: true
        });
        
        emit ProfileCreated(user, initialScore, block.timestamp);
    }
    
    /**
     * @notice Update a user's credit score
     * @param user Address of the user
     * @param newScore New credit score (0-100)
     */
    function updateScore(address user, uint8 newScore) 
        external 
        onlyRole(ORACLE_ROLE) 
    {
        require(newScore >= MIN_SCORE && newScore <= MAX_SCORE, "Invalid score");
        
        if (!creditProfiles[user].isActive) {
            createProfile(user, newScore);
            return;
        }
        
        uint8 oldScore = creditProfiles[user].score;
        creditProfiles[user].score = newScore;
        creditProfiles[user].lastUpdated = block.timestamp;
        
        emit ScoreUpdated(user, newScore, oldScore, block.timestamp);
    }
    
    /**
     * @notice Record a new loan for a user
     * @param user Address of the borrower
     */
    function recordLoan(address user) external onlyRole(ORACLE_ROLE) {
        require(creditProfiles[user].isActive, "Profile does not exist");
        
        creditProfiles[user].totalLoans++;
        
        emit LoanRecorded(user, false, block.timestamp);
    }
    
    /**
     * @notice Record a successful loan repayment
     * @param user Address of the borrower
     */
    function recordRepayment(address user) external onlyRole(ORACLE_ROLE) {
        require(creditProfiles[user].isActive, "Profile does not exist");
        
        creditProfiles[user].successfulRepayments++;
        
        // Improve score by 1-5 points for successful repayment
        uint8 currentScore = creditProfiles[user].score;
        uint8 improvement = 2; // Base improvement
        
        if (currentScore < MAX_SCORE) {
            uint8 newScore = currentScore + improvement;
            if (newScore > MAX_SCORE) {
                newScore = MAX_SCORE;
            }
            creditProfiles[user].score = newScore;
            creditProfiles[user].lastUpdated = block.timestamp;
            
            emit ScoreUpdated(user, newScore, currentScore, block.timestamp);
        }
        
        emit LoanRecorded(user, true, block.timestamp);
    }
    
    /**
     * @notice Record a loan default
     * @param user Address of the borrower
     */
    function recordDefault(address user) external onlyRole(ORACLE_ROLE) {
        require(creditProfiles[user].isActive, "Profile does not exist");
        
        creditProfiles[user].defaultedLoans++;
        
        // Decrease score by 10-20 points for default
        uint8 currentScore = creditProfiles[user].score;
        uint8 penalty = 15; // Base penalty
        
        if (currentScore > MIN_SCORE) {
            uint8 newScore = currentScore > penalty ? currentScore - penalty : MIN_SCORE;
            creditProfiles[user].score = newScore;
            creditProfiles[user].lastUpdated = block.timestamp;
            
            emit ScoreUpdated(user, newScore, currentScore, block.timestamp);
        }
    }
    
    /**
     * @notice Get a user's current credit score
     * @param user Address of the user
     * @return score Current credit score
     */
    function getScore(address user) external view returns (uint8) {
        if (!creditProfiles[user].isActive) {
            return DEFAULT_SCORE;
        }
        return creditProfiles[user].score;
    }
    
    /**
     * @notice Get complete credit profile for a user
     * @param user Address of the user
     * @return profile Complete CreditProfile struct
     */
    function getProfile(address user) 
        external 
        view 
        returns (CreditProfile memory) 
    {
        return creditProfiles[user];
    }
    
    /**
     * @notice Check if user is eligible for a loan based on minimum score
     * @param user Address of the user
     * @param minScore Minimum required score
     * @return eligible Whether user is eligible
     */
    function isEligibleForLoan(address user, uint8 minScore) 
        external 
        view 
        returns (bool) 
    {
        if (!creditProfiles[user].isActive) {
            return DEFAULT_SCORE >= minScore;
        }
        return creditProfiles[user].score >= minScore;
    }
    
    /**
     * @notice Calculate repayment success rate for a user
     * @param user Address of the user
     * @return rate Repayment success rate (0-100)
     */
    function getRepaymentRate(address user) external view returns (uint256) {
        if (!creditProfiles[user].isActive || creditProfiles[user].totalLoans == 0) {
            return 0;
        }
        
        return (creditProfiles[user].successfulRepayments * 100) / 
               creditProfiles[user].totalLoans;
    }
}
