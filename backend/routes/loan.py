"""
Loan API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

from database import get_db, Loan, User, CreditScoreHistory

router = APIRouter()

class LoanInfo(BaseModel):
    id: int
    borrower_address: str
    loan_id_onchain: int
    amount: int  # USDC in cents (10^6)
    interest_amount: int
    credit_score_at_loan: Optional[int]
    start_time: datetime
    due_date: datetime
    repaid_at: Optional[datetime]
    is_active: bool
    is_repaid: bool
    is_defaulted: bool

class LoanRequest(BaseModel):
    borrower_address: str
    loan_id_onchain: int
    amount: int
    interest_amount: int
    start_time: datetime
    due_date: datetime

class RepaymentRequest(BaseModel):
    borrower_address: str
    loan_id: int
    repaid_at: datetime

@router.get("/loans/{wallet_address}", response_model=List[LoanInfo])
async def get_user_loans(
    wallet_address: str,
    active_only: bool = False,
    db: Session = Depends(get_db)
):
    """Get all loans for a wallet address"""
    wallet_address = wallet_address.lower()
    
    query = db.query(Loan).filter(Loan.borrower_address == wallet_address)
    
    if active_only:
        query = query.filter(Loan.is_active == True)
    
    loans = query.order_by(Loan.created_at.desc()).all()
    
    return [
        LoanInfo(
            id=loan.id,
            borrower_address=loan.borrower_address,
            loan_id_onchain=loan.loan_id_onchain,
            amount=loan.amount,
            interest_amount=loan.interest_amount,
            credit_score_at_loan=loan.credit_score_at_loan,
            start_time=loan.start_time,
            due_date=loan.due_date,
            repaid_at=loan.repaid_at,
            is_active=loan.is_active,
            is_repaid=loan.is_repaid,
            is_defaulted=loan.is_defaulted
        )
        for loan in loans
    ]

@router.post("/loans/record")
async def record_loan(
    request: LoanRequest,
    db: Session = Depends(get_db)
):
    """Record a new loan (called by frontend after blockchain tx)"""
    wallet_address = request.borrower_address.lower()
    
    # Get user's current credit score
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Create loan record
    loan = Loan(
        borrower_address=wallet_address,
        loan_id_onchain=request.loan_id_onchain,
        amount=request.amount,
        interest_amount=request.interest_amount,
        credit_score_at_loan=user.credit_score,
        start_time=request.start_time,
        due_date=request.due_date,
        is_active=True,
        is_repaid=False
    )
    
    db.add(loan)
    
    # Update user statistics
    user.total_loans += 1
    user.total_borrowed += request.amount
    
    db.commit()
    db.refresh(loan)
    
    return {
        "message": "Loan recorded successfully",
        "loan_id": loan.id,
        "onchain_id": loan.loan_id_onchain
    }

@router.post("/loans/repayment")
async def record_repayment(
    request: RepaymentRequest,
    db: Session = Depends(get_db)
):
    """Record a loan repayment (called by frontend after blockchain tx)"""
    wallet_address = request.borrower_address.lower()
    
    # Find the loan
    loan = db.query(Loan).filter(
        Loan.borrower_address == wallet_address,
        Loan.id == request.loan_id
    ).first()
    
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    if loan.is_repaid:
        raise HTTPException(status_code=400, detail="Loan already repaid")
    
    # Update loan
    loan.is_active = False
    loan.is_repaid = True
    loan.repaid_at = request.repaid_at
    
    # Update user statistics
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    if user:
        user.successful_repayments += 1
        total_repayment = loan.amount + loan.interest_amount
        user.total_repaid += total_repayment
        
        # Improve credit score
        old_score = user.credit_score
        new_score = min(old_score + 2, 100)  # Improve by 2 points
        user.credit_score = new_score
        
        # Record score change
        score_history = CreditScoreHistory(
            wallet_address=wallet_address,
            score=new_score,
            reason="repayment"
        )
        db.add(score_history)
    
    db.commit()
    
    return {
        "message": "Repayment recorded successfully",
        "new_credit_score": user.credit_score if user else None
    }

@router.post("/loans/default")
async def record_default(
    borrower_address: str,
    loan_id: int,
    db: Session = Depends(get_db)
):
    """Record a loan default"""
    wallet_address = borrower_address.lower()
    
    loan = db.query(Loan).filter(
        Loan.borrower_address == wallet_address,
        Loan.id == loan_id
    ).first()
    
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    # Update loan
    loan.is_active = False
    loan.is_defaulted = True
    
    # Update user statistics
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    if user:
        user.defaulted_loans += 1
        
        # Decrease credit score
        old_score = user.credit_score
        new_score = max(old_score - 15, 0)  # Penalty of 15 points
        user.credit_score = new_score
        
        # Record score change
        score_history = CreditScoreHistory(
            wallet_address=wallet_address,
            score=new_score,
            reason="default"
        )
        db.add(score_history)
    
    db.commit()
    
    return {
        "message": "Default recorded",
        "new_credit_score": user.credit_score if user else None
    }

@router.get("/loans/stats")
async def get_loan_stats(db: Session = Depends(get_db)):
    """Get overall loan statistics"""
    from sqlalchemy import func
    
    total_loans = db.query(Loan).count()
    active_loans = db.query(Loan).filter(Loan.is_active == True).count()
    repaid_loans = db.query(Loan).filter(Loan.is_repaid == True).count()
    defaulted_loans = db.query(Loan).filter(Loan.is_defaulted == True).count()
    
    total_borrowed = db.query(func.sum(Loan.amount)).scalar() or 0
    total_repaid = db.query(func.sum(Loan.amount + Loan.interest_amount)).filter(
        Loan.is_repaid == True
    ).scalar() or 0
    
    return {
        "total_loans": total_loans,
        "active_loans": active_loans,
        "repaid_loans": repaid_loans,
        "defaulted_loans": defaulted_loans,
        "total_borrowed_usdc": total_borrowed / 1_000_000,  # Convert to USDC
        "total_repaid_usdc": total_repaid / 1_000_000,
        "repayment_rate": (repaid_loans / total_loans * 100) if total_loans > 0 else 0
    }
