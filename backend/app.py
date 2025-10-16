"""
SenteChainAI FastAPI Backend
Main application entry point
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import uvicorn
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import routes
from routes import score, user, loan, health

# Import database
from database import engine, Base

# Create database tables
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 Starting SenteChainAI Backend...")
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created")
    yield
    # Shutdown
    print("👋 Shutting down SenteChainAI Backend...")

# Initialize FastAPI app
app = FastAPI(
    title="SenteChainAI API",
    description="AI-powered credit scoring for decentralized lending",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/api", tags=["Health"])
app.include_router(score.router, prefix="/api", tags=["Credit Score"])
app.include_router(user.router, prefix="/api", tags=["User"])
app.include_router(loan.router, prefix="/api", tags=["Loan"])

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "Welcome to SenteChainAI API 💸🤖",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "operational"
    }

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "error": str(exc)
        }
    )

# Run application
if __name__ == "__main__":
    host = os.getenv("API_HOST", "0.0.0.0")
    port = int(os.getenv("API_PORT", 8000))
    reload = os.getenv("API_RELOAD", "True").lower() == "true"
    
    uvicorn.run(
        "app:app",
        host=host,
        port=port,
        reload=reload,
        log_level="info"
    )
