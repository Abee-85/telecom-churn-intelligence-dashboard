"""
ETL — Extract
=============
Loads the raw CSV, validates schema, and reports data quality.
"""
import logging
import pandas as pd
from pathlib import Path

logger = logging.getLogger(__name__)

EXPECTED_COLS = [
    "customerID","gender","SeniorCitizen","Partner","Dependents","tenure",
    "PhoneService","MultipleLines","InternetService","OnlineSecurity",
    "OnlineBackup","DeviceProtection","TechSupport","StreamingTV",
    "StreamingMovies","Contract","PaperlessBilling","PaymentMethod",
    "MonthlyCharges","TotalCharges","Churn",
]


class DataExtractor:
    def __init__(self, path: Path):
        self.path = Path(path)

    def load(self) -> pd.DataFrame:
        if not self.path.exists():
            raise FileNotFoundError(f"Dataset not found: {self.path}")
        df = pd.read_csv(self.path)
        self._validate(df)
        self._quality(df)
        return df

    def _validate(self, df: pd.DataFrame):
        missing = [c for c in EXPECTED_COLS if c not in df.columns]
        if missing:
            raise ValueError(f"Missing expected columns: {missing}")
        logger.info(f"  Schema OK — {df.shape[0]:,} rows · {df.shape[1]} cols")

    def _quality(self, df: pd.DataFrame):
        nulls  = df.isnull().sum()
        blanks = (df.astype(str).eq("")).sum()
        dupes  = df.duplicated().sum()
        logger.info(f"  Null cols   : {nulls[nulls>0].to_dict() or 'none'}")
        logger.info(f"  Blank cells : {blanks[blanks>0].to_dict() or 'none'}")
        logger.info(f"  Duplicates  : {dupes}")
        logger.info(f"  Churn dist  : {df['Churn'].value_counts().to_dict()}")
