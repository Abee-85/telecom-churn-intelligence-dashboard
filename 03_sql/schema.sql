-- ============================================================
-- schema.sql  |  Telecom Churn Intelligence — OLTP Schema
-- ============================================================

-- Drop and recreate for idempotency
DROP TABLE IF EXISTS CUSTOMERS;
DROP TABLE IF EXISTS SUBSCRIPTIONS;
DROP TABLE IF EXISTS BILLING;
DROP TABLE IF EXISTS CHURN_EVENTS;

-- ── CUSTOMERS ─────────────────────────────────────────────────
CREATE TABLE CUSTOMERS (
    customer_id       TEXT        PRIMARY KEY,
    gender            TEXT        NOT NULL CHECK(gender IN ('Male','Female')),
    senior_citizen    INTEGER     NOT NULL DEFAULT 0 CHECK(senior_citizen IN (0,1)),
    partner           TEXT        CHECK(partner IN ('Yes','No')),
    dependents        TEXT        CHECK(dependents IN ('Yes','No')),
    created_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── SUBSCRIPTIONS ─────────────────────────────────────────────
CREATE TABLE SUBSCRIPTIONS (
    subscription_id   INTEGER     PRIMARY KEY AUTOINCREMENT,
    customer_id       TEXT        NOT NULL REFERENCES CUSTOMERS(customer_id),
    tenure_months     INTEGER     NOT NULL CHECK(tenure_months >= 0),
    contract_type     TEXT        NOT NULL CHECK(contract_type IN
                                   ('Month-to-month','One year','Two year')),
    phone_service     TEXT        CHECK(phone_service IN ('Yes','No')),
    multiple_lines    TEXT,
    internet_service  TEXT        CHECK(internet_service IN ('DSL','Fiber optic','No')),
    online_security   TEXT,
    online_backup     TEXT,
    device_protection TEXT,
    tech_support      TEXT,
    streaming_tv      TEXT,
    streaming_movies  TEXT
);

-- ── BILLING ───────────────────────────────────────────────────
CREATE TABLE BILLING (
    billing_id        INTEGER     PRIMARY KEY AUTOINCREMENT,
    customer_id       TEXT        NOT NULL REFERENCES CUSTOMERS(customer_id),
    payment_method    TEXT        NOT NULL,
    paperless_billing TEXT        CHECK(paperless_billing IN ('Yes','No')),
    monthly_charges   REAL        NOT NULL CHECK(monthly_charges > 0),
    total_charges     REAL        DEFAULT 0.0,
    billing_date      DATE        DEFAULT CURRENT_DATE
);

-- ── CHURN_EVENTS ──────────────────────────────────────────────
CREATE TABLE CHURN_EVENTS (
    churn_id          INTEGER     PRIMARY KEY AUTOINCREMENT,
    customer_id       TEXT        NOT NULL REFERENCES CUSTOMERS(customer_id),
    churn_flag        INTEGER     NOT NULL CHECK(churn_flag IN (0,1)),
    churn_probability REAL,
    risk_segment      TEXT        CHECK(risk_segment IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    detected_at       TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_subs_customer  ON SUBSCRIPTIONS(customer_id);
CREATE INDEX IF NOT EXISTS idx_bill_customer  ON BILLING(customer_id);
CREATE INDEX IF NOT EXISTS idx_churn_customer ON CHURN_EVENTS(customer_id);
CREATE INDEX IF NOT EXISTS idx_churn_flag     ON CHURN_EVENTS(churn_flag);
CREATE INDEX IF NOT EXISTS idx_subs_contract  ON SUBSCRIPTIONS(contract_type);
