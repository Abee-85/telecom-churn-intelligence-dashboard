# 📸 Dashboard Screenshots Documentation

## Screenshot Inventory

Each screenshot documents a specific dashboard tab. Replace placeholder descriptions with actual screenshots captured from the deployed dashboard.

---

### Fig 1.1 — Executive Overview Tab
**File:** `docs/screenshots/fig_1_1_overview.png`  
**Resolution:** 1920 × 1080  
**Description:** Dark-mode dashboard header showing logo "Churn Intelligence · Telecom BI Platform v3.0" and live indicator. Six KPI cards in a responsive grid: Overall Churn Rate (26.54% in coral), Retention Rate (73.46% in sage), Avg Monthly Charge ($64.76 in amber), Avg Tenure Retained (37.6 mo in teal), M2M Contract Churn (42.71% in coral), Fiber Optic Churn (41.89% in violet). Second row: tenure cohort bar chart and churn donut chart. Third row: contract type bar and internet service bar.

---

### Fig 1.2 — ETL & Warehouse Tab
**File:** `docs/screenshots/fig_1_2_etl.png`  
**Description:** Five-step pipeline cards (Extract → Clean → Transform → Load → Validate) with arrow connectors. Star schema diagram with FACT_CHURN at centre connected to 4 dimension tables (field names visible). Data quality table showing 6 checks all marked PASS in green.

---

### Fig 1.3 — Churn Factor Analysis Tab
**File:** `docs/screenshots/fig_1_3_analysis.png`  
**Description:** Four-chart grid: payment method bar (Electronic Check 45.29% highlighted red), add-on services grouped bar (With=teal, Without=coral), demographic comparison bar, feature importance horizontal bar (Total Charges 18.68% top). Full-width monthly charges area chart at bottom.

---

### Fig 1.4 — Customer Segmentation Tab
**File:** `docs/screenshots/fig_1_4_segmentation.png`  
**Description:** Ten-row risk matrix table with colour-coded badge labels (CRITICAL/HIGH/LOW/SAFE) and horizontal risk progress bars. Two-chart row: tenure cohort line chart (exponential decay from 47.68% → 9.51%) and eight-axis radar chart showing high-risk segments far outside baseline ring.

---

### Fig 1.5 — Predictive Models Tab
**File:** `docs/screenshots/fig_1_5_models.png`  
**Description:** Four model cards in top row (LR★ in teal, DT in sage, RF in amber, GB in violet) each showing 5 metrics. AUC-ROC horizontal comparison bars. Grouped performance bar chart. 2×2 confusion matrix cells (TN=920 green, FP=115 amber, FN=169 red, TP=205 teal).

---

### Fig 1.6 — Recommendations Tab
**File:** `docs/screenshots/fig_1_6_recommendations.png`  
**Description:** 2×3 grid of recommendation cards with left-border colour coding (🔴🔴🟡🟡🔵🟢). Each card shows priority badge, strategy title, body text, and projected impact metric. Bottom row: 4 impact KPI cards (Churn Reduction, Customers Saved, Revenue Protected, Model Confidence).

---

### Fig 2.1 — Feature Importance Chart
**File:** `docs/screenshots/fig_2_1_feature_importance.png`  
**Description:** Horizontal bar chart of top 15 Random Forest feature importances. TotalCharges (18.68%), MonthlyCharges (17.92%), tenure (15.43%) dominate. Contract and payment features in middle tier. Demographic features at bottom. Teal gradient bars on dark background.

---

### Fig 2.2 — ROC Curve Comparison
**File:** `docs/screenshots/fig_2_2_roc_curves.png`  
**Description:** Four overlapping ROC curves on white background. Gradient Boosting (violet, AUC=0.845) and Logistic Regression (teal, AUC=0.840) nearly identical at top. Random Forest (amber, AUC=0.822) close behind. Decision Tree (sage, AUC=0.668) clearly lower. Diagonal random-chance reference line (dashed).

---

### Fig 2.3 — Confusion Matrix (Logistic Regression)
**File:** `docs/screenshots/fig_2_3_confusion_matrix.png`  
**Description:** 2×2 matrix. TN=920 (correctly retained, green cell), FP=115 (false alarm, amber cell), FN=169 (missed churner, red cell), TP=205 (correctly caught churner, teal cell). Total test set = 1,409.

---

## Capture Commands

```bash
# Using matplotlib savefig (programmatic)
python -c "
from src.visualization.charts import ChurnVisualizer
from src.utils.config import Config
import pandas as pd
df = pd.read_csv('data/processed/cleaned_churn_data.csv')
viz = ChurnVisualizer(df, Config())
viz.plot_churn_by_contract()
viz.plot_churn_by_tenure()
viz.plot_churn_by_payment()
viz.plot_monthly_charges()
print('Charts saved to docs/screenshots/')
"
```
