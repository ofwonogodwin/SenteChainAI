"""
Train the AI credit scoring model
Run this script to train and save the model
"""

from ai_model import CreditScoreModel, generate_synthetic_training_data
import os

def main():
    print("🤖 Training SenteChainAI Credit Scoring Model...\n")
    
    # Generate synthetic training data
    print("📊 Generating synthetic training data...")
    X, y = generate_synthetic_training_data(n_samples=2000)
    print(f"   Generated {len(X)} samples\n")
    
    # Initialize and train model
    print("🧠 Training model...")
    model = CreditScoreModel()
    train_acc, test_acc = model.train(X, y)
    
    print(f"\n✅ Model training complete!")
    print(f"   Training accuracy: {train_acc:.2%}")
    print(f"   Testing accuracy: {test_acc:.2%}")
    
    # Test prediction
    print("\n🧪 Testing prediction...")
    test_features = {
        'transaction_count': 150,
        'avg_transaction_value': 0.5,
        'total_volume': 75.0,
        'unique_counterparties': 80,
        'wallet_age_days': 400,
        'defi_interactions': 15,
        'nft_holdings': 8
    }
    
    score = model.predict_score(test_features)
    print(f"   Test score: {score}/100")
    
    print("\n✨ Model ready for use!")

if __name__ == "__main__":
    main()
