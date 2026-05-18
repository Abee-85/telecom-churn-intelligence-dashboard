"""
ETL — Transform
===============
Cleans raw data: fixes types, encodes target, engineers tenure cohorts.
"""
import logging
import pandas as pd

logger = logging.getLogger(__name__)

BINS   = [0, 12, 24, 48, 72]
LABELS = ["0-12 mo", "13-24 mo", "25-48 mo", "49-72 mo"]


class DataTransformer:
    def __init__(self, df: pd.DataFrame):
        self.df = df.copy()

    def run(self) -> pd.DataFrame:
        self._fix_total_charges()
        self._encode_churn()
        self._tenure_cohort()
        logger.info(f"  Transform done — {self.df.shape} · nulls: {self.df.isnull().sum().sum()}")
        return self.df

    # ── private helpers ────────────────────────────────────────────
    def _fix_total_charges(self):
        """Empty TotalCharges strings → 0.0 (new customers, tenure=0)."""
        before = self.df["TotalCharges"].isna().sum()
        self.df["TotalCharges"] = pd.to_numeric(self.df["TotalCharges"], errors="coerce")
        self.df["TotalCharges"].fillna(0.0, inplace=True)
        imputed = self.df["TotalCharges"].isna().sum()   # should be 0
        logger.info(f"  TotalCharges: fixed {before} → imputed {imputed} remaining nulls")

    def _encode_churn(self):
        """Map Yes/No → 1/0 for ML compatibility."""
        self.df["Churn"] = self.df["Churn"].map({"Yes": 1, "No": 0}).astype(int)
        rate = self.df["Churn"].mean() * 100
        logger.info(f"  Churn encoded — overall churn rate: {rate:.2f}%")

    def _tenure_cohort(self):
        """Create tenure lifecycle bucket feature."""
        self.df["TenureCohort"] = pd.cut(
            self.df["tenure"], bins=BINS, labels=LABELS, right=True
        )
        logger.info(f"  TenureCohort distribution:\n{self.df['TenureCohort'].value_counts().sort_index().to_string()}")
