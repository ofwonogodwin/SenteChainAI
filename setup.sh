#!/bin/bash

# SenteChainAI Full Setup Script
# This script sets up the entire project

set -e  # Exit on error

echo "🚀 Setting up SenteChainAI..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python 3.10+ first."
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL client not found. Please install PostgreSQL."
    echo "   Installation will continue, but you'll need to set up the database manually."
fi

echo -e "${GREEN}✓ Prerequisites checked${NC}"
echo ""

# Setup Smart Contracts
echo -e "${YELLOW}📜 Setting up smart contracts...${NC}"
cd contracts
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "⚠️  Please edit contracts/.env with your private key and RPC URL"
fi
npm install
npx hardhat compile
echo -e "${GREEN}✓ Smart contracts setup complete${NC}"
echo ""
cd ..

# Setup Backend
echo -e "${YELLOW}🤖 Setting up backend...${NC}"
cd backend
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your database credentials"
fi
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python train_model.py
echo -e "${GREEN}✓ Backend setup complete${NC}"
echo ""
cd ..

# Setup Frontend
echo -e "${YELLOW}⚛️  Setting up frontend...${NC}"
cd frontend
if [ ! -f ".env.local" ]; then
    cp .env.example .env.local
    echo "⚠️  Please edit frontend/.env.local with your contract addresses"
fi
npm install
echo -e "${GREEN}✓ Frontend setup complete${NC}"
echo ""
cd ..

# Setup Database
echo -e "${YELLOW}🗄️  Database setup...${NC}"
if command -v psql &> /dev/null; then
    echo "Run the following commands to set up the database:"
    echo "  sudo -u postgres psql"
    echo "  CREATE DATABASE sentechainai;"
    echo "  \\q"
    echo "  sudo -u postgres psql -d sentechainai -f database/schema.sql"
else
    echo "⚠️  PostgreSQL not found. Please set up manually using database/schema.sql"
fi
echo ""

# Final instructions
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Configure environment variables:"
echo "   - contracts/.env (add your private key)"
echo "   - backend/.env (add database URL)"
echo "   - frontend/.env.local (add contract addresses)"
echo ""
echo "2. Set up PostgreSQL database:"
echo "   See database/README.md for instructions"
echo ""
echo "3. Deploy smart contracts:"
echo "   cd contracts"
echo "   npx hardhat run scripts/deploy.js --network baseSepolia"
echo ""
echo "4. Start backend:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   uvicorn app:app --reload"
echo ""
echo "5. Start frontend:"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "📚 For detailed instructions, see README.md"
echo ""
echo -e "${GREEN}Happy hacking! 🚀${NC}"
