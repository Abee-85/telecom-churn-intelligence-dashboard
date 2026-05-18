"""
Churn Predictor
===============
Loads a saved model and scores new customer records.

Usage:
    from src.prediction.predict import ChurnPredictor
    predictor = ChurnPredictor("models/trained_models/logistic_regression.pkl")
    scores = predictor.score(df_new)
"""
import logging
import joblib
import pandas  as pd
import numpy   as np
from pathlib import Path

logger = logging.getLogger(__name__)

RISK_THRESHOLDS = {
    "LOW"     : (0.00, 0.30),
    "MEDIUM"  : (0.30, 0.50),
    "HIGH"    : (0.50, 0.70),
    "CRITICAL": (0.70, 1.01),
}


class ChurnPredictor:
    def __init__(self, model_path: str | Path):
        self.model_path = Path(model_path)
        self.model = self._load()

    def score(self, X: pd.DataFrame) -> pd.DataFrame:
        """
        Parameters
        ----------
        X : pd.DataFrame — preprocessed feature matrix (same columns as training)

        Returns
        -------
        pd.DataFrame with columns:
            churn_probability  — float [0,1]
            churn_prediction   — int   {0,1}
            risk_segment       — str   {LOW, MEDIUM, HIGH, CRITICAL}
        """
        proba = self.model.predict_proba(X)[:, 1]
        pred  = (proba >= 0.5).astype(int)
        risk  = np.where(
            proba < 0.30, "LOW",
            np.where(proba < 0.50, "MEDIUM",
                     np.where(proba < 0.70, "HIGH", "CRITICAL"))
        )
        result = pd.DataFrame({
            "churn_probability": proba.round(4),
            "churn_prediction" : pred,
            "risk_segment"     : risk,
        })
        logger.info(
            f"  Scored {len(result):,} customers — "
            f"predicted churn: {pred.sum()} ({pred.mean()*100:.1f}%)"
        )
        return result

    def _load(self):
        if not self.model_path.exists():
            raise FileNotFoundError(f"Model not found: {self.model_path}")
        model = joblib.load(self.model_path)
        logger.info(f"  Model loaded: {self.model_path.name}")
        return model
