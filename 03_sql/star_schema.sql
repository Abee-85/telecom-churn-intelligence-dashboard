-- TELECOM CHURN PROJECT - STAR SCHEMA
-- Ready for PostgreSQL Execution

BEGIN;

-- ============================================================================
-- TELECOM CHURN DATA WAREHOUSE - STAR SCHEMA
-- Dimensional model for analytics and BI reporting
-- 5 Tables: 1 Fact + 4 Dimensions
-- ============================================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS fact_churn CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_service CASCADE;
DROP TABLE IF EXISTS dim_billing CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

-- ============================================================================
-- DIMENSION TABLE: dim_date
-- Date dimension for time-based analysis
-- ============================================================================
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_week INTEGER,
    day_name VARCHAR(10),
    day_of_month INTEGER,
    day_of_year INTEGER,
    week_of_year INTEGER,
    month INTEGER,
    month_name VARCHAR(10),
    quarter INTEGER,
    year INTEGER,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN
);

-- Index
CREATE INDEX idx_dim_date_full ON dim_date(full_date);
CREATE INDEX idx_dim_date_year_month ON dim_date(year, month);

-- ============================================================================
-- DIMENSION TABLE: dim_customer
-- Customer demographic attributes
-- ============================================================================
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL UNIQUE,
    gender VARCHAR(10),
    age_group VARCHAR(20),
    senior_citizen VARCHAR(5),
    partner VARCHAR(5),
    dependents VARCHAR(5),
    customer_segment VARCHAR(30),
    -- SCD Type 2 fields
    effective_date DATE DEFAULT CURRENT_DATE,
    expiry_date DATE DEFAULT '9999-12-31',
    is_current BOOLEAN DEFAULT TRUE
);

-- Indexes
CREATE INDEX idx_dim_customer_id ON dim_customer(customer_id);
CREATE INDEX idx_dim_customer_segment ON dim_customer(customer_segment);
CREATE INDEX idx_dim_customer_senior ON dim_customer(senior_citizen);

-- ============================================================================
-- DIMENSION TABLE: dim_service
-- Service subscription details
-- ============================================================================
CREATE TABLE dim_service (
    service_key SERIAL PRIMARY KEY,
    phone_service VARCHAR(5),
    multiple_lines VARCHAR(20),
    internet_service VARCHAR(20),
    online_security VARCHAR(20),
    online_backup VARCHAR(20),
    device_protection VARCHAR(20),
    tech_support VARCHAR(20),
    streaming_tv VARCHAR(20),
    streaming_movies VARCHAR(20),
    total_services INTEGER,
    service_bundle_type VARCHAR(30)
);

-- Index
CREATE INDEX idx_dim_service_internet ON dim_service(internet_service);
CREATE INDEX idx_dim_service_bundle ON dim_service(service_bundle_type);

-- ============================================================================
-- DIMENSION TABLE: dim_billing
-- Billing and contract information
-- ============================================================================
CREATE TABLE dim_billing (
    billing_key SERIAL PRIMARY KEY,
    contract_type VARCHAR(20),
    payment_method VARCHAR(30),
    paperless_billing VARCHAR(5),
    tenure_group VARCHAR(20),
    monthly_charge_range VARCHAR(20),
    contract_category VARCHAR(30)
);

-- Indexes
CREATE INDEX idx_dim_billing_contract ON dim_billing(contract_type);
CREATE INDEX idx_dim_billing_payment ON dim_billing(payment_method);
CREATE INDEX idx_dim_billing_tenure ON dim_billing(tenure_group);

-- ============================================================================
-- FACT TABLE: fact_churn
-- Central fact table with measures and foreign keys to dimensions
-- ============================================================================
CREATE TABLE fact_churn (
    fact_id SERIAL PRIMARY KEY,
    
    -- Foreign Keys (Dimension References)
    customer_key INTEGER NOT NULL,
    service_key INTEGER NOT NULL,
    billing_key INTEGER NOT NULL,
    churn_date_key INTEGER,
    billing_date_key INTEGER NOT NULL,
    
    -- Measures (Facts)
    tenure_months INTEGER,
    monthly_charges DECIMAL(10, 2),
    total_charges DECIMAL(10, 2),
    avg_monthly_charges DECIMAL(10, 2),
    
    -- Churn Indicators
    churned INTEGER CHECK (churned IN (0, 1)),
    churn_probability DECIMAL(5, 4),
    churn_risk_score INTEGER CHECK (churn_risk_score BETWEEN 1 AND 10),
    
    -- Calculated Measures
    total_revenue DECIMAL(12, 2),
    customer_lifetime_value DECIMAL(12, 2),
    months_to_churn INTEGER,
    
    -- Metadata
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_fact_customer 
        FOREIGN KEY (customer_key) 
        REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_fact_service 
        FOREIGN KEY (service_key) 
        REFERENCES dim_service(service_key),
    CONSTRAINT fk_fact_billing 
        FOREIGN KEY (billing_key) 
        REFERENCES dim_billing(billing_key),
    CONSTRAINT fk_fact_churn_date 
        FOREIGN KEY (churn_date_key) 
        REFERENCES dim_date(date_key),
    CONSTRAINT fk_fact_billing_date 
        FOREIGN KEY (billing_date_key) 
        REFERENCES dim_date(date_key)
);

-- Indexes for faster queries
CREATE INDEX idx_fact_customer ON fact_churn(customer_key);
CREATE INDEX idx_fact_service ON fact_churn(service_key);
CREATE INDEX idx_fact_billing ON fact_churn(billing_key);
CREATE INDEX idx_fact_churned ON fact_churn(churned);
CREATE INDEX idx_fact_churn_date ON fact_churn(churn_date_key);
CREATE INDEX idx_fact_billing_date ON fact_churn(billing_date_key);

-- Composite indexes for common query patterns
CREATE INDEX idx_fact_churn_analysis ON fact_churn(churned, churn_date_key);
CREATE INDEX idx_fact_revenue_analysis ON fact_churn(billing_date_key, monthly_charges);

-- ============================================================================
-- POPULATE DATE DIMENSION (Generate 5 years of dates)
-- ============================================================================
INSERT INTO dim_date (date_key, full_date, day_of_week, day_name, day_of_month, 
                      day_of_year, week_of_year, month, month_name, quarter, year, 
                      is_weekend, is_holiday)
SELECT 
    TO_CHAR(date_val, 'YYYYMMDD')::INTEGER as date_key,
    date_val as full_date,
    EXTRACT(DOW FROM date_val)::INTEGER as day_of_week,
    TO_CHAR(date_val, 'Day') as day_name,
    EXTRACT(DAY FROM date_val)::INTEGER as day_of_month,
    EXTRACT(DOY FROM date_val)::INTEGER as day_of_year,
    EXTRACT(WEEK FROM date_val)::INTEGER as week_of_year,
    EXTRACT(MONTH FROM date_val)::INTEGER as month,
    TO_CHAR(date_val, 'Month') as month_name,
    EXTRACT(QUARTER FROM date_val)::INTEGER as quarter,
    EXTRACT(YEAR FROM date_val)::INTEGER as year,
    CASE WHEN EXTRACT(DOW FROM date_val) IN (0, 6) THEN TRUE ELSE FALSE END as is_weekend,
    FALSE as is_holiday
FROM generate_series(
    '2020-01-01'::DATE,
    '2024-12-31'::DATE,
    '1 day'::INTERVAL
) as date_val;

-- ============================================================================
-- SAMPLE DIMENSION DATA
-- ============================================================================

-- Sample dim_customer data
INSERT INTO dim_customer (customer_id, gender, age_group, senior_citizen, partner, 
                          dependents, customer_segment) VALUES
('CUST000001', 'Male', '26-35', 'No', 'Yes', 'No', 'Young Professional'),
('CUST000002', 'Female', '65+', 'Yes', 'No', 'No', 'Senior'),
('CUST000003', 'Male', '36-50', 'No', 'Yes', 'Yes', 'Family');

-- Sample dim_service data
INSERT INTO dim_service (phone_service, multiple_lines, internet_service, online_security,
                         online_backup, device_protection, tech_support, streaming_tv,
                         streaming_movies, total_services, service_bundle_type) VALUES
('Yes', 'No', 'Fiber optic', 'No', 'No', 'No', 'No', 'Yes', 'Yes', 4, 'Internet + Entertainment'),
('Yes', 'Yes', 'DSL', 'Yes', 'Yes', 'Yes', 'Yes', 'No', 'No', 6, 'Full Protection'),
('Yes', 'No', 'No', 'No internet', 'No internet', 'No internet', 'No internet', 'No', 'No', 1, 'Phone Only');

-- Sample dim_billing data
INSERT INTO dim_billing (contract_type, payment_method, paperless_billing, tenure_group,
                         monthly_charge_range, contract_category) VALUES
('Month-to-month', 'Electronic check', 'Yes', '0-12 months', 'High ($70+)', 'Short-term High-value'),
('Two year', 'Credit card (automatic)', 'No', '24-48 months', 'High ($70+)', 'Long-term Loyal'),
('One year', 'Bank transfer (automatic)', 'Yes', '0-12 months', 'Medium ($35-70)', 'Mid-term Moderate');

-- Sample fact_churn data
INSERT INTO fact_churn (customer_key, service_key, billing_key, churn_date_key, billing_date_key,
                        tenure_months, monthly_charges, total_charges, avg_monthly_charges,
                        churned, churn_probability, churn_risk_score, total_revenue,
                        customer_lifetime_value, months_to_churn) VALUES
(1, 1, 1, NULL, 20230115, 12, 85.50, 1026.00, 85.50, 0, 0.7543, 8, 1026.00, 2052.00, NULL),
(2, 2, 2, NULL, 20210601, 40, 95.00, 3800.00, 95.00, 0, 0.1234, 2, 3800.00, 22800.00, NULL),
(3, 3, 3, NULL, 20240520, 6, 75.25, 451.50, 75.25, 0, 0.4567, 5, 451.50, 903.00, NULL);

-- ============================================================================
-- ANALYTICAL VIEWS
-- ============================================================================

-- View: Churn Analysis by Contract Type
CREATE OR REPLACE VIEW vw_churn_by_contract AS
SELECT 
    b.contract_type,
    COUNT(*) as total_customers,
    SUM(f.churned) as churned_customers,
    ROUND(AVG(f.churned) * 100, 2) as churn_rate_percent,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_charges,
    ROUND(AVG(f.tenure_months), 1) as avg_tenure_months
FROM fact_churn f
JOIN dim_billing b ON f.billing_key = b.billing_key
GROUP BY b.contract_type
ORDER BY churn_rate_percent DESC;

-- View: Revenue Analysis
CREATE OR REPLACE VIEW vw_revenue_analysis AS
SELECT 
    d.year,
    d.quarter,
    SUM(f.monthly_charges) as total_monthly_revenue,
    SUM(f.total_charges) as total_revenue,
    COUNT(*) as total_customers,
    ROUND(AVG(f.monthly_charges), 2) as avg_revenue_per_customer
FROM fact_churn f
JOIN dim_date d ON f.billing_date_key = d.date_key
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- View: High-Risk Customer Profile
CREATE OR REPLACE VIEW vw_high_risk_profile AS
SELECT 
    c.customer_segment,
    s.internet_service,
    b.contract_type,
    COUNT(*) as customer_count,
    ROUND(AVG(f.churn_probability), 4) as avg_churn_probability,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_charges
FROM fact_churn f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_service s ON f.service_key = s.service_key
JOIN dim_billing b ON f.billing_key = b.billing_key
WHERE f.churn_risk_score >= 7
GROUP BY c.customer_segment, s.internet_service, b.contract_type
ORDER BY avg_churn_probability DESC;

-- ============================================================================
-- SCHEMA SUMMARY
-- ============================================================================
/*
STAR SCHEMA DESIGN:

FACT TABLE (1):
- fact_churn: Central fact table with measures

DIMENSION TABLES (4):
- dim_customer: Customer demographics
- dim_service: Service subscriptions
- dim_billing: Billing and contracts
- dim_date: Time dimension

MEASURES IN FACT TABLE:
- tenure_months
- monthly_charges
- total_charges
- avg_monthly_charges
- churned (0/1)
- churn_probability
- churn_risk_score
- total_revenue
- customer_lifetime_value

GRAIN: One row per customer billing record
*/

COMMIT;
