-- SenteChainAI Database Schema
-- PostgreSQL Database Setup

-- Create database (run as postgres superuser)
-- CREATE DATABASE sentechainai;

-- Connect to database
\c sentechainai;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    wallet_address VARCHAR(42) UNIQUE NOT NULL,
    credit_score INTEGER DEFAULT 50 CHECK (credit_score >= 0 AND credit_score <= 100),
    total_loans INTEGER DEFAULT 0,
    successful_repayments INTEGER DEFAULT 0,
    defaulted_loans INTEGER DEFAULT 0,
    total_borrowed BIGINT DEFAULT 0,  -- in USDC cents (10^6)
    total_repaid BIGINT DEFAULT 0,
    has_badge BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loans table
CREATE TABLE IF NOT EXISTS loans (
    id SERIAL PRIMARY KEY,
    borrower_address VARCHAR(42) NOT NULL,
    loan_id_onchain INTEGER NOT NULL,
    amount BIGINT NOT NULL,  -- in USDC cents (10^6)
    interest_amount BIGINT NOT NULL,
    credit_score_at_loan INTEGER,
    start_time TIMESTAMP NOT NULL,
    due_date TIMESTAMP NOT NULL,
    repaid_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_repaid BOOLEAN DEFAULT FALSE,
    is_defaulted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (borrower_address) REFERENCES users(wallet_address) ON DELETE CASCADE
);

-- Credit score history table
CREATE TABLE IF NOT EXISTS credit_score_history (
    id SERIAL PRIMARY KEY,
    wallet_address VARCHAR(42) NOT NULL,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    reason VARCHAR(50),  -- 'initial', 'repayment', 'default', 'ai_update'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_address) REFERENCES users(wallet_address) ON DELETE CASCADE
);

-- Transaction data table (for AI model features)
CREATE TABLE IF NOT EXISTS transaction_data (
    id SERIAL PRIMARY KEY,
    wallet_address VARCHAR(42) UNIQUE NOT NULL,
    transaction_count INTEGER DEFAULT 0,
    avg_transaction_value DECIMAL(18, 6) DEFAULT 0.0,
    total_volume DECIMAL(18, 6) DEFAULT 0.0,
    unique_counterparties INTEGER DEFAULT 0,
    wallet_age_days INTEGER DEFAULT 0,
    defi_interactions INTEGER DEFAULT 0,
    nft_holdings INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_address) REFERENCES users(wallet_address) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_users_wallet ON users(wallet_address);
CREATE INDEX IF NOT EXISTS idx_users_credit_score ON users(credit_score);
CREATE INDEX IF NOT EXISTS idx_loans_borrower ON loans(borrower_address);
CREATE INDEX IF NOT EXISTS idx_loans_active ON loans(is_active);
CREATE INDEX IF NOT EXISTS idx_credit_history_wallet ON credit_score_history(wallet_address);
CREATE INDEX IF NOT EXISTS idx_credit_history_created ON credit_score_history(created_at);
CREATE INDEX IF NOT EXISTS idx_transaction_data_wallet ON transaction_data(wallet_address);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transaction_data_updated_at BEFORE UPDATE ON transaction_data
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some sample data for testing (optional)
-- Sample user
INSERT INTO users (wallet_address, credit_score, created_at) 
VALUES ('0x1234567890123456789012345678901234567890', 75, CURRENT_TIMESTAMP)
ON CONFLICT (wallet_address) DO NOTHING;

-- Sample transaction data
INSERT INTO transaction_data (
    wallet_address, 
    transaction_count, 
    avg_transaction_value, 
    total_volume,
    unique_counterparties,
    wallet_age_days,
    defi_interactions,
    nft_holdings
)
VALUES (
    '0x1234567890123456789012345678901234567890',
    150,
    0.5,
    75.0,
    80,
    400,
    15,
    8
)
ON CONFLICT (wallet_address) DO NOTHING;

-- Create view for user statistics
CREATE OR REPLACE VIEW user_statistics AS
SELECT 
    u.wallet_address,
    u.credit_score,
    u.total_loans,
    u.successful_repayments,
    u.defaulted_loans,
    u.total_borrowed,
    u.total_repaid,
    u.has_badge,
    CASE 
        WHEN u.total_loans > 0 THEN (u.successful_repayments::DECIMAL / u.total_loans * 100)
        ELSE 0 
    END AS repayment_rate,
    COUNT(l.id) FILTER (WHERE l.is_active = TRUE) AS active_loans_count,
    u.created_at,
    u.updated_at
FROM users u
LEFT JOIN loans l ON u.wallet_address = l.borrower_address
GROUP BY u.wallet_address;

-- Create view for platform statistics
CREATE OR REPLACE VIEW platform_statistics AS
SELECT 
    COUNT(DISTINCT u.wallet_address) AS total_users,
    COUNT(DISTINCT CASE WHEN u.total_loans > 0 THEN u.wallet_address END) AS users_with_loans,
    COUNT(DISTINCT CASE WHEN u.has_badge = TRUE THEN u.wallet_address END) AS users_with_badges,
    COALESCE(AVG(u.credit_score), 0) AS average_credit_score,
    COUNT(l.id) AS total_loans,
    COUNT(l.id) FILTER (WHERE l.is_active = TRUE) AS active_loans,
    COUNT(l.id) FILTER (WHERE l.is_repaid = TRUE) AS repaid_loans,
    COUNT(l.id) FILTER (WHERE l.is_defaulted = TRUE) AS defaulted_loans,
    COALESCE(SUM(l.amount), 0) AS total_borrowed,
    COALESCE(SUM(CASE WHEN l.is_repaid THEN l.amount + l.interest_amount ELSE 0 END), 0) AS total_repaid
FROM users u
LEFT JOIN loans l ON u.wallet_address = l.borrower_address;

-- Grant permissions (adjust as needed for your user)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_db_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_db_user;

COMMENT ON TABLE users IS 'Stores user profiles and credit scores';
COMMENT ON TABLE loans IS 'Stores loan records from smart contracts';
COMMENT ON TABLE credit_score_history IS 'Tracks credit score changes over time';
COMMENT ON TABLE transaction_data IS 'Stores on-chain transaction data for AI model';
COMMENT ON VIEW user_statistics IS 'Aggregated user statistics with calculated metrics';
COMMENT ON VIEW platform_statistics IS 'Overall platform statistics';

-- Success message
SELECT 'Database schema created successfully!' AS message;
