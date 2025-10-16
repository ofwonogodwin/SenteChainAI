#!/bin/bash

# SenteChainAI - Complete Run Guide
# Follow these steps to get everything running

set -e

echo "🚀 SenteChainAI - Run Guide"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Install Dependencies
echo -e "${BLUE}Step 1: Installing Dependencies...${NC}"
echo ""

echo "📦 Installing contracts dependencies..."
cd contracts
npm install
echo -e "${GREEN}✓ Contracts dependencies installed${NC}"
echo ""

echo "📦 Installing frontend dependencies..."
cd ../frontend
npm install
echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
echo ""

echo "📦 Installing backend dependencies..."
cd ../backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo -e "${GREEN}✓ Backend dependencies installed${NC}"
echo ""
cd ..

# Step 2: Setup Environment Files
echo -e "${BLUE}Step 2: Setting Up Environment Files...${NC}"
echo ""

if [ ! -f "contracts/.env" ]; then
    cp contracts/.env.example contracts/.env
    echo -e "${YELLOW}⚠️  Created contracts/.env - Please edit with your private key${NC}"
else
    echo -e "${GREEN}✓ contracts/.env exists${NC}"
fi

if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    echo -e "${YELLOW}⚠️  Created backend/.env - Please edit with your database URL${NC}"
else
    echo -e "${GREEN}✓ backend/.env exists${NC}"
fi

if [ ! -f "frontend/.env.local" ]; then
    cp frontend/.env.example frontend/.env.local
    echo -e "${YELLOW}⚠️  Created frontend/.env.local - Please edit with contract addresses${NC}"
else
    echo -e "${GREEN}✓ frontend/.env.local exists${NC}"
fi

echo ""

# Step 3: Database Setup
echo -e "${BLUE}Step 3: Database Setup${NC}"
echo ""
echo "Run these commands to set up PostgreSQL:"
echo ""
echo -e "${YELLOW}sudo -u postgres psql${NC}"
echo -e "${YELLOW}CREATE DATABASE sentechainai;${NC}"
echo -e "${YELLOW}\\q${NC}"
echo -e "${YELLOW}sudo -u postgres psql -d sentechainai -f database/schema.sql${NC}"
echo ""
read -p "Press Enter when database is ready..."

# Step 4: Train AI Model
echo ""
echo -e "${BLUE}Step 4: Training AI Model...${NC}"
echo ""
cd backend
source venv/bin/activate
python train_model.py
echo -e "${GREEN}✓ AI Model trained${NC}"
cd ..

# Step 5: Compile Contracts
echo ""
echo -e "${BLUE}Step 5: Compiling Smart Contracts...${NC}"
echo ""
cd contracts
npx hardhat compile
echo -e "${GREEN}✓ Contracts compiled${NC}"
cd ..

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1️⃣  Deploy Contracts (if not already done):"
echo "   cd contracts"
echo "   npx hardhat run scripts/deploy.js --network baseSepolia"
echo ""
echo "2️⃣  Start Backend (Terminal 1):"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   uvicorn app:app --reload"
echo ""
echo "3️⃣  Start Frontend (Terminal 2):"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "4️⃣  Open Browser:"
echo "   http://localhost:3000"
echo ""
echo -e "${GREEN}Happy hacking! 🚀${NC}"
