
import sqlite3
import logging
import pandas as pd
from pathlib import Path

logger = logging.getLogger(__name__)


class DataLoader:
    def __init__(self, df: pd.DataFrame, db_path: Path):
        self.df      = df.copy()
        self.db_path = Path(db_path)

    def run(self):
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        conn = sqlite3.connect(self.db_path)
        try:
            self._create_schema(conn)
            self._load_dimensions(conn)
            self._load_fact(conn)
            conn.commit()
            self._validate(conn)
        finally:
            conn.close()
        logger.info(f"  Warehouse ready: {self.db_path}")

    # ── private ────────────────────────────────────────────────────
    def _create_schema(self, conn):
        conn.executescript("""
        CREATE TABLE IF NOT EXISTS DIM_CUSTOMER (
            customer_id TEXT PRIMARY KEY,
            gender TEXT, senior_citizen INTEGER,
            partner TEXT, dependents TEXT
        );
        CREATE TABLE IF NOT EXISTS DIM_CONTRACT (
            contract_type TEXT PRIMARY KEY,
            payment_method TEXT, paperless_billing TEXT
        );
        CREATE TABLE IF NOT EXISTS DIM_SERVICE (
            internet_service TEXT PRIMARY KEY,
            phone_service TEXT, online_security TEXT,
            tech_support TEXT, streaming_tv TEXT
        );
        CREATE TABLE IF NOT EXISTS DIM_DATE (
            tenure_bucket TEXT PRIMARY KEY,
            cohort_order INTEGER
        );
        CREATE TABLE IF NOT EXISTS FACT_CHURN (
            fact_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id TEXT, contract_type TEXT,
            internet_service TEXT, tenure_bucket TEXT,
            tenure INTEGER, monthly_charges REAL,
            total_charges REAL, churn INTEGER,
            FOREIGN KEY(customer_id)      REFERENCES DIM_CUSTOMER(customer_id),
            FOREIGN KEY(contract_type)    REFERENCES DIM_CONTRACT(contract_type),
            FOREIGN KEY(internet_service) REFERENCES DIM_SERVICE(internet_service),
            FOREIGN KEY(tenure_bucket)    REFERENCES DIM_DATE(tenure_bucket)
        );
        """)

    def _load_dimensions(self, conn):
        # DIM_CUSTOMER
        dim_c = self.df[["customerID","gender","SeniorCitizen","Partner","Dependents"]].drop_duplicates()
        dim_c.columns = ["customer_id","gender","senior_citizen","partner","dependents"]
        dim_c.to_sql("DIM_CUSTOMER", conn, if_exists="replace", index=False)

        # DIM_CONTRACT
        dim_k = self.df[["Contract","PaymentMethod","PaperlessBilling"]].drop_duplicates()
        dim_k.columns = ["contract_type","payment_method","paperless_billing"]
        dim_k.to_sql("DIM_CONTRACT", conn, if_exists="replace", index=False)

        # DIM_SERVICE
        dim_s = self.df[["InternetService","PhoneService","OnlineSecurity","TechSupport","StreamingTV"]].drop_duplicates()
        dim_s.columns = ["internet_service","phone_service","online_security","tech_support","streaming_tv"]
        dim_s.to_sql("DIM_SERVICE", conn, if_exists="replace", index=False)

        # DIM_DATE
        cohort_order = {"0-12 mo":1,"13-24 mo":2,"25-48 mo":3,"49-72 mo":4}
        dim_d = self.df[["TenureCohort"]].drop_duplicates().dropna()
        dim_d.columns = ["tenure_bucket"]
        dim_d["cohort_order"] = dim_d["tenure_bucket"].map(cohort_order)
        dim_d.to_sql("DIM_DATE", conn, if_exists="replace", index=False)

        logger.info("  Dimension tables loaded")

    def _load_fact(self, conn):
        fact = self.df[[
            "customerID","Contract","InternetService","TenureCohort",
            "tenure","MonthlyCharges","TotalCharges","Churn"
        ]].copy()
        fact.columns = [
            "customer_id","contract_type","internet_service","tenure_bucket",
            "tenure","monthly_charges","total_charges","churn"
        ]
        fact.to_sql("FACT_CHURN", conn, if_exists="replace", index=False)
        logger.info(f"  FACT_CHURN loaded: {len(fact):,} rows")

    def _validate(self, conn):
        n = conn.execute("SELECT COUNT(*) FROM FACT_CHURN").fetchone()[0]
        assert n == len(self.df), f"Row mismatch: {n} ≠ {len(self.df)}"
        logger.info(f"  Validation PASSED — {n:,} rows in warehouse")
