"""
Credit Score API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from typing import Optional
import random

from database import get_db, User, CreditScoreHistory, TransactionData
from ai_model import credit_model

router = APIRouter()

class ScoreRequest(BaseModel):
    wallet_address: str = Field(..., description="Ethereum wallet address")
    transaction_count: Optional[int] = Field(default=None, ge=0)
    avg_transaction_value: Optional[float] = Field(default=None, ge=0)
    total_volume: Optional[float] = Field(default=None, ge=0)
    unique_counterparties: Optional[int] = Field(default=None, ge=0)
    wallet_age_days: Optional[int] = Field(default=None, ge=0)
    defi_interactions: Optional[int] = Field(default=None, ge=0)
    nft_holdings: Optional[int] = Field(default=None, ge=0)

class ScoreResponse(BaseModel):
    wallet_address: str
    score: int
    tier: str
    eligible_for_loan: bool
    max_loan_amount: float
    interest_rate: float
    message: str

@router.post("/score", response_model=ScoreResponse)
async def get_credit_score(
    request: ScoreRequest,
    db: Session = Depends(get_db)
):
    """
    Calculate AI credit score for a wallet address
    
    Returns:
    - score: Credit score 0-100
    - tier: Bronze, Silver, Gold, or Platinum
    - eligible_for_loan: Boolean indicating loan eligibility
    - max_loan_amount: Maximum loan amount in USDC
    - interest_rate: Interest rate percentage
    """
    
    wallet_address = request.wallet_address.lower()
    
    # Check if user exists
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    
    # If no transaction data provided, generate synthetic data for demo
    if request.transaction_count is None:
        # Generate random but reasonable transaction data
        features = _generate_demo_features(wallet_address)
    else:
        features = {
            'transaction_count': request.transaction_count,
            'avg_transaction_value': request.avg_transaction_value or 0,
            'total_volume': request.total_volume or 0,
            'unique_counterparties': request.unique_counterparties or 0,
            'wallet_age_days': request.wallet_age_days or 0,
            'defi_interactions': request.defi_interactions or 0,
            'nft_holdings': request.nft_holdings or 0
        }
    
    # Save/update transaction data
    tx_data = db.query(TransactionData).filter(
        TransactionData.wallet_address == wallet_address
    ).first()
    
    if tx_data:
        tx_data.transaction_count = features['transaction_count']
        tx_data.avg_transaction_value = features['avg_transaction_value']
        tx_data.total_volume = features['total_volume']
        tx_data.unique_counterparties = features['unique_counterparties']
        tx_data.wallet_age_days = features['wallet_age_days']
        tx_data.defi_interactions = features['defi_interactions']
        tx_data.nft_holdings = features['nft_holdings']
    else:
        tx_data = TransactionData(
            wallet_address=wallet_address,
            **features
        )
        db.add(tx_data)
    
    # Predict credit score using AI model
    try:
        credit_model.load()
        score = credit_model.predict_score(features)
    except Exception as e:
        # Fallback to simple scoring if model not available
        print(f"Model error: {e}")
        score = _simple_score_calculation(features)
    
    # Update or create user
    if user:
        user.credit_score = score
    else:
        user = User(
            wallet_address=wallet_address,
            credit_score=score
        )
        db.add(user)
    
    # Save score history
    score_history = CreditScoreHistory(
        wallet_address=wallet_address,
        score=score,
        reason="ai_update"
    )
    db.add(score_history)
    
    db.commit()
    
    # Determine tier
    tier = _get_tier(score)
    
    # Calculate loan eligibility and terms
    eligible = score >= 60
    max_loan = _calculate_max_loan(score)
    interest_rate = _calculate_interest_rate(score)
    
    # Generate message
    if eligible:
        message = f"Congratulations! You have {tier} tier credit and are eligible for loans up to ${max_loan:,.0f} USDC"
    else:
        message = f"Your current score is {score}/100. Build your credit history to become eligible for loans (minimum score: 60)"
    
    return ScoreResponse(
        wallet_address=wallet_address,
        score=score,
        tier=tier,
        eligible_for_loan=eligible,
        max_loan_amount=max_loan,
        interest_rate=interest_rate,
        message=message
    )

@router.get("/score/{wallet_address}", response_model=ScoreResponse)
async def get_existing_score(
    wallet_address: str,
    db: Session = Depends(get_db)
):
    """Get existing credit score for a wallet"""
    wallet_address = wallet_address.lower()
    
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    score = user.credit_score
    tier = _get_tier(score)
    eligible = score >= 60
    max_loan = _calculate_max_loan(score)
    interest_rate = _calculate_interest_rate(score)
    
    message = f"Your current SenteScore is {score}/100 ({tier} tier)"
    
    return ScoreResponse(
        wallet_address=wallet_address,
        score=score,
        tier=tier,
        eligible_for_loan=eligible,
        max_loan_amount=max_loan,
        interest_rate=interest_rate,
        message=message
    )

@router.get("/score/history/{wallet_address}")
async def get_score_history(
    wallet_address: str,
    db: Session = Depends(get_db)
):
    """Get credit score history for a wallet"""
    wallet_address = wallet_address.lower()
    
    history = db.query(CreditScoreHistory).filter(
        CreditScoreHistory.wallet_address == wallet_address
    ).order_by(CreditScoreHistory.created_at.desc()).limit(10).all()
    
    return {
        "wallet_address": wallet_address,
        "history": [
            {
                "score": h.score,
                "reason": h.reason,
                "timestamp": h.created_at.isoformat()
            }
            for h in history
        ]
    }

# Helper functions
def _generate_demo_features(wallet_address: str) -> dict:
    """Generate demo transaction features based on wallet address"""
    # Use wallet address as seed for consistent results
    seed = int(wallet_address[-8:], 16) % 1000
    random.seed(seed)
    
    # Generate reasonable random features
    return {
        'transaction_count': random.randint(10, 300),
        'avg_transaction_value': round(random.uniform(0.05, 1.5), 4),
        'total_volume': round(random.uniform(5, 200), 2),
        'unique_counterparties': random.randint(5, 150),
        'wallet_age_days': random.randint(30, 800),
        'defi_interactions': random.randint(0, 40),
        'nft_holdings': random.randint(0, 25)
    }

def _simple_score_calculation(features: dict) -> int:
    """Simple fallback scoring if AI model unavailable"""
    score = 50  # Base score
    
    # Add points for various factors
    if features['transaction_count'] > 100:
        score += 15
    elif features['transaction_count'] > 50:
        score += 10
    elif features['transaction_count'] > 20:
        score += 5
    
    if features['wallet_age_days'] > 365:
        score += 10
    elif features['wallet_age_days'] > 180:
        score += 5
    
    if features['defi_interactions'] > 10:
        score += 10
    elif features['defi_interactions'] > 5:
        score += 5
    
    if features['unique_counterparties'] > 50:
        score += 10
    elif features['unique_counterparties'] > 20:
        score += 5
    
    return min(score, 100)

def _get_tier(score: int) -> str:
    """Get credit tier based on score"""
    if score >= 90:
        return "Platinum"
    elif score >= 80:
        return "Gold"
    elif score >= 70:
        return "Silver"
    elif score >= 60:
        return "Bronze"
    else:
        return "Unrated"

def _calculate_max_loan(score: int) -> float:
    """Calculate maximum loan amount based on score"""
    if score >= 90:
        return 1000.0
    elif score >= 80:
        return 750.0
    elif score >= 70:
        return 500.0
    elif score >= 60:
        return 250.0
    else:
        return 0.0

def _calculate_interest_rate(score: int) -> float:
    """Calculate interest rate based on score"""
    if score >= 91:
        return 5.0
    elif score >= 81:
        return 6.0
    elif score >= 71:
        return 8.0
    elif score >= 60:
        return 10.0
    else:
        return 15.0
