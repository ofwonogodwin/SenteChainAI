"""
Database configuration and models
"""

from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Boolean, BigInteger
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

# Database URL
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost:5432/sentechainai")

# Create engine
engine = create_engine(DATABASE_URL, echo=True)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()

# Database Models
class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    wallet_address = Column(String, unique=True, index=True, nullable=False)
    credit_score = Column(Integer, default=50)
    total_loans = Column(Integer, default=0)
    successful_repayments = Column(Integer, default=0)
    defaulted_loans = Column(Integer, default=0)
    total_borrowed = Column(BigInteger, default=0)  # in USDC (6 decimals)
    total_repaid = Column(BigInteger, default=0)
    has_badge = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Loan(Base):
    __tablename__ = "loans"
    
    id = Column(Integer, primary_key=True, index=True)
    borrower_address = Column(String, index=True, nullable=False)
    loan_id_onchain = Column(Integer, nullable=False)  # ID from smart contract
    amount = Column(BigInteger, nullable=False)  # Principal in USDC (6 decimals)
    interest_amount = Column(BigInteger, nullable=False)
    credit_score_at_loan = Column(Integer)
    start_time = Column(DateTime, nullable=False)
    due_date = Column(DateTime, nullable=False)
    repaid_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    is_repaid = Column(Boolean, default=False)
    is_defaulted = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class CreditScoreHistory(Base):
    __tablename__ = "credit_score_history"
    
    id = Column(Integer, primary_key=True, index=True)
    wallet_address = Column(String, index=True, nullable=False)
    score = Column(Integer, nullable=False)
    reason = Column(String, nullable=True)  # "initial", "repayment", "default", "ai_update"
    created_at = Column(DateTime, default=datetime.utcnow)

class TransactionData(Base):
    __tablename__ = "transaction_data"
    
    id = Column(Integer, primary_key=True, index=True)
    wallet_address = Column(String, index=True, nullable=False)
    transaction_count = Column(Integer, default=0)
    avg_transaction_value = Column(Float, default=0.0)
    total_volume = Column(Float, default=0.0)
    unique_counterparties = Column(Integer, default=0)
    wallet_age_days = Column(Integer, default=0)
    defi_interactions = Column(Integer, default=0)
    nft_holdings = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
