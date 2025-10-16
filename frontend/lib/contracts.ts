/**
 * Contract ABIs
 * Simplified versions - import full ABIs from contract artifacts in production
 */

export const CREDIT_REGISTRY_ABI = [
    {
        inputs: [{ name: 'user', type: 'address' }],
        name: 'getScore',
        outputs: [{ name: '', type: 'uint8' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ name: 'user', type: 'address' }],
        name: 'getProfile',
        outputs: [
            {
                components: [
                    { name: 'score', type: 'uint8' },
                    { name: 'lastUpdated', type: 'uint256' },
                    { name: 'totalLoans', type: 'uint256' },
                    { name: 'successfulRepayments', type: 'uint256' },
                    { name: 'defaultedLoans', type: 'uint256' },
                    { name: 'isActive', type: 'bool' },
                ],
                name: '',
                type: 'tuple',
            },
        ],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [
            { name: 'user', type: 'address' },
            { name: 'minScore', type: 'uint8' },
        ],
        name: 'isEligibleForLoan',
        outputs: [{ name: '', type: 'bool' }],
        stateMutability: 'view',
        type: 'function',
    },
] as const;

export const LENDING_POOL_ABI = [
    {
        inputs: [{ name: 'amount', type: 'uint256' }],
        name: 'deposit',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
    },
    {
        inputs: [{ name: 'amount', type: 'uint256' }],
        name: 'withdraw',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
    },
    {
        inputs: [{ name: 'amount', type: 'uint256' }],
        name: 'requestLoan',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
    },
    {
        inputs: [{ name: 'loanId', type: 'uint256' }],
        name: 'repayLoan',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
    },
    {
        inputs: [{ name: 'borrower', type: 'address' }],
        name: 'getBorrowerLoans',
        outputs: [
            {
                components: [
                    { name: 'amount', type: 'uint256' },
                    { name: 'interestAmount', type: 'uint256' },
                    { name: 'startTime', type: 'uint256' },
                    { name: 'dueDate', type: 'uint256' },
                    { name: 'isActive', type: 'bool' },
                    { name: 'isRepaid', type: 'bool' },
                    { name: 'borrower', type: 'address' },
                ],
                name: '',
                type: 'tuple[]',
            },
        ],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ name: 'lender', type: 'address' }],
        name: 'getLenderInfo',
        outputs: [
            {
                components: [
                    { name: 'deposited', type: 'uint256' },
                    { name: 'interestEarned', type: 'uint256' },
                    { name: 'lastDepositTime', type: 'uint256' },
                ],
                name: '',
                type: 'tuple',
            },
        ],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [],
        name: 'getAvailableLiquidity',
        outputs: [{ name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [],
        name: 'getUtilizationRate',
        outputs: [{ name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
] as const;

export const SENTE_BADGE_ABI = [
    {
        inputs: [{ name: 'owner', type: 'address' }],
        name: 'balanceOf',
        outputs: [{ name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ name: 'owner', type: 'address' }],
        name: 'hasSenteBadge',
        outputs: [{ name: '', type: 'bool' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ name: 'tokenId', type: 'uint256' }],
        name: 'getBadgeData',
        outputs: [
            {
                components: [
                    { name: 'creditScore', type: 'uint8' },
                    { name: 'repaymentsCount', type: 'uint256' },
                    { name: 'mintedAt', type: 'uint256' },
                    { name: 'tier', type: 'string' },
                ],
                name: '',
                type: 'tuple',
            },
        ],
        stateMutability: 'view',
        type: 'function',
    },
] as const;

export const ERC20_ABI = [
    {
        inputs: [
            { name: 'spender', type: 'address' },
            { name: 'amount', type: 'uint256' },
        ],
        name: 'approve',
        outputs: [{ name: '', type: 'bool' }],
        stateMutability: 'nonpayable',
        type: 'function',
    },
    {
        inputs: [
            { name: 'owner', type: 'address' },
            { name: 'spender', type: 'address' },
        ],
        name: 'allowance',
        outputs: [{ name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ name: 'account', type: 'address' }],
        name: 'balanceOf',
        outputs: [{ name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [],
        name: 'decimals',
        outputs: [{ name: '', type: 'uint8' }],
        stateMutability: 'view',
        type: 'function',
    },
] as const;
