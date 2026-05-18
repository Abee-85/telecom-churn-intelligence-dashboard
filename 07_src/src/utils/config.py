"""Central configuration — all paths, constants, and hyperparameters."""
import os
from pathlib import Path


class Config:
    # ── Paths ──────────────────────────────────────────────────────
    ROOT_DIR      = Path(__file__).resolve().parent.parent.parent
    DATA_DIR      = ROOT_DIR / "data"
    RAW_DATA_PATH = DATA_DIR / "raw" / "WA_FnUseC_TelcoCustomerChurn.csv"
    PROCESSED_DIR = DATA_DIR / "processed"
    DB_PATH       = ROOT_DIR / "churn_warehouse.db"
    MODELS_DIR    = ROOT_DIR / "models" / "trained_models"
    CHARTS_DIR    = ROOT_DIR / "docs" / "screenshots"

    # ── ML Hyperparameters ─────────────────────────────────────────
    TEST_SIZE    = 0.20
    RANDOM_STATE = 42
    STRATIFY     = True

    # ── Logging ────────────────────────────────────────────────────
    LOG_LEVEL  = os.getenv("LOG_LEVEL", "INFO")

    # ── Feature Definitions ────────────────────────────────────────
    TARGET_COL  = "Churn"
    DROP_COLS   = ["customerID", "TenureCohort"]
    BINARY_COLS = ["Partner", "Dependents", "PhoneService", "PaperlessBilling"]
    CAT_COLS    = [
        "InternetService", "Contract", "PaymentMethod",
        "MultipleLines", "OnlineSecurity", "OnlineBackup",
        "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies",
    ]
    NUMERIC_COLS = ["tenure", "MonthlyCharges", "TotalCharges", "SeniorCitizen"]

    # ── Tenure Buckets ─────────────────────────────────────────────
    TENURE_BINS   = [0, 12, 24, 48, 72]
    TENURE_LABELS = ["0-12 mo", "13-24 mo", "25-48 mo", "49-72 mo"]

    def ensure_dirs(self):
        """Create output directories if they don't exist."""
        for d in [self.PROCESSED_DIR, self.MODELS_DIR, self.CHARTS_DIR]:
            d.mkdir(parents=True, exist_ok=True)
