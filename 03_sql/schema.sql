-- TELECOM CHURN PROJECT - OLTP SCHEMA
-- Ready for PostgreSQL Execution

BEGIN;

-- ============================================================================
-- TELECOM CHURN OLTP DATABASE SCHEMA
-- Normalized relational schema with constraints
-- ============================================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS churn_records CASCADE;
DROP TABLE IF EXISTS service_subscriptions CASCADE;
DROP TABLE IF EXISTS billing_info CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS service_catalog CASCADE;

-- ============================================================================
-- TABLE: customers
-- Core customer demographic information
-- ============================================================================
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
    senior_citizen BOOLEAN DEFAULT FALSE,
    partner BOOLEAN DEFAULT FALSE,
    dependents BOOLEAN DEFAULT FALSE,
    created_date DATE DEFAULT CURRENT_DATE,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster lookups
CREATE INDEX idx_customers_senior ON customers(senior_citizen);
CREATE INDEX idx_customers_created ON customers(created_date);

-- ============================================================================
-- TABLE: billing_info
-- Customer billing and contract information
-- ============================================================================
CREATE TABLE billing_info (
    billing_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    contract_type VARCHAR(20) CHECK (contract_type IN ('Month-to-month', 'One year', 'Two year')),
    payment_method VARCHAR(30) CHECK (payment_method IN (
        'Electronic check', 
        'Mailed check', 
        'Bank transfer (automatic)', 
        'Credit card (automatic)'
    )),
    paperless_billing BOOLEAN DEFAULT FALSE,
    monthly_charges DECIMAL(10, 2) CHECK (monthly_charges >= 0),
    total_charges DECIMAL(10, 2) CHECK (total_charges >= 0),
    tenure_months INTEGER CHECK (tenure_months >= 0),
    billing_start_date DATE,
    
    -- Foreign key
    CONSTRAINT fk_billing_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_billing_customer ON billing_info(customer_id);
CREATE INDEX idx_billing_contract ON billing_info(contract_type);
CREATE INDEX idx_billing_tenure ON billing_info(tenure_months);

-- ============================================================================
-- TABLE: service_catalog
-- Available services catalog
-- ============================================================================
CREATE TABLE service_catalog (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(50) NOT NULL UNIQUE,
    service_category VARCHAR(30) CHECK (service_category IN (
        'Phone', 'Internet', 'Security', 'Entertainment', 'Support'
    )),
    description TEXT,
    base_price DECIMAL(8, 2)
);

-- Insert service catalog data
INSERT INTO service_catalog (service_name, service_category, base_price) VALUES
('Phone Service', 'Phone', 10.00),
('Multiple Lines', 'Phone', 5.00),
('DSL Internet', 'Internet', 20.00),
('Fiber Optic Internet', 'Internet', 30.00),
('Online Security', 'Security', 5.00),
('Online Backup', 'Security', 5.00),
('Device Protection', 'Security', 5.00),
('Tech Support', 'Support', 5.00),
('Streaming TV', 'Entertainment', 10.00),
('Streaming Movies', 'Entertainment', 10.00);

-- ============================================================================
-- TABLE: service_subscriptions
-- Customer service subscriptions (many-to-many relationship)
-- ============================================================================
CREATE TABLE service_subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    service_id INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    subscription_date DATE DEFAULT CURRENT_DATE,
    
    -- Foreign keys
    CONSTRAINT fk_subscription_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_subscription_service 
        FOREIGN KEY (service_id) 
        REFERENCES service_catalog(service_id),
    
    -- Unique constraint to prevent duplicate subscriptions
    CONSTRAINT unique_customer_service 
        UNIQUE (customer_id, service_id)
);

-- Indexes
CREATE INDEX idx_subscriptions_customer ON service_subscriptions(customer_id);
CREATE INDEX idx_subscriptions_service ON service_subscriptions(service_id);
CREATE INDEX idx_subscriptions_active ON service_subscriptions(is_active);

-- ============================================================================
-- TABLE: churn_records
-- Customer churn tracking
-- ============================================================================
CREATE TABLE churn_records (
    churn_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL UNIQUE,
    churned BOOLEAN DEFAULT FALSE,
    churn_date DATE,
    churn_reason VARCHAR(100),
    predicted_churn_probability DECIMAL(5, 4) CHECK (
        predicted_churn_probability BETWEEN 0 AND 1
    ),
    risk_score VARCHAR(10) CHECK (risk_score IN ('Low', 'Medium', 'High')),
    
    -- Foreign key
    CONSTRAINT fk_churn_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_churn_customer ON churn_records(customer_id);
CREATE INDEX idx_churn_status ON churn_records(churned);
CREATE INDEX idx_churn_risk ON churn_records(risk_score);

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Customer Complete Profile
CREATE OR REPLACE VIEW vw_customer_profile AS
SELECT 
    c.customer_id,
    c.gender,
    c.senior_citizen,
    c.partner,
    c.dependents,
    b.contract_type,
    b.payment_method,
    b.monthly_charges,
    b.total_charges,
    b.tenure_months,
    ch.churned,
    ch.risk_score,
    COUNT(DISTINCT s.service_id) as total_services
FROM customers c
LEFT JOIN billing_info b ON c.customer_id = b.customer_id
LEFT JOIN churn_records ch ON c.customer_id = ch.customer_id
LEFT JOIN service_subscriptions s ON c.customer_id = s.customer_id AND s.is_active = TRUE
GROUP BY 
    c.customer_id, c.gender, c.senior_citizen, c.partner, c.dependents,
    b.contract_type, b.payment_method, b.monthly_charges, b.total_charges, 
    b.tenure_months, ch.churned, ch.risk_score;

-- View: High-Risk Customers
CREATE OR REPLACE VIEW vw_high_risk_customers AS
SELECT 
    customer_id,
    monthly_charges,
    tenure_months,
    contract_type,
    total_services,
    risk_score
FROM vw_customer_profile
WHERE risk_score = 'High' AND churned = FALSE;

-- ============================================================================
-- SAMPLE DATA INSERTION (for testing)
-- ============================================================================

-- Insert sample customers
INSERT INTO customers (customer_id, gender, senior_citizen, partner, dependents) VALUES
('CUST000001', 'Male', FALSE, TRUE, FALSE),
('CUST000002', 'Female', TRUE, FALSE, FALSE),
('CUST000003', 'Male', FALSE, TRUE, TRUE);

-- Insert billing info
INSERT INTO billing_info (customer_id, contract_type, payment_method, paperless_billing, 
                          monthly_charges, total_charges, tenure_months, billing_start_date) VALUES
('CUST000001', 'Month-to-month', 'Electronic check', TRUE, 85.50, 1026.00, 12, '2023-01-15'),
('CUST000002', 'Two year', 'Credit card (automatic)', FALSE, 95.00, 3800.00, 40, '2021-06-01'),
('CUST000003', 'One year', 'Bank transfer (automatic)', TRUE, 75.25, 451.50, 6, '2024-05-20');

-- Insert churn records
INSERT INTO churn_records (customer_id, churned, churn_date, risk_score, predicted_churn_probability) VALUES
('CUST000001', FALSE, NULL, 'High', 0.7543),
('CUST000002', FALSE, NULL, 'Low', 0.1234),
('CUST000003', FALSE, NULL, 'Medium', 0.4567);

-- ============================================================================
-- CONSTRAINTS SUMMARY
-- ============================================================================
/*
PRIMARY KEYS:
- customers.customer_id
- billing_info.billing_id
- service_catalog.service_id
- service_subscriptions.subscription_id
- churn_records.churn_id

FOREIGN KEYS:
- billing_info.customer_id -> customers.customer_id
- service_subscriptions.customer_id -> customers.customer_id
- service_subscriptions.service_id -> service_catalog.service_id
- churn_records.customer_id -> customers.customer_id

CHECK CONSTRAINTS:
- Gender values
- Contract types
- Payment methods
- Service categories
- Numeric ranges (charges >= 0, probability 0-1)
- Risk scores

UNIQUE CONSTRAINTS:
- service_catalog.service_name
- service_subscriptions(customer_id, service_id)
- churn_records.customer_id
*/

COMMIT;
