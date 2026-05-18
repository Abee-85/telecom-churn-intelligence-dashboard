# 📊 Power BI Dashboard Documentation
## Telecom Customer Churn Intelligence Dashboard

**Tool:** Microsoft Power BI Desktop  
**Theme:** Dark telecom (custom JSON theme)  
**Pages:** 6 tabs  
**Dataset:** IBM Telco Customer Churn (7,043 records)

---

## 🎨 Design Theme

```json
{
  "name": "Telecom Churn Dark",
  "dataColors": ["#2dd4bf","#fb7185","#f59e0b","#86efac","#a78bfa","#fbbf24"],
  "background": "#0d0f0d",
  "foreground": "#e8f0e8",
  "tableAccent": "#2dd4bf"
}
```

| Token | Hex | Usage |
|-------|-----|-------|
| Teal `--teal` | `#2dd4bf` | Primary accent, retained KPIs |
| Coral `--coral` | `#fb7185` | Churn / risk indicators |
| Amber `--amber` | `#f59e0b` | Secondary / medium risk |
| Sage `--sage` | `#86efac` | Positive / safe segments |
| Violet `--violet` | `#a78bfa` | Tertiary / ML model colour |
| Background | `#0d0f0d` | Page background |

---

## 📄 Dashboard Pages

### Page 1 — Executive Overview

**Purpose:** High-level KPI summary for C-suite and management

**KPI Cards (Row 1):**
| Card | Value | Colour |
|------|-------|--------|
| Overall Churn Rate | 26.54% | Coral |
| Retention Rate | 73.46% | Sage |
| Avg Monthly Charge | $64.76 | Amber |
| Avg Retained Tenure | 37.6 mo | Teal |
| Month-to-Month Churn | 42.71% | Coral |
| Fiber Optic Churn | 41.89% | Violet |

**Charts:**
- Clustered bar: Churn by Tenure Cohort (4 bars)
- Donut: Churned vs Retained (2 slices)
- Clustered bar: Churn by Contract Type (3 bars)
- Clustered bar: Churn by Internet Service (3 bars)

**Slicers:** Contract Type · Internet Service · Senior Citizen

---

### Page 2 — ETL & Data Warehouse

**Purpose:** Data engineering transparency for technical stakeholders

**Visuals:**
- Star schema diagram (image visual)
- Table: Data quality metrics (before / after ETL)
- Funnel: Customer retention lifecycle
- Card: Total Records Loaded · Null Values Fixed · ETL Status

---

### Page 3 — Churn Factor Analysis

**Purpose:** Deep-dive into churn drivers across all dimensions

**Charts:**
- Bar: Churn rate by PaymentMethod (4 bars)
- Grouped bar: Add-on services vs churn (with/without pairs)
- Bar: Demographic churn comparison (10 bars)
- Horizontal bar: Feature Importance Top 10
- Area chart: Monthly charges distribution (Churned vs Retained)

**Slicers:** Gender · Senior Citizen · Has Partner · Has Dependents

---

### Page 4 — Customer Segmentation

**Purpose:** Risk segmentation matrix and cohort analysis

**Visuals:**
- Matrix table: Segment → Churn Rate → Risk Badge → Risk Bar
- Line chart: Churn rate trend by tenure cohort
- Radar/Spider: Multi-dimensional risk profile (8 axes)
- Scatter: Tenure vs Monthly Charges coloured by Churn

---

### Page 5 — Predictive Models

**Purpose:** ML model performance comparison

**Visuals:**
- 4 model cards: Accuracy · AUC-ROC · Precision · Recall · F1
- Grouped bar: All metrics across 4 models
- Confusion matrix (4-cell table visual)
- ROC curve comparison (line chart with 4 series)
- Bar: AUC-ROC ranking

**Slicers:** Model selector

---

### Page 6 — Retention Recommendations

**Purpose:** Evidence-based action items for retention managers

**Visuals:**
- 6 recommendation cards (text + impact metric)
- KPI row: Projected churn reduction · Customers saved · Revenue protected
- Waterfall: Cumulative churn reduction by strategy

---

## 📐 DAX Measures

```dax
-- Overall Churn Rate
Churn Rate =
DIVIDE(
    CALCULATE(COUNTROWS(FACT_CHURN), FACT_CHURN[churn_flag] = 1),
    COUNTROWS(FACT_CHURN)
)

-- Retention Rate
Retention Rate =
1 - [Churn Rate]

-- Average Monthly Charge
Avg Monthly Charge =
AVERAGE(FACT_CHURN[monthly_charges])

-- Churned Customer Avg Charge
Churned Avg Charge =
CALCULATE(
    AVERAGE(FACT_CHURN[monthly_charges]),
    FACT_CHURN[churn_flag] = 1
)

-- Revenue at Risk (monthly)
Revenue at Risk =
CALCULATE(
    SUMX(FACT_CHURN, FACT_CHURN[monthly_charges]),
    FACT_CHURN[churn_flag] = 1
)

-- Churn Rate by Contract
Churn Rate by Contract =
CALCULATE(
    [Churn Rate],
    ALLEXCEPT(DIM_CONTRACT, DIM_CONTRACT[contract_type])
)

-- Month-to-Month Churn Rate
M2M Churn Rate =
CALCULATE(
    [Churn Rate],
    DIM_CONTRACT[contract_type] = "Month-to-month"
)

-- New Customer Churn (0-12 mo)
New Customer Churn =
CALCULATE(
    [Churn Rate],
    DIM_DATE[tenure_bucket] = "0-12 mo"
)

-- High Risk Customer Count (probability > 0.6)
High Risk Count =
CALCULATE(
    COUNTROWS(FACT_CHURN),
    FACT_CHURN[churn_probability] > 0.6
)

-- Projected Revenue Protected (conservative)
Projected Revenue Protected =
[Revenue at Risk] * 0.27

-- Tenure Cohort Churn Rate (for trend line)
Cohort Churn Rate =
CALCULATE(
    [Churn Rate],
    ALLEXCEPT(DIM_DATE, DIM_DATE[tenure_bucket])
)
```

---

## 🔌 Data Model Relationships

```
DIM_CUSTOMER  (1) ──── (M)  FACT_CHURN
DIM_CONTRACT  (1) ──── (M)  FACT_CHURN
DIM_SERVICE   (1) ──── (M)  FACT_CHURN
DIM_DATE      (1) ──── (M)  FACT_CHURN
```

All relationships: single-direction filter flow from dimension → fact table.  
Join type: Inner join on surrogate keys.

---

## 📁 Power BI File Structure

```
dashboards/powerbi/
├── TelecomChurnDashboard.pbix     # Main Power BI file
├── dashboard_documentation.md    # This file
├── theme_telecom_dark.json        # Custom colour theme
└── dax_measures_reference.txt    # All DAX measures
```

---

## 🚀 Publishing Steps

1. Open `TelecomChurnDashboard.pbix` in Power BI Desktop
2. Refresh data source → point to `data/processed/cleaned_churn_data.csv`
3. Apply custom theme: View → Themes → Browse → `theme_telecom_dark.json`
4. Publish: Home → Publish → Select workspace
5. Set scheduled refresh in Power BI Service (daily recommended)
