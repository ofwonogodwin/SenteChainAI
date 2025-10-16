# SenteChainAI 💸🤖

A decentralized micro-lending platform built on **Base blockchain** with **AI-driven credit scoring**.

## 🔹 Overview

SenteChainAI revolutionizes micro-lending by combining:
- **AI-powered credit scoring** (SenteScore) based on transaction patterns
- **Smart contracts** for transparent lending and borrowing
- **Soulbound NFTs** as reputation tokens for good borrowers
- **Base blockchain** for fast, low-cost transactions

## 🏗️ Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Frontend  │────▶│  AI Backend  │────▶│  Database   │
│  (Next.js)  │     │   (FastAPI)  │     │ (PostgreSQL)│
└──────┬──────┘     └──────────────┘     └─────────────┘
       │
       │ ethers.js/wagmi
       │
       ▼
┌─────────────────────────────────────────────────────┐
│          Base Blockchain (Smart Contracts)          │
│  • CreditScoreRegistry  • LendingPool  • SenteBadge │
└─────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm/yarn
- Python 3.10+
- PostgreSQL 14+
- MetaMask wallet
- Base testnet ETH (get from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet))

### 1. Clone and Install

```bash
git clone <repository-url>
cd SenteChainAI
```

### 2. Setup Smart Contracts

```bash
cd contracts
npm install
cp .env.example .env
# Add your private key and Alchemy API key to .env
npx hardhat compile
npx hardhat run scripts/deploy.js --network baseSepolia
```

### 3. Setup Backend (AI Service)

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Configure DATABASE_URL in .env
python train_model.py  # Train the AI model
uvicorn app:app --reload --port 8000
```

### 4. Setup Database

```bash
cd database
psql -U postgres -f schema.sql
```

### 5. Setup Frontend

```bash
cd frontend
npm install
cp .env.example .env.local
# Add contract addresses and API URLs to .env.local
npm run dev
```

Visit `http://localhost:3000` 🎉

## 📁 Project Structure

```
sentechainai/
├── frontend/              # Next.js 15 app
│   ├── app/              # App router pages
│   ├── components/       # React components
│   ├── lib/             # Utilities and Web3 config
│   └── public/          # Static assets
├── contracts/            # Solidity smart contracts
│   ├── contracts/       # .sol files
│   ├── scripts/         # Deployment scripts
│   ├── test/           # Contract tests
│   └── hardhat.config.js
├── backend/             # FastAPI AI service
│   ├── app.py          # Main API
│   ├── routes/         # API endpoints
│   ├── models/         # AI models
│   └── requirements.txt
├── database/            # PostgreSQL schemas
│   ├── schema.sql
│   └── migrations/
└── README.md
```

## 🧠 Key Features

### For Borrowers
- ✅ Connect wallet and view SenteScore (0-100)
- ✅ Request loans based on credit score
- ✅ Transparent repayment tracking
- ✅ Earn SenteBadge NFTs for good repayment history

### For Lenders
- ✅ Deposit USDC into lending pools
- ✅ Earn interest on deposits
- ✅ View pool statistics and utilization
- ✅ Withdraw funds anytime

### AI Credit Scoring
- 📊 Analyzes transaction history
- 🎯 Generates SenteScore (0-100)
- 🔄 Updates dynamically based on repayment behavior
- 🤖 Uses RandomForest ML model

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Next.js 15, TailwindCSS, TypeScript, ethers.js, wagmi |
| Backend | FastAPI, Python, scikit-learn, PostgreSQL |
| Blockchain | Solidity, Hardhat, OpenZeppelin, Base Sepolia |
| Database | PostgreSQL 14+ |
| Deployment | Vercel (Frontend), Render (Backend), Alchemy RPC |

## 📜 Smart Contracts

### CreditScoreRegistry.sol
Stores and manages AI-generated credit scores on-chain.

### LendingPool.sol
Handles:
- USDC deposits from lenders
- Loan requests and approvals
- Automatic repayments
- Interest calculations

### SenteBadge.sol
Mints non-transferable (Soulbound) NFTs to borrowers with good repayment history.

## 🔐 Security Features

- ✅ OpenZeppelin audited contracts
- ✅ ReentrancyGuard protection
- ✅ AccessControl for admin functions
- ✅ Rate limiting on API endpoints
- ✅ Input validation and sanitization

## 🌐 Deployment

### Frontend (Vercel)
```bash
cd frontend
vercel --prod
```

### Backend (Render/Railway)
```bash
cd backend
# Connect to Render/Railway and deploy
```

### Smart Contracts (Base Sepolia)
```bash
cd contracts
npx hardhat run scripts/deploy.js --network baseSepolia
```

## 🧪 Testing

### Smart Contracts
```bash
cd contracts
npx hardhat test
npx hardhat coverage
```

### Backend
```bash
cd backend
pytest tests/ -v
```

### Frontend
```bash
cd frontend
npm test
npm run e2e
```

## 📊 API Endpoints

### Backend API (Port 8000)

- `POST /api/score` - Get AI credit score
- `GET /api/user/{address}` - Get user profile
- `GET /api/loans/{address}` - Get user loan history
- `POST /api/repayment` - Record repayment

## 🎯 Demo Workflow

1. **Connect Wallet** → User connects MetaMask to Base Sepolia
2. **View Score** → AI analyzes wallet and generates SenteScore
3. **Request Loan** → Smart contract checks score and approves if eligible
4. **Receive Funds** → USDC sent directly to borrower's wallet
5. **Repay Loan** → Borrower repays with interest
6. **Earn Badge** → Mint SenteBadge NFT as reputation proof

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

MIT License - see LICENSE file for details

## 🔗 Links

- [Base Documentation](https://docs.base.org)
- [Hardhat Docs](https://hardhat.org/docs)
- [Next.js Docs](https://nextjs.org/docs)
- [FastAPI Docs](https://fastapi.tiangolo.com)

## 👥 Team

Built for hackathon by passionate blockchain developers 🚀

---

**Made with ❤️ for the future of DeFi**
