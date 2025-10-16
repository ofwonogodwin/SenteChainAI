"""
AI Credit Scoring Model
Uses RandomForest to predict creditworthiness
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib
import os

class CreditScoreModel:
    def __init__(self, model_path="models/credit_score_model.pkl"):
        self.model_path = model_path
        self.model = None
        self.scaler = None
        
    def train(self, X, y):
        """Train the credit scoring model"""
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Scale features
        self.scaler = StandardScaler()
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train RandomForest
        self.model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            class_weight='balanced'
        )
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate
        train_score = self.model.score(X_train_scaled, y_train)
        test_score = self.model.score(X_test_scaled, y_test)
        
        print(f"Training accuracy: {train_score:.2f}")
        print(f"Testing accuracy: {test_score:.2f}")
        
        # Save model
        self.save()
        
        return train_score, test_score
    
    def predict_score(self, features):
        """
        Predict credit score (0-100) based on transaction features
        
        Features expected:
        - transaction_count: Number of transactions
        - avg_transaction_value: Average transaction value (ETH)
        - total_volume: Total transaction volume (ETH)
        - unique_counterparties: Number of unique addresses interacted with
        - wallet_age_days: Age of wallet in days
        - defi_interactions: Number of DeFi protocol interactions
        - nft_holdings: Number of NFTs held
        """
        if self.model is None:
            self.load()
        
        # Convert features to array
        if isinstance(features, dict):
            feature_array = np.array([[
                features.get('transaction_count', 0),
                features.get('avg_transaction_value', 0),
                features.get('total_volume', 0),
                features.get('unique_counterparties', 0),
                features.get('wallet_age_days', 0),
                features.get('defi_interactions', 0),
                features.get('nft_holdings', 0)
            ]])
        else:
            feature_array = np.array([features])
        
        # Scale features
        feature_scaled = self.scaler.transform(feature_array)
        
        # Get probability predictions
        probabilities = self.model.predict_proba(feature_scaled)[0]
        
        # Convert to score (0-100)
        # Assuming classes are [0, 1, 2] representing [bad, medium, good]
        score = self._calculate_score_from_probabilities(probabilities, feature_array[0])
        
        return int(np.clip(score, 0, 100))
    
    def _calculate_score_from_probabilities(self, probabilities, features):
        """Convert class probabilities to score 0-100"""
        # Weight by class: bad=0, medium=50, good=100
        base_score = probabilities[0] * 0 + probabilities[1] * 50 + probabilities[2] * 100
        
        # Adjust based on specific features
        # More transactions = better
        if features[0] > 100:
            base_score += 5
        elif features[0] > 50:
            base_score += 2
        
        # More DeFi interactions = better
        if features[5] > 10:
            base_score += 5
        elif features[5] > 5:
            base_score += 3
        
        # Longer wallet age = better
        if features[4] > 365:
            base_score += 5
        elif features[4] > 180:
            base_score += 3
        
        return base_score
    
    def save(self):
        """Save model and scaler to disk"""
        os.makedirs(os.path.dirname(self.model_path), exist_ok=True)
        joblib.dump({
            'model': self.model,
            'scaler': self.scaler
        }, self.model_path)
        print(f"Model saved to {self.model_path}")
    
    def load(self):
        """Load model and scaler from disk"""
        if os.path.exists(self.model_path):
            data = joblib.load(self.model_path)
            self.model = data['model']
            self.scaler = data['scaler']
            print(f"Model loaded from {self.model_path}")
        else:
            raise FileNotFoundError(f"Model not found at {self.model_path}")

def generate_synthetic_training_data(n_samples=1000):
    """Generate synthetic training data for demonstration"""
    np.random.seed(42)
    
    data = []
    labels = []
    
    for _ in range(n_samples):
        # Generate features for different credit tiers
        credit_tier = np.random.choice([0, 1, 2], p=[0.2, 0.5, 0.3])
        
        if credit_tier == 0:  # Bad credit
            transaction_count = np.random.randint(1, 20)
            avg_tx_value = np.random.uniform(0.01, 0.1)
            total_volume = transaction_count * avg_tx_value * np.random.uniform(0.8, 1.2)
            unique_counterparties = np.random.randint(1, 10)
            wallet_age = np.random.randint(1, 90)
            defi_interactions = np.random.randint(0, 3)
            nft_holdings = np.random.randint(0, 2)
        elif credit_tier == 1:  # Medium credit
            transaction_count = np.random.randint(20, 100)
            avg_tx_value = np.random.uniform(0.1, 0.5)
            total_volume = transaction_count * avg_tx_value * np.random.uniform(0.8, 1.2)
            unique_counterparties = np.random.randint(10, 50)
            wallet_age = np.random.randint(90, 365)
            defi_interactions = np.random.randint(3, 10)
            nft_holdings = np.random.randint(2, 10)
        else:  # Good credit
            transaction_count = np.random.randint(100, 500)
            avg_tx_value = np.random.uniform(0.5, 2.0)
            total_volume = transaction_count * avg_tx_value * np.random.uniform(0.8, 1.2)
            unique_counterparties = np.random.randint(50, 200)
            wallet_age = np.random.randint(365, 1000)
            defi_interactions = np.random.randint(10, 50)
            nft_holdings = np.random.randint(10, 50)
        
        data.append([
            transaction_count,
            avg_tx_value,
            total_volume,
            unique_counterparties,
            wallet_age,
            defi_interactions,
            nft_holdings
        ])
        labels.append(credit_tier)
    
    return np.array(data), np.array(labels)

# Initialize global model instance
credit_model = CreditScoreModel()
