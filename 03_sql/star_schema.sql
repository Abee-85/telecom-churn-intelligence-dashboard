-- ============================================================
-- star_schema.sql  |  Churn Analytics Data Warehouse
-- Star Schema: FACT_CHURN  +  4 Dimension Tables
-- ============================================================

-- ── Dimension Tables ──────────────────────────────────────────

DROP TABLE IF EXISTS DIM_CUSTOMER;
CREATE TABLE DIM_CUSTOMER (
    customer_sk       INTEGER     PRIMARY KEY AUTOINCREMENT,  -- surrogate key
    customer_id       TEXT        UNIQUE NOT NULL,
    gender            TEXT,
    senior_citizen    INTEGER,
    partner           TEXT,
    dependents        TEXT,
    valid_from        DATE        DEFAULT CURRENT_DATE,
    valid_to          DATE        DEFAULT '9999-12-31',
    is_current        INTEGER     DEFAULT 1
);

DROP TABLE IF EXISTS DIM_CONTRACT;
CREATE TABLE DIM_CONTRACT (
    contract_sk       INTEGER     PRIMARY KEY AUTOINCREMENT,
    contract_type     TEXT        NOT NULL,
    payment_method    TEXT        NOT NULL,
    paperless_billing TEXT
);

DROP TABLE IF EXISTS DIM_SERVICE;
CREATE TABLE DIM_SERVICE (
    service_sk        INTEGER     PRIMARY KEY AUTOINCREMENT,
    internet_service  TEXT,
    phone_service     TEXT,
    multiple_lines    TEXT,
    online_security   TEXT,
    online_backup     TEXT,
    device_protection TEXT,
    tech_support      TEXT,
    streaming_tv      TEXT,
    streaming_movies  TEXT
);

DROP TABLE IF EXISTS DIM_DATE;
CREATE TABLE DIM_DATE (
    date_sk           INTEGER     PRIMARY KEY,
    tenure_months     INTEGER,
    tenure_bucket     TEXT,
    cohort_order      INTEGER     -- 1=new,2=early,3=established,4=loyal
);

-- ── Central Fact Table ─────────────────────────────────────────

DROP TABLE IF EXISTS FACT_CHURN;
CREATE TABLE FACT_CHURN (
    fact_sk           INTEGER     PRIMARY KEY AUTOINCREMENT,
    customer_sk       INTEGER     NOT NULL REFERENCES DIM_CUSTOMER(customer_sk),
    contract_sk       INTEGER     NOT NULL REFERENCES DIM_CONTRACT(contract_sk),
    service_sk        INTEGER     NOT NULL REFERENCES DIM_SERVICE(service_sk),
    date_sk           INTEGER     NOT NULL REFERENCES DIM_DATE(date_sk),
    -- Measures
    monthly_charges   REAL        NOT NULL,
    total_charges     REAL        DEFAULT 0.0,
    churn_flag        INTEGER     NOT NULL CHECK(churn_flag IN (0,1)),
    churn_probability REAL,
    risk_segment      TEXT
);

-- ── Performance Indexes ────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_fact_customer ON FACT_CHURN(customer_sk);
CREATE INDEX IF NOT EXISTS idx_fact_contract ON FACT_CHURN(contract_sk);
CREATE INDEX IF NOT EXISTS idx_fact_service  ON FACT_CHURN(service_sk);
CREATE INDEX IF NOT EXISTS idx_fact_date     ON FACT_CHURN(date_sk);
CREATE INDEX IF NOT EXISTS idx_fact_churn    ON FACT_CHURN(churn_flag);
