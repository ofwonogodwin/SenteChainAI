# SenteChainAI - Contributing Guide

Thank you for your interest in contributing to SenteChainAI! 🎉

## Development Setup

1. Fork the repository
2. Clone your fork
3. Run `./setup.sh`
4. Create a branch: `git checkout -b feature/your-feature`

## Project Structure

```
sentechainai/
├── contracts/      # Solidity smart contracts
├── backend/        # FastAPI Python backend
├── frontend/       # Next.js React frontend
└── database/       # PostgreSQL schemas
```

## Coding Standards

### Solidity
- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Add NatSpec comments
- Write tests for all functions
- Run `npx hardhat test` before committing

### Python
- Follow PEP 8
- Use type hints
- Add docstrings
- Run `pytest` before committing

### TypeScript/React
- Use TypeScript strict mode
- Follow React best practices
- Use functional components with hooks
- Run `npm run lint` before committing

## Testing

```bash
# Smart contracts
cd contracts && npx hardhat test

# Backend
cd backend && pytest

# Frontend
cd frontend && npm test
```

## Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Create PR with clear description

## Code Review

All submissions require review. We'll review for:
- Code quality
- Test coverage
- Documentation
- Security considerations

## Questions?

Open an issue or reach out to the team!
