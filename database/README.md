# Database Setup Instructions

## Prerequisites
- PostgreSQL 14+ installed
- Access to PostgreSQL server

## Quick Setup

### 1. Install PostgreSQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# macOS (with Homebrew)
brew install postgresql
brew services start postgresql

# Windows
# Download installer from https://www.postgresql.org/download/windows/
```

### 2. Create Database and User
```bash
# Login as postgres superuser
sudo -u postgres psql

# In PostgreSQL prompt:
CREATE DATABASE sentechainai;
CREATE USER sente_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE sentechainai TO sente_user;
\q
```

### 3. Run Schema
```bash
# Run the schema SQL file
psql -U sente_user -d sentechainai -f schema.sql

# Or as postgres user:
sudo -u postgres psql -d sentechainai -f schema.sql
```

### 4. Verify Setup
```bash
psql -U sente_user -d sentechainai

# In PostgreSQL prompt:
\dt  # List tables
SELECT * FROM platform_statistics;  # Check stats view
\q
```

## Configuration

### Update Backend .env
```env
DATABASE_URL=postgresql://sente_user:your_secure_password@localhost:5432/sentechainai
```

## Database Structure

### Tables
- `users` - User profiles and credit scores
- `loans` - Loan records
- `credit_score_history` - Score change history
- `transaction_data` - On-chain data for AI

### Views
- `user_statistics` - Aggregated user metrics
- `platform_statistics` - Platform-wide statistics

## Maintenance

### Backup Database
```bash
pg_dump -U sente_user sentechainai > backup.sql
```

### Restore Database
```bash
psql -U sente_user sentechainai < backup.sql
```

### Reset Database
```bash
sudo -u postgres psql -d sentechainai -f schema.sql
```

## Troubleshooting

### Connection Issues
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Check firewall: `sudo ufw allow 5432/tcp`
- Verify pg_hba.conf settings for authentication

### Permission Issues
```sql
-- Grant all permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sente_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sente_user;
```
