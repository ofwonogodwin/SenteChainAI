"""
Health check endpoint
"""

from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "SenteChainAI API"
    }

@router.get("/version")
async def version():
    """Get API version"""
    return {
        "version": "1.0.0",
        "name": "SenteChainAI API"
    }
