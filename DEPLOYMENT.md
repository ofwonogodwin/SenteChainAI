# 🚀 Deployment Guide

## Prerequisites

- [ ] Node.js 18+ installed
- [ ] Python 3.10+ installed
- [ ] PostgreSQL 14+ installed
- [ ] MetaMask wallet with Base Sepolia ETH
- [ ] Alchemy or Infura API key
- [ ] WalletConnect Project ID

## Step-by-Step Deployment

### 1. Clone and Install Dependencies

```bash
git clone <your-repo-url>
cd SenteChainAI
chmod +x setup.sh
./setup.sh
```

### 2. Get Base Sepolia Test ETH

Visit: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

Get at least 0.5 ETH for deployment and testing.

### 3. Configure Smart Contracts

```bash
cd contracts
cp .env.example .env
nano .env
```

Add:
```env
PRIVATE_KEY=your_private_key_here
BASE_SEPOLIA_RPC_URL=https://base-sepolia.g.alchemy.com/v2/YOUR-API-KEY
BASESCAN_API_KEY=your_basescan_api_key
```

### 4. Deploy Smart Contracts

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to Base Sepolia
npx hardhat run scripts/deploy.js --network baseSepolia
```

**Save the contract addresses from the output!**

### 5. Verify Contracts (Optional but Recommended)

```bash
npx hardhat verify --network baseSepolia <CREDIT_REGISTRY_ADDRESS>
npx hardhat verify --network baseSepolia <SENTE_BADGE_ADDRESS>
npx hardhat verify --network baseSepolia <LENDING_POOL_ADDRESS> "<USDC_ADDRESS>" "<CREDIT_REGISTRY_ADDRESS>"
```

### 6. Setup PostgreSQL Database

```bash
# Create database
sudo -u postgres psql
CREATE DATABASE sentechainai;
CREATE USER sente_user WITH PASSWORD 'secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE sentechainai TO sente_user;
\q

# Run schema
cd ../database
sudo -u postgres psql -d sentechainai -f schema.sql
```

### 7. Configure Backend

```bash
cd ../backend
cp .env.example .env
nano .env
```

Update:
```env
DATABASE_URL=postgresql://sente_user:secure_password_here@localhost:5432/sentechainai
BLOCKCHAIN_RPC_URL=https://sepolia.base.org
CREDIT_REGISTRY_ADDRESS=<your_deployed_address>
LENDING_POOL_ADDRESS=<your_deployed_address>
SENTE_BADGE_ADDRESS=<your_deployed_address>
SECRET_KEY=<generate_with_openssl_rand_hex_32>
```

Train AI model:
```bash
source venv/bin/activate
python train_model.py
```

### 8. Configure Frontend

```bash
cd ../frontend
cp .env.example .env.local
nano .env.local
```

Update:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_CREDIT_REGISTRY_ADDRESS=<your_deployed_address>
NEXT_PUBLIC_LENDING_POOL_ADDRESS=<your_deployed_address>
NEXT_PUBLIC_SENTE_BADGE_ADDRESS=<your_deployed_address>
NEXT_PUBLIC_USDC_ADDRESS=<usdc_address>
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=<get_from_cloud.walletconnect.com>
```

### 9. Test Locally

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

Visit: http://localhost:3000

### 10. Deploy to Production

#### Backend (Render/Railway)

**Render:**
1. Create new Web Service
2. Connect GitHub repo
3. Set build command: `pip install -r backend/requirements.txt`
4. Set start command: `cd backend && uvicorn app:app --host 0.0.0.0 --port $PORT`
5. Add environment variables from backend/.env
6. Deploy

**Railway:**
1. Create new project
2. Connect GitHub repo
3. Add PostgreSQL database
4. Set start command: `cd backend && uvicorn app:app --host 0.0.0.0 --port $PORT`
5. Add environment variables
6. Deploy

#### Frontend (Vercel)

```bash
cd frontend
npm run build  # Test build locally

# Deploy to Vercel
npx vercel

# Or connect GitHub repo on vercel.com
```

**Important:** Update `NEXT_PUBLIC_API_URL` in production .env to your backend URL.

### 11. Post-Deployment

1. **Test all functionality:**
   - Connect wallet
   - Get credit score
   - Request loan (deposit USDC to pool first)
   - Repay loan
   - Check badge minting

2. **Monitor:**
   - Check backend logs
   - Monitor contract events on BaseScan
   - Check database for records

3. **Security:**
   - Never commit .env files
   - Use strong passwords
   - Enable 2FA on all services
   - Regular security audits

## Production Checklist

- [ ] Smart contracts deployed and verified
- [ ] Database created and secured
- [ ] Backend deployed with proper environment variables
- [ ] Frontend deployed with correct API URL
- [ ] All environment variables set correctly
- [ ] SSL certificates installed (auto with Vercel/Render)
- [ ] Domain configured (optional)
- [ ] Monitoring set up
- [ ] Backup strategy in place
- [ ] Documentation updated

## Troubleshooting

### Contract Deployment Fails
- Check you have enough ETH for gas
- Verify RPC URL is correct
- Check network is Base Sepolia (Chain ID: 84532)

### Backend Won't Start
- Verify database connection string
- Check all environment variables are set
- Ensure PostgreSQL is running
- Check Python version (3.10+)

### Frontend Build Fails
- Run `npm install` again
- Check all contract addresses are set
- Verify Next.js 15 is installed
- Clear `.next` folder and rebuild

### Wallet Connection Issues
- Check WalletConnect Project ID is set
- Verify you're on Base Sepolia network
- Clear browser cache
- Try different wallet/browser

## Support

For issues:
1. Check the logs
2. Review environment variables
3. Consult README.md
4. Check GitHub Issues

## Cost Estimates

### Development (Base Sepolia)
- Contract deployment: ~0.05 ETH (test)
- Testing: ~0.01 ETH
- Total: ~0.06 ETH (FREE from faucet)

### Production (Base Mainnet)
- Contract deployment: ~$5-10
- Backend (Render): $7/month (Hobby plan) or FREE (Starter)
- Frontend (Vercel): FREE (Hobby plan)
- Database: Included with backend or $7/month
- **Total: $0-14/month**

## Next Steps

After deployment:
1. Share with testers
2. Gather feedback
3. Monitor usage
4. Iterate and improve
5. Consider audit for mainnet
6. Build community
7. Apply for grants

Good luck with your hackathon! 🚀
