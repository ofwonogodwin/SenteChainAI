/**
 * API Client for backend communication
 */

import axios from 'axios';
import { API_URL } from './config';

const apiClient = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

export interface CreditScore {
    wallet_address: string;
    score: number;
    tier: string;
    eligible_for_loan: boolean;
    max_loan_amount: number;
    interest_rate: number;
    message: string;
}

export interface UserProfile {
    wallet_address: string;
    credit_score: number;
    total_loans: number;
    successful_repayments: number;
    defaulted_loans: number;
    total_borrowed: number;
    total_repaid: number;
    has_badge: boolean;
    repayment_rate: number | null;
}

export interface LoanInfo {
    id: number;
    borrower_address: string;
    loan_id_onchain: number;
    amount: number;
    interest_amount: number;
    credit_score_at_loan: number | null;
    start_time: string;
    due_date: string;
    repaid_at: string | null;
    is_active: boolean;
    is_repaid: boolean;
    is_defaulted: boolean;
}

// Get credit score
export const getCreditScore = async (walletAddress: string): Promise<CreditScore> => {
    const response = await apiClient.post('/score', {
        wallet_address: walletAddress,
    });
    return response.data;
};

// Get existing credit score
export const getExistingScore = async (walletAddress: string): Promise<CreditScore> => {
    const response = await apiClient.get(`/score/${walletAddress}`);
    return response.data;
};

// Get user profile
export const getUserProfile = async (walletAddress: string): Promise<UserProfile> => {
    const response = await apiClient.get(`/user/${walletAddress}`);
    return response.data;
};

// Get user loans
export const getUserLoans = async (
    walletAddress: string,
    activeOnly: boolean = false
): Promise<LoanInfo[]> => {
    const response = await apiClient.get(`/loans/${walletAddress}`, {
        params: { active_only: activeOnly },
    });
    return response.data;
};

// Record loan
export const recordLoan = async (data: {
    borrower_address: string;
    loan_id_onchain: number;
    amount: number;
    interest_amount: number;
    start_time: string;
    due_date: string;
}): Promise<any> => {
    const response = await apiClient.post('/loans/record', data);
    return response.data;
};

// Record repayment
export const recordRepayment = async (data: {
    borrower_address: string;
    loan_id: number;
    repaid_at: string;
}): Promise<any> => {
    const response = await apiClient.post('/loans/repayment', data);
    return response.data;
};

// Get platform stats
export const getPlatformStats = async (): Promise<any> => {
    const response = await apiClient.get('/users/stats');
    return response.data;
};

// Get loan stats
export const getLoanStats = async (): Promise<any> => {
    const response = await apiClient.get('/loans/stats');
    return response.data;
};

// Health check
export const healthCheck = async (): Promise<any> => {
    const response = await apiClient.get('/health');
    return response.data;
};

export default apiClient;
