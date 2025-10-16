/**
 * Web3 Configuration
 * Wagmi and RainbowKit setup for Base Sepolia
 */

import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { baseSepolia, base } from 'wagmi/chains';

const projectId = process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || '';

export const config = getDefaultConfig({
    appName: 'SenteChainAI',
    projectId: projectId,
    chains: [baseSepolia, base],
    ssr: true,
});

// Contract addresses
export const CONTRACTS = {
    CREDIT_REGISTRY: process.env.NEXT_PUBLIC_CREDIT_REGISTRY_ADDRESS as `0x${string}`,
    LENDING_POOL: process.env.NEXT_PUBLIC_LENDING_POOL_ADDRESS as `0x${string}`,
    SENTE_BADGE: process.env.NEXT_PUBLIC_SENTE_BADGE_ADDRESS as `0x${string}`,
    USDC: process.env.NEXT_PUBLIC_USDC_ADDRESS as `0x${string}`,
};

// API Configuration
export const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

// Blockchain configuration
export const CHAIN_CONFIG = {
    id: parseInt(process.env.NEXT_PUBLIC_CHAIN_ID || '84532'),
    name: process.env.NEXT_PUBLIC_CHAIN_NAME || 'Base Sepolia',
    rpcUrl: process.env.NEXT_PUBLIC_RPC_URL || 'https://sepolia.base.org',
    blockExplorer: process.env.NEXT_PUBLIC_BLOCK_EXPLORER || 'https://sepolia.basescan.org',
};
