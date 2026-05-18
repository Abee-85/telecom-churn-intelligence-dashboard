-- ============================================================
-- etl_queries.sql  |  ETL + Analytical Queries
-- ============================================================

-- ============================================================
-- SECTION 1: ETL LOAD QUERIES
-- ============================================================

-- Load dimension: DIM_CUSTOMER (from staging)
INSERT OR IGNORE INTO DIM_CUSTOMER (customer_id, gender, senior_citizen, partner, dependents)
SELECT DISTINCT
    customerID, gender, SeniorCitizen, Partner, Dependents
FROM staging_raw;

-- Load dimension: DIM_CONTRACT
INSERT OR IGNORE INTO DIM_CONTRACT (contract_type, payment_method, paperless_billing)
SELECT DISTINCT
    Contract, PaymentMethod, PaperlessBilling
FROM staging_raw;

-- Load dimension: DIM_SERVICE
INSERT OR IGNORE INTO DIM_SERVICE (
    internet_service, phone_service, multiple_lines, online_security,
    online_backup, device_protection, tech_support, streaming_tv, streaming_movies
)
SELECT DISTINCT
    InternetService, PhoneService, MultipleLines, OnlineSecurity,
    OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies
FROM staging_raw;

-- Load dimension: DIM_DATE (tenure buckets)
INSERT OR IGNORE INTO DIM_DATE (tenure_months, tenure_bucket, cohort_order)
SELECT DISTINCT
    tenure,
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN '0-12 mo'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 mo'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 mo'
        ELSE '49-72 mo'
    END AS tenure_bucket,
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN 1
        WHEN tenure BETWEEN 13 AND 24 THEN 2
        WHEN tenure BETWEEN 25 AND 48 THEN 3
        ELSE 4
    END AS cohort_order
FROM staging_raw;

-- Load FACT_CHURN
INSERT INTO FACT_CHURN (
    customer_sk, contract_sk, service_sk, date_sk,
    monthly_charges, total_charges, churn_flag
)
SELECT
    dc.customer_sk,
    dk.contract_sk,
    ds.service_sk,
    dd.date_sk,
    CAST(r.MonthlyCharges AS REAL),
    CASE WHEN r.TotalCharges = '' THEN 0.0
         ELSE CAST(r.TotalCharges AS REAL) END,
    CASE WHEN r.Churn = 'Yes' THEN 1 ELSE 0 END
FROM staging_raw r
JOIN DIM_CUSTOMER dc ON dc.customer_id      = r.customerID
JOIN DIM_CONTRACT dk ON dk.contract_type    = r.Contract
                     AND dk.payment_method  = r.PaymentMethod
JOIN DIM_SERVICE  ds ON ds.internet_service = r.InternetService
JOIN DIM_DATE     dd ON dd.tenure_months    = r.tenure;

-- ============================================================
-- SECTION 2: DATA QUALITY CHECKS
-- ============================================================

-- Row count validation
SELECT 'FACT_CHURN rows' AS check_name, COUNT(*) AS cnt FROM FACT_CHURN;

-- Null check on measures
SELECT COUNT(*) AS null_charges
FROM FACT_CHURN WHERE monthly_charges IS NULL;

-- Class distribution
SELECT churn_flag, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM FACT_CHURN GROUP BY churn_flag;

-- ============================================================
-- SECTION 3: ANALYTICAL QUERIES (BI Layer)
-- ============================================================

-- Q1: Churn rate by contract type
SELECT
    dc.contract_type,
    COUNT(*)                                              AS total_customers,
    SUM(f.churn_flag)                                    AS churned,
    ROUND(100.0 * SUM(f.churn_flag) / COUNT(*), 2)      AS churn_rate_pct,
    ROUND(AVG(f.monthly_charges), 2)                     AS avg_monthly_charge
FROM FACT_CHURN f
JOIN DIM_CONTRACT dc ON dc.contract_sk = f.contract_sk
GROUP BY dc.contract_type
ORDER BY churn_rate_pct DESC;

-- Q2: Churn rate by tenure cohort
SELECT
    dd.tenure_bucket,
    dd.cohort_order,
    COUNT(*)                                              AS total_customers,
    SUM(f.churn_flag)                                    AS churned,
    ROUND(100.0 * SUM(f.churn_flag) / COUNT(*), 2)      AS churn_rate_pct
FROM FACT_CHURN f
JOIN DIM_DATE dd ON dd.date_sk = f.date_sk
GROUP BY dd.tenure_bucket, dd.cohort_order
ORDER BY dd.cohort_order;

-- Q3: Churn rate by internet service type
SELECT
    ds.internet_service,
    COUNT(*)                                              AS total_customers,
    SUM(f.churn_flag)                                    AS churned,
    ROUND(100.0 * SUM(f.churn_flag) / COUNT(*), 2)      AS churn_rate_pct,
    ROUND(AVG(f.monthly_charges), 2)                     AS avg_monthly_charge
FROM FACT_CHURN f
JOIN DIM_SERVICE ds ON ds.service_sk = f.service_sk
GROUP BY ds.internet_service
ORDER BY churn_rate_pct DESC;

-- Q4: Revenue at risk (churned customer revenue)
SELECT
    ROUND(SUM(f.monthly_charges), 2)  AS total_monthly_revenue,
    ROUND(SUM(CASE WHEN f.churn_flag=1 THEN f.monthly_charges ELSE 0 END), 2) AS revenue_at_risk,
    ROUND(100.0 * SUM(CASE WHEN f.churn_flag=1 THEN f.monthly_charges ELSE 0 END)
          / SUM(f.monthly_charges), 2)                   AS pct_at_risk
FROM FACT_CHURN f;

-- Q5: High-risk customer list (churn_probability > 0.60)
SELECT
    dc.customer_id,
    dc.senior_citizen,
    dk.contract_type,
    dk.payment_method,
    f.monthly_charges,
    f.churn_probability,
    f.risk_segment
FROM FACT_CHURN f
JOIN DIM_CUSTOMER dc ON dc.customer_sk = f.customer_sk
JOIN DIM_CONTRACT dk ON dk.contract_sk = f.contract_sk
WHERE f.churn_probability > 0.60
ORDER BY f.churn_probability DESC;

-- Q6: KPI Summary dashboard card values
SELECT
    COUNT(*)                                              AS total_customers,
    SUM(churn_flag)                                      AS total_churned,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2)        AS overall_churn_rate,
    ROUND(AVG(monthly_charges), 2)                       AS avg_monthly_charge,
    ROUND(AVG(CASE WHEN churn_flag=1 THEN monthly_charges END), 2) AS churned_avg_charge,
    ROUND(AVG(CASE WHEN churn_flag=0 THEN monthly_charges END), 2) AS retained_avg_charge
FROM FACT_CHURN;
