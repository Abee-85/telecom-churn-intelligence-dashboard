# 📡 Telecom Customer Churn Intelligence Dashboard
### Retention Strategy Analysis · IBM Telco Dataset · 7,043 Records · 21 Features

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python)
![Scikit-Learn](https://img.shields.io/badge/ScikitLearn-1.3-orange?logo=scikit-learn)
![Jupyter](https://img.shields.io/badge/Notebooks-5-yellow?logo=jupyter)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Production--Ready-brightgreen)

> A full-stack BI + Machine Learning platform that identifies telecom customer churn patterns, builds predictive models, and drives proactive data-driven retention strategies.

---

## 🎯 Project Objectives

| # | Objective | Delivered |
|---|-----------|-----------|
| 1 | Collect & preprocess telecom customer dataset | ✅ |
| 2 | Design star-schema data warehouse | ✅ |
| 3 | Implement full ETL pipeline | ✅ |
| 4 | Build interactive BI dashboard | ✅ |
| 5 | Identify churn drivers via EDA | ✅ |
| 6 | Train & compare 4 ML classifiers | ✅ |
| 7 | Evaluate models (AUC-ROC, F1, Precision, Recall) | ✅ |
| 8 | Generate actionable retention recommendations | ✅ |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA SOURCE LAYER                         │
│      IBM Telco CSV · 7,043 records · 21 features            │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│               ETL & PROCESSING LAYER                        │
│   extract.py → transform.py → load.py                      │
│   Cleaning · Encoding · Feature Engineering                 │
└────────────────────────┬───────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│          DATA WAREHOUSE & ANALYTICS LAYER                   │
│   Star Schema · FACT_CHURN · 4 Dimension Tables            │
│   ML Module: LR · DT · RF · GBT                            │
└────────────────────────┬───────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                         │
│   Dashboard · Notebooks · Reports · Recommendations         │
└────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
telecom-churn-intelligence-dashboard/
├── data/
│   ├── raw/                         # Original IBM Telco CSV
│   ├── processed/                   # Cleaned, encoded dataset
│   └── external/                    # Data dictionary
├── notebooks/
│   ├── 01_data_cleaning.ipynb       # ETL + preprocessing
│   ├── 02_eda.ipynb                 # Exploratory analysis + charts
│   ├── 03_feature_engineering.ipynb # Feature creation & selection
│   ├── 04_model_building.ipynb      # 4 classifier training
│   └── 05_model_evaluation.ipynb   # Metrics + ROC + confusion matrix
├── sql/
│   ├── schema.sql                   # OLTP schema
│   ├── star_schema.sql              # Warehouse star schema
│   └── etl_queries.sql              # ETL + analytical queries
├── src/
│   ├── etl/                         # extract · transform · load
│   ├── preprocessing/               # Preprocessor class
│   ├── visualization/               # Chart generators
│   ├── prediction/                  # Model trainer + predictor
│   └── utils/                       # Config + logger
├── models/
│   ├── trained_models/              # Serialized .pkl files
│   └── model_metrics/               # Evaluation results markdown
├── dashboards/
│   ├── powerbi/                     # DAX measures + page docs
│   └── screenshots/                 # Dashboard screenshot guide
├── docs/
│   ├── architecture/                # System & ETL documentation
│   ├── diagrams/                    # Mermaid diagrams
│   └── screenshots/                 # Visual documentation
├── reports/
│   ├── project_report/              # Full report outline
│   └── presentation/                # Slide deck outline
├── main.py                          # Pipeline orchestrator
├── requirements.txt
├── .gitignore
└── LICENSE
```

---

## ⚡ Quick Start

```bash
# 1. Clone
git clone https://github.com/<username>/telecom-churn-intelligence-dashboard.git
cd telecom-churn-intelligence-dashboard

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run full pipeline
python main.py

# 4. Or explore notebooks
jupyter notebook notebooks/01_data_cleaning.ipynb
```

---

## 📊 Key Findings

| Segment | Churn Rate | Risk Level |
|---------|-----------|------------|
| Month-to-Month Contract | **42.71%** | 🔴 Critical |
| 0–12 Month Tenure | **47.68%** | 🔴 Critical |
| Electronic Check Payment | **45.29%** | 🔴 Critical |
| Fiber Optic Internet | **41.89%** | 🔴 Critical |
| Senior Citizens | **41.68%** | 🔴 Critical |
| Two-Year Contract | **2.83%** | 🟢 Safe |
| Auto-Pay Users | **~16%** | 🟢 Safe |

---

## 🤖 Model Performance Summary

| Model | Accuracy | AUC-ROC | Precision | Recall | F1 |
|-------|----------|---------|-----------|--------|----|
| ⭐ Logistic Regression | 79.91% | 84.03% | 64.26% | **54.81%** | 59.16% |
| Gradient Boosting | **80.13%** | **84.49%** | **66.55%** | 50.53% | 57.45% |
| Random Forest | 79.21% | 82.25% | 63.73% | 50.27% | 56.20% |
| Decision Tree | 72.95% | 66.80% | 50.66% | 52.37% | 51.50% |

> ⭐ **Logistic Regression** recommended: highest recall (catches most churners) + interpretable coefficients for CRM integration.

---

## 🔮 Future Enhancements

- Real-time scoring REST API (FastAPI)
- LSTM sequential churn modelling
- SMOTE class imbalance correction
- SHAP explainability (per-customer explanations)
- Power BI Embedded deployment

---

## 🚀 GitHub Setup

```bash
git init
git add .
git commit -m "feat: initial commit - Telecom Churn Intelligence Dashboard"
git branch -M main
git remote add origin https://github.com/<username>/telecom-churn-intelligence-dashboard.git
git push -u origin main
```

---

## 📜 License
MIT License — see [LICENSE](LICENSE)

---

*MCA Final Project · IBM Telco Customer Churn Dataset · 7,043 records*
