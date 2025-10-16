// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SenteBadge
 * @dev Non-transferable (Soulbound) NFT as proof of good repayment history
 * @notice These badges are reputation tokens that cannot be transferred
 */
contract SenteBadge is ERC721, ERC721URIStorage, Ownable {
    
    uint256 private _nextTokenId;
    
    struct BadgeData {
        uint8 creditScore;           // Credit score at minting
        uint256 repaymentsCount;     // Number of successful repayments
        uint256 mintedAt;            // Timestamp of minting
        string tier;                 // Badge tier (Bronze, Silver, Gold, Platinum)
    }
    
    // Mapping from token ID to badge data
    mapping(uint256 => BadgeData) public badges;
    
    // Mapping to track if address has a badge
    mapping(address => bool) public hasBadge;
    
    // Authorized minters (LendingPool contract)
    mapping(address => bool) public authorizedMinters;
    
    // Events
    event BadgeMinted(
        address indexed recipient,
        uint256 indexed tokenId,
        uint8 creditScore,
        string tier
    );
    
    event MinterAuthorized(address indexed minter, bool authorized);
    
    /**
     * @dev Constructor
     */
    constructor() ERC721("SenteBadge", "SENTE") Ownable(msg.sender) {
        _nextTokenId = 1; // Start from 1
    }
    
    /**
     * @notice Authorize or revoke minter
     * @param minter Address to authorize
     * @param authorized Whether to authorize or revoke
     */
    function setAuthorizedMinter(address minter, bool authorized) 
        external 
        onlyOwner 
    {
        require(minter != address(0), "Invalid minter address");
        authorizedMinters[minter] = authorized;
        emit MinterAuthorized(minter, authorized);
    }
    
    /**
     * @notice Mint a SenteBadge to a borrower
     * @param to Address to mint badge to
     * @param creditScore Credit score at minting
     * @param repaymentsCount Number of successful repayments
     * @return tokenId Minted token ID
     */
    function mintBadge(
        address to,
        uint8 creditScore,
        uint256 repaymentsCount
    ) external returns (uint256) {
        require(
            authorizedMinters[msg.sender] || msg.sender == owner(),
            "Not authorized to mint"
        );
        require(to != address(0), "Cannot mint to zero address");
        require(!hasBadge[to], "Address already has a badge");
        require(creditScore >= 60, "Credit score too low");
        
        uint256 tokenId = _nextTokenId++;
        
        // Determine badge tier based on credit score and repayments
        string memory tier = _determineTier(creditScore, repaymentsCount);
        
        // Store badge data
        badges[tokenId] = BadgeData({
            creditScore: creditScore,
            repaymentsCount: repaymentsCount,
            mintedAt: block.timestamp,
            tier: tier
        });
        
        // Mint the NFT
        _safeMint(to, tokenId);
        
        // Generate and set token URI
        string memory tokenURI = _generateTokenURI(tokenId, tier, creditScore);
        _setTokenURI(tokenId, tokenURI);
        
        hasBadge[to] = true;
        
        emit BadgeMinted(to, tokenId, creditScore, tier);
        
        return tokenId;
    }
    
    /**
     * @dev Determine badge tier based on credit score and repayments
     * @param creditScore Current credit score
     * @param repaymentsCount Number of successful repayments
     * @return tier Badge tier string
     */
    function _determineTier(uint8 creditScore, uint256 repaymentsCount) 
        internal 
        pure 
        returns (string memory) 
    {
        if (creditScore >= 90 && repaymentsCount >= 10) {
            return "Platinum";
        } else if (creditScore >= 80 && repaymentsCount >= 7) {
            return "Gold";
        } else if (creditScore >= 70 && repaymentsCount >= 5) {
            return "Silver";
        } else {
            return "Bronze";
        }
    }
    
    /**
     * @dev Generate token URI with badge metadata
     * @param tokenId Token ID
     * @param tier Badge tier
     * @param creditScore Credit score
     * @return JSON metadata string
     */
    function _generateTokenURI(
        uint256 tokenId,
        string memory tier,
        uint8 creditScore
    ) internal pure returns (string memory) {
        // In production, this should return IPFS URL with proper metadata
        // For demo, return inline JSON
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                _encodeBase64(
                    abi.encodePacked(
                        '{"name":"SenteBadge #',
                        _toString(tokenId),
                        '","description":"Proof of excellent repayment history on SenteChainAI",',
                        '"attributes":[',
                        '{"trait_type":"Tier","value":"',
                        tier,
                        '"},',
                        '{"trait_type":"Credit Score","value":',
                        _toString(creditScore),
                        '}',
                        ']}'
                    )
                )
            )
        );
    }
    
    /**
     * @notice Get badge data for a token
     * @param tokenId Token ID to query
     * @return BadgeData struct
     */
    function getBadgeData(uint256 tokenId) 
        external 
        view 
        returns (BadgeData memory) 
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return badges[tokenId];
    }
    
    /**
     * @notice Check if an address owns a SenteBadge
     * @param owner Address to check
     * @return Whether address owns a badge
     */
    function hasSenteBadge(address owner) external view returns (bool) {
        return hasBadge[owner];
    }
    
    /**
     * @dev Override transfer functions to make tokens non-transferable (Soulbound)
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == address(0))
        // Prevent all transfers (from != address(0) && to != address(0))
        // Allow burning if needed (to == address(0))
        require(
            from == address(0) || to == address(0),
            "SenteBadge: Soulbound token cannot be transferred"
        );
        
        return super._update(to, tokenId, auth);
    }
    
    /**
     * @dev Override to prevent approvals (since non-transferable)
     */
    function approve(address, uint256) public virtual override {
        revert("SenteBadge: Soulbound token cannot be approved");
    }
    
    /**
     * @dev Override to prevent approvals (since non-transferable)
     */
    function setApprovalForAll(address, bool) public virtual override {
        revert("SenteBadge: Soulbound token cannot be approved");
    }
    
    /**
     * @dev Required override for ERC721URIStorage
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    /**
     * @dev Required override for ERC721URIStorage
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    /**
     * @dev Helper function to convert uint256 to string
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    /**
     * @dev Simple base64 encoding (for demo purposes)
     * In production, use a proper base64 library
     */
    function _encodeBase64(bytes memory data) internal pure returns (string memory) {
        // Simplified - in production use proper base64 encoding
        return string(data);
    }
}
