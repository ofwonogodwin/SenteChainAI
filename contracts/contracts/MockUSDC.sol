// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockUSDC
 * @dev Mock USDC token for testing purposes
 * @notice This is ONLY for testnet - DO NOT use in production
 */
contract MockUSDC is ERC20, Ownable {
    uint8 private _decimals = 6; // USDC uses 6 decimals
    
    constructor() ERC20("Mock USDC", "USDC") Ownable(msg.sender) {
        // Mint initial supply to deployer (1 million USDC)
        _mint(msg.sender, 1_000_000 * 10**6);
    }
    
    /**
     * @notice Mint tokens (for testing only)
     * @param to Address to mint to
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
    
    /**
     * @notice Faucet function - anyone can get test tokens
     */
    function faucet() external {
        // Give 1000 USDC per request
        _mint(msg.sender, 1000 * 10**6);
    }
    
    /**
     * @dev Override decimals to return 6 (like real USDC)
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
