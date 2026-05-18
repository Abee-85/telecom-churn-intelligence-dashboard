# 🎯 Presentation Outline
## Telecom Customer Churn Intelligence Dashboard
### MCA Final Project Viva Presentation · 20 Slides

---

## Slide Deck Structure

---

### Slide 1 — Title Slide
**Title:** Telecom Customer Churn Intelligence Dashboard for Retention Strategy Analysis  
**Subtitle:** MCA Final Project  
**Details:** [Student Name] · [UID] · [Guide Name] · [Institute] · [Year]  
**Visual:** Telecom tower silhouette + data flow animation

---

### Slide 2 — Agenda
- Problem Statement
- Project Objectives
- System Architecture
- Dataset Overview
- ETL & Data Warehouse
- Exploratory Analysis
- Machine Learning Models
- Dashboard Demo
- Key Findings
- Retention Recommendations
- Conclusion & Future Scope

---

### Slide 3 — Problem Statement
**Headline:** Telecom operators lose 26.54% of customers annually to churn

**Key pain points:**
- Reactive churn management (after subscriber leaves)
- Fragmented data silos (no unified view)
- No predictive capability to identify at-risk customers
- No evidence-based retention strategy framework

**Visual:** Funnel showing 7,043 customers → 1,869 churned (26.54%)

---

### Slide 4 — Project Objectives
**Grid of 4 objectives (icons + text):**
- 📊 Build BI Platform — 6-tab interactive dashboard
- 🗄️ Design Data Warehouse — Star schema + ETL pipeline
- 🤖 Train ML Models — 4 classifiers, best AUC 84.03%
- 🎯 Generate Insights — 6 data-driven retention strategies

---

### Slide 5 — System Architecture
**4-layer diagram:**
```
Data Source → ETL Layer → Warehouse + ML → Presentation
```
Show data flow arrows. Highlight each module with tech stack labels.

---

### Slide 6 — Dataset Overview
**IBM Telco Customer Churn Dataset**

| Metric | Value |
|--------|-------|
| Records | 7,043 customers |
| Features | 21 columns |
| Churn Rate | 26.54% |
| Target | Churn (Yes/No) |

**Feature categories:** Demographics · Services · Billing · Contract  
**Visual:** Donut chart (73.46% retained / 26.54% churned)

---

### Slide 7 — ETL Pipeline & Data Warehouse
**Left: ETL flow** (5 steps: Extract → Clean → Transform → Load → Validate)  
**Right: Star schema** diagram (FACT_CHURN + 4 DIM tables)  
**Bottom: Data quality table** (all 6 checks ✅ PASS)

---

### Slide 8 — Exploratory Analysis: Contract & Tenure
**Two charts side-by-side:**
- Bar: Churn by Contract (Month-to-Month 42.71% vs Two-Year 2.83%)
- Line: Churn by Tenure Cohort (47.68% → 9.51%)

**Callout:** "15× difference between highest and lowest risk contract segments"

---

### Slide 9 — Exploratory Analysis: Payment & Service
**Two charts:**
- Bar: Electronic Check 45.29% vs Auto-Pay ~16%
- Grouped bar: Online Security With 14.61% vs Without 41.77%

**Callout:** "Auto-payment and security add-ons are the strongest retention anchors"

---

### Slide 10 — Customer Segmentation Matrix
**Risk Matrix Table (top 6 rows):**

| Segment | Churn Rate | Risk |
|---------|-----------|------|
| New Customers | 47.68% | 🔴 CRITICAL |
| Electronic Check | 45.29% | 🔴 CRITICAL |
| Month-to-Month | 42.71% | 🔴 CRITICAL |
| Fiber Optic | 41.89% | 🔴 CRITICAL |
| Senior Citizens | 41.68% | 🔴 CRITICAL |
| Two-Year Contract | 2.83% | 🟢 SAFE |

---

### Slide 11 — ML Model Results
**Model performance table (4 rows):**

| Model | Accuracy | AUC-ROC | Recall |
|-------|----------|---------|--------|
| ⭐ Logistic Regression | 79.91% | 84.03% | **54.81%** |
| Gradient Boosting | 80.13% | **84.49%** | 50.53% |
| Random Forest | 79.21% | 82.25% | 50.27% |
| Decision Tree | 72.95% | 66.80% | 52.37% |

**Visual:** AUC-ROC bar comparison

---

### Slide 12 — Model: Confusion Matrix
**2×2 Confusion Matrix (Logistic Regression):**
- TN = 920 🟢 (correctly retained)
- FP = 115 🟡 (false alarm)
- FN = 169 🔴 (missed churner — costly)
- TP = 205 🔵 (correctly caught)

**Explanation:** "We correctly identify 205 out of 374 churners — highest recall of all models"

---

### Slide 13 — Feature Importance
**Horizontal bar chart — Top 10:**
1. TotalCharges 18.68%
2. MonthlyCharges 17.92%
3. tenure 15.43%
4. Contract_M2M 7.96%
5. PaymentMethod_ElecCheck 5.01%

**Insight:** "Financial and temporal features dominate — price sensitivity drives churn"

---

### Slide 14 — Dashboard Demo (Screenshot)
**Full-screen screenshot: Overview Tab**  
- 6 KPI cards visible
- Tenure cohort bar chart
- Churn donut chart
- Navigation tabs

**Speaker notes:** "Live demo of all 6 tabs"

---

### Slide 15 — Dashboard: Analysis & Models Tabs
**Split screenshot:**
- Left: Churn Analysis tab (payment + services charts)
- Right: Predictive Models tab (4 model cards)

---

### Slide 16 — Retention Recommendations
**6 cards with impact:**

| Priority | Strategy | Impact |
|----------|---------|--------|
| 🔴 Critical | Contract Conversion Campaign | −18–22% M2M churn |
| 🔴 Critical | Early Tenure Onboarding | −12–15% new customer churn |
| 🟡 High | Fiber Quality Programme | −8–12% fiber churn |
| 🟡 High | Auto-Pay + Security Bundles | −20% combined |
| 🔵 Strategic | Deploy LR Churn Scorer | 700+ proactive alerts/month |
| 🟢 Ongoing | Senior Loyalty Programme | −10–14% senior churn |

---

### Slide 17 — Projected Business Impact
**4 KPI cards:**
- Churn Reduction: **−8 to −12%**
- Customers Saved: **563 – 845**
- Revenue Protected: **$504,000+/year**
- Model Confidence: **84.03% AUC-ROC**

**Visual:** Revenue waterfall chart showing strategy-by-strategy accumulation

---

### Slide 18 — Technical Achievements
**Achievement grid:**
- ✅ ETL Pipeline: 7,043 records, 0 nulls post-processing
- ✅ Star Schema: 5 tables, FK integrity validated
- ✅ 4 ML Models: trained, compared, saved as .pkl
- ✅ Dashboard: 6 tabs, 20+ charts, dark theme
- ✅ 5 Jupyter Notebooks: fully documented
- ✅ SQL: 3 scripts, 6 analytical queries
- ✅ GitHub Ready: all 40+ files in repository

---

### Slide 19 — Future Scope
1. **Real-time streaming** via Apache Kafka
2. **LSTM deep learning** for sequential churn prediction
3. **REST API deployment** (FastAPI) for CRM integration
4. **SHAP explainability** per-customer churn reasons
5. **SMOTE** to fix class imbalance and improve recall
6. **Multi-class churn** (voluntary vs. involuntary)

---

### Slide 20 — Conclusion
**"Objectives Met"** checklist (11 items, all ticked)

**Key takeaway:**
> *"This platform transforms 7,043 customer records into $504,000+ in projected annual retention — demonstrating that open-source data science can deliver enterprise-grade business intelligence."*

**Thank You · Questions?**

---

## Presentation Tips

- **Duration:** 15–20 minutes + 10 minutes Q&A
- **Live Demo:** Switch to browser for Slides 14–15 (dashboard demo)
- **Anticipated Questions:**
  - "Why Logistic Regression over Gradient Boosting?" → Recall + interpretability
  - "How would you handle class imbalance?" → SMOTE (future scope)
  - "How does the ETL handle new data?" → Idempotent `if_exists='replace'` pattern
  - "What's the ROI of deploying this?" → $504K+ revenue protection estimate
