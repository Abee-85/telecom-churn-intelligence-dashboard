-- TELECOM CHURN PROJECT - ETL QUERIES
-- Ready for PostgreSQL Execution

-- EXECUTION ORDER:
-- 1. schema.sql
-- 2. star_schema.sql
-- 3. etl_queries.sql

BEGIN;

-- ============================================================================
-- TELECOM CHURN - ETL QUERIES & ANALYTICAL QUERIES
-- ETL: Load data from OLTP to Data Warehouse
-- Analytics: 6 business intelligence queries
-- ============================================================================

-- ============================================================================
-- PART 1: ETL QUERIES - LOAD DATA FROM OLTP TO STAR SCHEMA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ETL 1: Load dim_customer from OLTP
-- ----------------------------------------------------------------------------
INSERT INTO dim_customer (customer_id, gender, age_group, senior_citizen, partner, 
                          dependents, customer_segment)
SELECT 
    c.customer_id,
    c.gender,
    CASE 
        WHEN c.senior_citizen = TRUE THEN '65+'
        ELSE 'Under 65'
    END as age_group,
    CASE WHEN c.senior_citizen THEN 'Yes' ELSE 'No' END as senior_citizen,
    CASE WHEN c.partner THEN 'Yes' ELSE 'No' END as partner,
    CASE WHEN c.dependents THEN 'Yes' ELSE 'No' END as dependents,
    CASE 
        WHEN c.senior_citizen = TRUE THEN 'Senior'
        WHEN c.partner = TRUE AND c.dependents = TRUE THEN 'Family'
        WHEN c.partner = TRUE THEN 'Couple'
        ELSE 'Individual'
    END as customer_segment
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer dc WHERE dc.customer_id = c.customer_id
);

-- ----------------------------------------------------------------------------
-- ETL 2: Load dim_billing from OLTP
-- ----------------------------------------------------------------------------
INSERT INTO dim_billing (contract_type, payment_method, paperless_billing, 
                         tenure_group, monthly_charge_range, contract_category)
SELECT DISTINCT
    b.contract_type,
    b.payment_method,
    CASE WHEN b.paperless_billing THEN 'Yes' ELSE 'No' END as paperless_billing,
    CASE 
        WHEN b.tenure_months BETWEEN 0 AND 12 THEN '0-12 months'
        WHEN b.tenure_months BETWEEN 13 AND 24 THEN '12-24 months'
        WHEN b.tenure_months BETWEEN 25 AND 48 THEN '24-48 months'
        ELSE '48+ months'
    END as tenure_group,
    CASE 
        WHEN b.monthly_charges < 35 THEN 'Low ($0-35)'
        WHEN b.monthly_charges < 70 THEN 'Medium ($35-70)'
        ELSE 'High ($70+)'
    END as monthly_charge_range,
    CASE 
        WHEN b.contract_type = 'Month-to-month' AND b.monthly_charges >= 70 THEN 'Short-term High-value'
        WHEN b.contract_type IN ('One year', 'Two year') AND b.tenure_months >= 24 THEN 'Long-term Loyal'
        WHEN b.contract_type = 'One year' THEN 'Mid-term Moderate'
        ELSE 'Short-term Low-value'
    END as contract_category
FROM billing_info b
WHERE NOT EXISTS (
    SELECT 1 FROM dim_billing db 
    WHERE db.contract_type = b.contract_type 
    AND db.payment_method = b.payment_method
);

-- ----------------------------------------------------------------------------
-- ETL 3: Load dim_service from OLTP
-- ----------------------------------------------------------------------------
WITH service_summary AS (
    SELECT 
        s.customer_id,
        MAX(CASE WHEN sc.service_name = 'Phone Service' THEN 'Yes' ELSE 'No' END) as phone_service,
        MAX(CASE WHEN sc.service_name = 'Multiple Lines' THEN 'Yes' ELSE 'No' END) as multiple_lines,
        MAX(CASE WHEN sc.service_name LIKE '%Internet%' THEN sc.service_name ELSE 'No' END) as internet_service,
        MAX(CASE WHEN sc.service_name = 'Online Security' THEN 'Yes' ELSE 'No internet' END) as online_security,
        MAX(CASE WHEN sc.service_name = 'Online Backup' THEN 'Yes' ELSE 'No internet' END) as online_backup,
        MAX(CASE WHEN sc.service_name = 'Device Protection' THEN 'Yes' ELSE 'No internet' END) as device_protection,
        MAX(CASE WHEN sc.service_name = 'Tech Support' THEN 'Yes' ELSE 'No internet' END) as tech_support,
        MAX(CASE WHEN sc.service_name = 'Streaming TV' THEN 'Yes' ELSE 'No' END) as streaming_tv,
        MAX(CASE WHEN sc.service_name = 'Streaming Movies' THEN 'Yes' ELSE 'No' END) as streaming_movies,
        COUNT(DISTINCT s.service_id) as total_services
    FROM service_subscriptions s
    JOIN service_catalog sc ON s.service_id = sc.service_id
    WHERE s.is_active = TRUE
    GROUP BY s.customer_id
)
INSERT INTO dim_service (phone_service, multiple_lines, internet_service, online_security,
                         online_backup, device_protection, tech_support, streaming_tv,
                         streaming_movies, total_services, service_bundle_type)
SELECT DISTINCT
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    total_services,
    CASE 
        WHEN total_services >= 6 THEN 'Premium Bundle'
        WHEN internet_service != 'No' AND (streaming_tv = 'Yes' OR streaming_movies = 'Yes') THEN 'Internet + Entertainment'
        WHEN online_security = 'Yes' AND online_backup = 'Yes' THEN 'Full Protection'
        WHEN internet_service != 'No' THEN 'Internet Basic'
        ELSE 'Phone Only'
    END as service_bundle_type
FROM service_summary;

-- ----------------------------------------------------------------------------
-- ETL 4: Load fact_churn from OLTP to Data Warehouse
-- ----------------------------------------------------------------------------
INSERT INTO fact_churn (customer_key, service_key, billing_key, churn_date_key, 
                        billing_date_key, tenure_months, monthly_charges, total_charges,
                        avg_monthly_charges, churned, churn_probability, churn_risk_score,
                        total_revenue, customer_lifetime_value, months_to_churn)
SELECT 
    dc.customer_key,
    ds.service_key,
    db.billing_key,
    CASE WHEN ch.churned THEN TO_CHAR(ch.churn_date, 'YYYYMMDD')::INTEGER ELSE NULL END as churn_date_key,
    TO_CHAR(b.billing_start_date, 'YYYYMMDD')::INTEGER as billing_date_key,
    b.tenure_months,
    b.monthly_charges,
    b.total_charges,
    CASE WHEN b.tenure_months > 0 THEN b.total_charges / b.tenure_months ELSE b.monthly_charges END as avg_monthly_charges,
    CASE WHEN ch.churned THEN 1 ELSE 0 END as churned,
    ch.predicted_churn_probability,
    CASE 
        WHEN ch.risk_score = 'High' THEN 8
        WHEN ch.risk_score = 'Medium' THEN 5
        ELSE 2
    END as churn_risk_score,
    b.total_charges as total_revenue,
    b.monthly_charges * 24 as customer_lifetime_value,
    CASE WHEN ch.churned THEN b.tenure_months ELSE NULL END as months_to_churn
FROM customers c
JOIN dim_customer dc ON c.customer_id = dc.customer_id
JOIN billing_info b ON c.customer_id = b.customer_id
JOIN dim_billing db ON b.contract_type = db.contract_type AND b.payment_method = db.payment_method
LEFT JOIN churn_records ch ON c.customer_id = ch.customer_id
CROSS JOIN LATERAL (
    SELECT service_key 
    FROM dim_service 
    LIMIT 1
) ds
WHERE NOT EXISTS (
    SELECT 1 FROM fact_churn f 
    WHERE f.customer_key = dc.customer_key
);

-- ============================================================================
-- PART 2: ANALYTICAL QUERIES - 6 BUSINESS INTELLIGENCE QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: Churn Rate Analysis by Contract Type and Payment Method
-- Business Question: Which contract and payment combinations have highest churn?
-- ----------------------------------------------------------------------------
SELECT 
    db.contract_type,
    db.payment_method,
    COUNT(*) as total_customers,
    SUM(f.churned) as churned_customers,
    ROUND(AVG(f.churned) * 100, 2) as churn_rate_percent,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_charges,
    ROUND(AVG(f.tenure_months), 1) as avg_tenure_months,
    ROUND(SUM(f.total_revenue), 2) as total_revenue_lost
FROM fact_churn f
JOIN dim_billing db ON f.billing_key = db.billing_key
GROUP BY db.contract_type, db.payment_method
ORDER BY churn_rate_percent DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- QUERY 2: Revenue Analysis by Customer Segment and Time Period
-- Business Question: What is the revenue trend across customer segments?
-- ----------------------------------------------------------------------------
SELECT 
    d.year,
    d.quarter,
    dc.customer_segment,
    COUNT(DISTINCT f.customer_key) as total_customers,
    ROUND(SUM(f.monthly_charges), 2) as total_monthly_revenue,
    ROUND(AVG(f.monthly_charges), 2) as avg_revenue_per_customer,
    ROUND(SUM(f.total_revenue), 2) as lifetime_revenue,
    SUM(f.churned) as churned_count
FROM fact_churn f
JOIN dim_customer dc ON f.customer_key = dc.customer_key
JOIN dim_date d ON f.billing_date_key = d.date_key
GROUP BY d.year, d.quarter, dc.customer_segment
ORDER BY d.year DESC, d.quarter DESC, total_monthly_revenue DESC;

-- ----------------------------------------------------------------------------
-- QUERY 3: High-Risk Customer Identification
-- Business Question: Who are our high-risk customers we should retain?
-- ----------------------------------------------------------------------------
SELECT 
    dc.customer_id,
    dc.customer_segment,
    ds.internet_service,
    ds.service_bundle_type,
    db.contract_type,
    f.tenure_months,
    f.monthly_charges,
    f.total_revenue,
    f.churn_probability,
    CASE 
        WHEN f.churn_risk_score >= 7 THEN 'High Risk'
        WHEN f.churn_risk_score >= 4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category
FROM fact_churn f
JOIN dim_customer dc ON f.customer_key = dc.customer_key
JOIN dim_service ds ON f.service_key = ds.service_key
JOIN dim_billing db ON f.billing_key = db.billing_key
WHERE f.churned = 0 
AND f.churn_risk_score >= 7
AND f.monthly_charges > 50
ORDER BY f.churn_probability DESC, f.monthly_charges DESC
LIMIT 50;

-- ----------------------------------------------------------------------------
-- QUERY 4: Service Bundle Performance Analysis
-- Business Question: Which service bundles have best retention?
-- ----------------------------------------------------------------------------
SELECT 
    ds.service_bundle_type,
    ds.internet_service,
    ds.total_services,
    COUNT(*) as total_customers,
    SUM(f.churned) as churned_customers,
    ROUND(AVG(f.churned) * 100, 2) as churn_rate_percent,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_revenue,
    ROUND(AVG(f.tenure_months), 1) as avg_tenure_months,
    ROUND(AVG(f.customer_lifetime_value), 2) as avg_customer_ltv
FROM fact_churn f
JOIN dim_service ds ON f.service_key = ds.service_key
GROUP BY ds.service_bundle_type, ds.internet_service, ds.total_services
ORDER BY churn_rate_percent ASC, avg_customer_ltv DESC;

-- ----------------------------------------------------------------------------
-- QUERY 5: Tenure Impact on Churn and Revenue
-- Business Question: How does tenure affect churn and revenue?
-- ----------------------------------------------------------------------------
SELECT 
    db.tenure_group,
    COUNT(*) as total_customers,
    SUM(f.churned) as churned_customers,
    ROUND(AVG(f.churned) * 100, 2) as churn_rate_percent,
    ROUND(AVG(f.tenure_months), 1) as avg_tenure_months,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_charges,
    ROUND(SUM(f.total_revenue), 2) as total_revenue,
    ROUND(AVG(f.customer_lifetime_value), 2) as avg_lifetime_value,
    ROUND(AVG(f.churn_probability), 4) as avg_churn_probability
FROM fact_churn f
JOIN dim_billing db ON f.billing_key = db.billing_key
GROUP BY db.tenure_group
ORDER BY 
    CASE db.tenure_group
        WHEN '0-12 months' THEN 1
        WHEN '12-24 months' THEN 2
        WHEN '24-48 months' THEN 3
        WHEN '48+ months' THEN 4
    END;

-- ----------------------------------------------------------------------------
-- QUERY 6: Monthly Cohort Analysis - Revenue Retention
-- Business Question: What is the revenue retention pattern by billing month?
-- ----------------------------------------------------------------------------
WITH monthly_cohorts AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        COUNT(DISTINCT f.customer_key) as new_customers,
        ROUND(SUM(f.monthly_charges), 2) as monthly_revenue,
        ROUND(AVG(f.monthly_charges), 2) as avg_revenue_per_customer,
        SUM(CASE WHEN f.churned = 1 THEN 1 ELSE 0 END) as churned_in_month,
        ROUND(AVG(CASE WHEN f.churned = 1 THEN f.tenure_months ELSE NULL END), 1) as avg_tenure_at_churn
    FROM fact_churn f
    JOIN dim_date d ON f.billing_date_key = d.date_key
    GROUP BY d.year, d.month, d.month_name
)
SELECT 
    year,
    month,
    month_name,
    new_customers,
    monthly_revenue,
    avg_revenue_per_customer,
    churned_in_month,
    ROUND((churned_in_month::DECIMAL / NULLIF(new_customers, 0)) * 100, 2) as churn_rate_percent,
    avg_tenure_at_churn,
    SUM(monthly_revenue) OVER (PARTITION BY year ORDER BY month) as cumulative_yearly_revenue
FROM monthly_cohorts
ORDER BY year DESC, month DESC
LIMIT 24;

-- ============================================================================
-- ADDITIONAL UTILITY QUERIES
-- ============================================================================

-- Query: Customer Lifetime Value by Segment
SELECT 
    dc.customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(f.customer_lifetime_value), 2) as avg_ltv,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_revenue,
    ROUND(AVG(f.tenure_months), 1) as avg_tenure,
    ROUND(AVG(f.churn_probability), 4) as avg_churn_risk
FROM fact_churn f
JOIN dim_customer dc ON f.customer_key = dc.customer_key
WHERE f.churned = 0
GROUP BY dc.customer_segment
ORDER BY avg_ltv DESC;

-- Query: Top Revenue Generating Services
SELECT 
    ds.service_bundle_type,
    COUNT(*) as customer_count,
    ROUND(SUM(f.total_revenue), 2) as total_revenue,
    ROUND(AVG(f.monthly_charges), 2) as avg_monthly_charges,
    ROUND(AVG(f.churned) * 100, 2) as churn_rate_percent
FROM fact_churn f
JOIN dim_service ds ON f.service_key = ds.service_key
GROUP BY ds.service_bundle_type
ORDER BY total_revenue DESC;

-- ============================================================================
-- SUMMARY OF QUERIES
-- ============================================================================
/*
ETL QUERIES (4):
1. Load dim_customer from OLTP customers table
2. Load dim_billing from OLTP billing_info table
3. Load dim_service from OLTP service_subscriptions table
4. Load fact_churn from OLTP (combines all sources)

ANALYTICAL QUERIES (6):
1. Churn Rate by Contract & Payment Method
2. Revenue Analysis by Segment & Time
3. High-Risk Customer Identification
4. Service Bundle Performance
5. Tenure Impact on Churn
6. Monthly Cohort Revenue Retention

INSIGHTS GENERATED:
- Retention patterns
- Revenue trends
- Customer segmentation
- Risk profiling
- Service effectiveness
- Cohort behavior
*/

COMMIT;
