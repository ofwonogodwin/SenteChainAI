"""
User API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from database import get_db, User

router = APIRouter()

class UserProfile(BaseModel):
    wallet_address: str
    credit_score: int
    total_loans: int
    successful_repayments: int
    defaulted_loans: int
    total_borrowed: int  # in cents (USDC * 10^6)
    total_repaid: int
    has_badge: bool
    repayment_rate: Optional[float] = None

@router.get("/user/{wallet_address}", response_model=UserProfile)
async def get_user_profile(
    wallet_address: str,
    db: Session = Depends(get_db)
):
    """Get user profile and statistics"""
    wallet_address = wallet_address.lower()
    
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Calculate repayment rate
    repayment_rate = None
    if user.total_loans > 0:
        repayment_rate = (user.successful_repayments / user.total_loans) * 100
    
    return UserProfile(
        wallet_address=user.wallet_address,
        credit_score=user.credit_score,
        total_loans=user.total_loans,
        successful_repayments=user.successful_repayments,
        defaulted_loans=user.defaulted_loans,
        total_borrowed=user.total_borrowed,
        total_repaid=user.total_repaid,
        has_badge=user.has_badge,
        repayment_rate=repayment_rate
    )

@router.get("/users/stats")
async def get_platform_stats(db: Session = Depends(get_db)):
    """Get overall platform statistics"""
    
    total_users = db.query(User).count()
    users_with_loans = db.query(User).filter(User.total_loans > 0).count()
    users_with_badges = db.query(User).filter(User.has_badge == True).count()
    
    # Calculate average credit score
    from sqlalchemy import func
    avg_score = db.query(func.avg(User.credit_score)).scalar() or 0
    
    return {
        "total_users": total_users,
        "users_with_loans": users_with_loans,
        "users_with_badges": users_with_badges,
        "average_credit_score": round(avg_score, 2),
        "platform_health": "operational"
    }
