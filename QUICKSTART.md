# 🎯 Quick Start Guide

Get SenteChainAI running in 10 minutes!

## Prerequisites

Install these first:
- [Node.js 18+](https://nodejs.org/)
- [Python 3.10+](https://www.python.org/)
- [PostgreSQL 14+](https://www.postgresql.org/)

## 🚀 Fast Setup

### 1. Get Test ETH
Visit: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

### 2. Run Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Configure Environment

**contracts/.env:**
```bash
PRIVATE_KEY=your_wallet_private_key
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
```

**backend/.env:**
```bash
DATABASE_URL=postgresql://postgres:password@localhost:5432/sentechainai
```

**frontend/.env.local:**
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=get_from_walletconnect
```

### 4. Setup Database
```bash
sudo -u postgres psql
CREATE DATABASE sentechainai;
\q

sudo -u postgres psql -d sentechainai -f database/schema.sql
```

### 5. Deploy Contracts
```bash
cd contracts
npx hardhat run scripts/deploy.js --network baseSepolia
```

**Copy the deployed addresses!**

### 6. Update Frontend Config
Add contract addresses to `frontend/.env.local`:
```bash
NEXT_PUBLIC_CREDIT_REGISTRY_ADDRESS=0x...
NEXT_PUBLIC_LENDING_POOL_ADDRESS=0x...
NEXT_PUBLIC_SENTE_BADGE_ADDRESS=0x...
```

### 7. Start Services

**Terminal 1 - Backend:**
```bash
cd backend
source venv/bin/activate
uvicorn app:app --reload
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

### 8. Test It Out! 🎉

1. Open http://localhost:3000
2. Connect your wallet
3. Get your credit score
4. Try borrowing (you'll need USDC - use faucet or deploy mock)

## 📚 Full Documentation

- [README.md](README.md) - Complete overview
- [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment
- [database/README.md](database/README.md) - Database setup

## 🆘 Troubleshooting

**"Cannot connect to database"**
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Verify DATABASE_URL in backend/.env

**"Contract deployment failed"**
- Check you have Base Sepolia ETH
- Verify PRIVATE_KEY is correct
- Ensure RPC_URL is accessible

**"Module not found"**
- Run `npm install` in contracts and frontend
- Run `pip install -r requirements.txt` in backend

**"Wallet won't connect"**
- Get WalletConnect Project ID from cloud.walletconnect.com
- Add it to NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID
- Make sure you're on Base Sepolia network in MetaMask

## 🎥 Demo Flow

1. **Connect Wallet** → MetaMask opens
2. **View Score** → AI analyzes and shows credit score
3. **Deposit USDC** → (As lender) Add liquidity to pool
4. **Request Loan** → Smart contract approves based on score
5. **Repay Loan** → Complete cycle and improve score
6. **Earn Badge** → Get SenteBadge NFT after 3 repayments

## 💡 Tips

- Use Base Sepolia testnet for development
- Keep private keys secure (never commit!)
- Test thoroughly before mainnet
- Read the smart contract code
- Check BaseScan for transaction details

## 🏆 Hackathon Tips

- Focus on demo flow first
- Document your process
- Create a compelling pitch
- Show the AI in action
- Highlight the innovation
- Be ready for questions

Good luck! 🚀
