# 📸 Dashboard Screenshots Guide

All screenshots should be captured at **1920×1080 resolution** in the dashboard's dark theme.

---

## Screenshot List

### screenshot_01_overview_tab.png
**Tab:** Executive Overview  
**Content:** Full page showing 6 KPI cards (Churn Rate 26.54%, Retention 73.46%, Avg Charge $64.76, Avg Tenure 37.6mo, M2M Churn 42.71%, Fiber Churn 41.89%), tenure cohort bar chart (green→red gradient), and churn distribution donut chart (teal=retained, coral=churned).

---

### screenshot_02_etl_warehouse.png
**Tab:** ETL & Data Warehouse  
**Content:** Star schema diagram showing FACT_CHURN at centre connected to 4 dimension tables. Data quality table showing before/after ETL metrics (11 nulls fixed, type conversions). Pipeline flow cards (Extract → Clean → Transform → Load → Validate).

---

### screenshot_03_churn_analysis.png
**Tab:** Churn Factor Analysis  
**Content:** Payment method horizontal bar chart (Electronic Check 45.29% highlighted in red). Grouped bar chart showing add-on services with/without churn rates. Feature importance horizontal bar (Total Charges 18.68% top). Monthly charges area chart (red=churned peak $74-$100 range, teal=retained).

---

### screenshot_04_segmentation.png
**Tab:** Customer Segmentation  
**Content:** Risk matrix table with 10 rows — colour-coded badges (CRITICAL=red, HIGH=amber, LOW=teal, SAFE=green) and horizontal risk bars. Radar chart showing 8-dimension risk profile with churned segments far outside baseline ring.

---

### screenshot_05_models.png
**Tab:** Predictive Models  
**Content:** 4 model cards (LR★ in teal, DT in green, RF in amber, GB in violet) each showing 5 metrics. Grouped bar chart comparing all 4 models across accuracy/AUC/precision/recall/F1. 4-cell confusion matrix for Logistic Regression (TN=920, FP=115, FN=169, TP=205).

---

### screenshot_06_recommendations.png
**Tab:** Retention Recommendations  
**Content:** 6 recommendation cards with priority badges (🔴🔴🟡🟡🔵🟢) and projected impact figures. Bottom row: 4 summary KPIs (Churn Reduction −8-12%, Customers Saved 563-845, Revenue Protected $504K+, Model Confidence 84.03%).

---

### screenshot_07_mobile_view.png
**View:** Mobile layout (390×844)  
**Content:** Responsive mobile layout showing stacked KPI cards and simplified chart view.

---

## Capture Instructions

```bash
# Method 1: Power BI Desktop built-in
# File → Export → Export to PDF (all pages)

# Method 2: Browser screenshot (Power BI Service)
# Use browser DevTools → Capture full page

# Method 3: Windows Snipping Tool
# Win + Shift + S → Rectangular selection → Save to dashboards/screenshots/
```

## Naming Convention
```
screenshot_NN_descriptive_name.png
```
All files in: `dashboards/screenshots/`
