# 🏃 How to Run SenteChainAI

Complete guide to get SenteChainAI running on your machine.

## 📋 Prerequisites Checklist

Before starting, make sure you have:
- [ ] Node.js 18+ installed (`node --version`)
- [ ] Python 3.10+ installed (`python3 --version`)
- [ ] PostgreSQL 14+ installed (`psql --version`)
- [ ] Git installed
- [ ] A code editor (VS Code recommended)
- [ ] MetaMask wallet extension

## 🚀 Quick Start (10 Minutes)

### Option 1: Automated Setup

```bash
# Make script executable
chmod +x run-setup.sh

# Run setup (installs everything)
./run-setup.sh
```

### Option 2: Manual Setup

Follow these steps:

---

## 📦 Step 1: Install Dependencies

### Install Smart Contract Dependencies
```bash
cd contracts
npm install
```

### Install Frontend Dependencies
```bash
cd ../frontend
npm install
```

### Install Backend Dependencies
```bash
cd ../backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

---

## ⚙️ Step 2: Configure Environment Variables

### Contracts Configuration
```bash
cd contracts
cp .env.example .env
nano .env  # or use your preferred editor
```

Add your details:
```env
PRIVATE_KEY=your_metamask_private_key_here
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=your_basescan_api_key  # Optional, for verification
```

**Get Base Sepolia ETH**: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

### Backend Configuration
```bash
cd ../backend
cp .env.example .env
nano .env
```

Update:
```env
DATABASE_URL=postgresql://postgres:password@localhost:5432/sentechainai
API_HOST=0.0.0.0
API_PORT=8000
CORS_ORIGINS=http://localhost:3000
```

### Frontend Configuration
```bash
cd ../frontend
cp .env.example .env.local
nano .env.local
```

Update:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id_from_walletconnect
```

**Get WalletConnect ID**: https://cloud.walletconnect.com

---

## 🗄️ Step 3: Setup Database

### Create PostgreSQL Database
```bash
# Login to PostgreSQL
sudo -u postgres psql

# In PostgreSQL prompt:
CREATE DATABASE sentechainai;
CREATE USER sente_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE sentechainai TO sente_user;
\q
```

### Run Database Schema
```bash
# From project root
sudo -u postgres psql -d sentechainai -f database/schema.sql
```

### Verify Database
```bash
psql -U postgres -d sentechainai -c "SELECT * FROM platform_statistics;"
```

---

## 🤖 Step 4: Train AI Model

```bash
cd backend
source venv/bin/activate
python train_model.py
```

You should see:
```
🤖 Training SenteChainAI Credit Scoring Model...
📊 Generating synthetic training data...
   Generated 2000 samples
🧠 Training model...
   Training accuracy: 99%
   Testing accuracy: 98%
✅ Model training complete!
```

---

## 📜 Step 5: Compile & Deploy Smart Contracts

### Compile Contracts
```bash
cd contracts
npx hardhat compile
```

### Run Tests (Optional but Recommended)
```bash
npx hardhat test
```

### Deploy to Base Sepolia
```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

**IMPORTANT**: Save the contract addresses from the output!

### Update Frontend Config
Edit `frontend/.env.local` with your deployed addresses:
```env
NEXT_PUBLIC_CREDIT_REGISTRY_ADDRESS=0x...
NEXT_PUBLIC_LENDING_POOL_ADDRESS=0x...
NEXT_PUBLIC_SENTE_BADGE_ADDRESS=0x...
NEXT_PUBLIC_USDC_ADDRESS=0x...
```

---

## 🎮 Step 6: Run the Application

You'll need **3 terminals** open:

### Terminal 1: Backend API

```bash
cd backend
source venv/bin/activate
uvicorn app:app --reload
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

Test it: http://localhost:8000/docs (FastAPI docs)

### Terminal 2: Frontend

```bash
cd frontend
npm run dev
```

You should see:
```
  ▲ Next.js 15.0.0
  - Local:        http://localhost:3000
  - Ready in 2.5s
```

### Terminal 3: Development Console (Optional)

Keep this open for running commands, checking logs, etc.

---

## 🌐 Step 7: Access the Application

Open your browser and go to: **http://localhost:3000**

You should see the SenteChainAI homepage! 🎉

---

## 🧪 Step 8: Test the Full Flow

### 1. Connect Wallet
- Click "Connect Wallet"
- Select MetaMask
- Approve connection
- Make sure you're on **Base Sepolia** network

### 2. Get Your Credit Score
- Click "View Score" or "Dashboard"
- The AI will analyze your wallet (demo data)
- You'll see your SenteScore (0-100)

### 3. Deposit USDC (As Lender)
```bash
# First, get some test USDC
# Option A: Use the faucet in MockUSDC contract
# Option B: Deploy MockUSDC and mint to yourself
```

Go to "Lend" page and deposit USDC to the pool.

### 4. Request a Loan (As Borrower)
- Go to "Borrow" page
- Enter loan amount
- Click "Request Loan"
- Approve transaction in MetaMask
- Wait for confirmation

### 5. Repay Loan
- View your active loans
- Click "Repay"
- Approve USDC spending
- Confirm repayment transaction
- Your credit score will improve!

### 6. Earn Badge
After 3 successful repayments, you'll automatically receive a SenteBadge NFT! 🏆

---

## 🔍 Monitoring & Debugging

### Check Backend Logs
Terminal 1 shows all API requests and responses

### Check Frontend Console
Open browser DevTools (F12) → Console tab

### Check Blockchain Transactions
Visit BaseScan: https://sepolia.basescan.org
Search for your wallet address or contract addresses

### Check Database
```bash
psql -U postgres -d sentechainai
SELECT * FROM users;
SELECT * FROM loans;
\q
```

---

## 🛠️ Common Commands

### Restart Backend
```bash
# Terminal 1
Ctrl+C  # Stop
uvicorn app:app --reload  # Start
```

### Restart Frontend
```bash
# Terminal 2
Ctrl+C  # Stop
npm run dev  # Start
```

### Rebuild Frontend
```bash
cd frontend
rm -rf .next
npm run dev
```

### Recompile Contracts
```bash
cd contracts
npx hardhat clean
npx hardhat compile
```

### Reset Database
```bash
sudo -u postgres psql -d sentechainai -f database/schema.sql
```

---

## ❌ Troubleshooting

### "Cannot connect to database"
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Start if not running
sudo systemctl start postgresql

# Check connection
psql -U postgres -d sentechainai -c "SELECT 1;"
```

### "Module not found" errors
```bash
# Reinstall dependencies
cd frontend && npm install
cd ../backend && pip install -r requirements.txt
cd ../contracts && npm install
```

### "Contract not deployed"
```bash
# Deploy contracts
cd contracts
npx hardhat run scripts/deploy.js --network baseSepolia

# Update frontend/.env.local with new addresses
```

### "Wallet connection fails"
- Check you have MetaMask installed
- Verify you're on Base Sepolia network
- Get WalletConnect Project ID and add to .env.local
- Clear browser cache and try again

### "Transaction reverted"
- Check you have enough Base Sepolia ETH
- Verify contract addresses are correct
- Check your credit score meets minimum (60)
- Make sure lending pool has liquidity

---

## 📊 Verify Everything Works

Run this checklist:

```bash
# 1. Backend health check
curl http://localhost:8000/api/health

# 2. Get platform stats
curl http://localhost:8000/api/users/stats

# 3. Frontend is running
curl http://localhost:3000

# 4. Contracts compiled
ls contracts/artifacts/contracts/*.sol/*.json

# 5. AI model exists
ls backend/models/credit_score_model.pkl
```

All should return success! ✅

---

## 🎯 Quick Reference

### Start Everything
```bash
# Terminal 1
cd backend && source venv/bin/activate && uvicorn app:app --reload

# Terminal 2
cd frontend && npm run dev

# Terminal 3
# Keep open for commands
```

### Stop Everything
```bash
# In each terminal
Ctrl+C
```

### View Logs
- Backend: Terminal 1
- Frontend: Terminal 2
- Browser: DevTools Console (F12)
- Blockchain: BaseScan

---

## 🚀 Production Deployment

When ready to deploy to production, see:
- [DEPLOYMENT.md](DEPLOYMENT.md) - Full production guide
- [QUICKSTART.md](QUICKSTART.md) - Quick deployment steps

---

## 💡 Development Tips

1. **Use Hot Reload**: Both backend (`--reload`) and frontend (`npm run dev`) support hot reload
2. **Check Logs**: Always monitor terminal outputs for errors
3. **Test Transactions**: Use BaseScan to verify all transactions
4. **Save Contract Addresses**: Keep them in a safe place
5. **Backup Database**: Regular backups during development

---

## 🆘 Need Help?

- Check [README.md](README.md) for overview
- See [QUICKSTART.md](QUICKSTART.md) for fast setup
- Read [DEPLOYMENT.md](DEPLOYMENT.md) for production
- Review code comments in files
- Check terminal error messages

---

## ✅ Success Indicators

You'll know everything is working when:
- ✅ Backend responds at http://localhost:8000/api/health
- ✅ Frontend loads at http://localhost:3000
- ✅ Wallet connects successfully
- ✅ Credit score displays correctly
- ✅ Transactions confirm on BaseScan
- ✅ Database records are created

---

**You're all set! Now go build something amazing! 🚀**

Need help? Check the logs, review the docs, or debug step by step.
