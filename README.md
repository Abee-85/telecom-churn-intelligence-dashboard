# 📊 Telecom Customer Churn Intelligence Dashboard

## Project Overview

The Telecom Customer Churn Intelligence Dashboard is an AI-based analytics system designed to predict customer churn in the telecom industry using Machine Learning algorithms and Business Intelligence tools.

This project analyzes telecom customer data, performs ETL operations, trains predictive models, and visualizes insights through an interactive dashboard to support customer retention strategies and business decision-making.

The project uses the IBM Telco Customer Churn Dataset for analysis and prediction.

---

## Objectives

- Predict customer churn using Machine Learning
- Analyze customer behavior and usage patterns
- Build ETL pipelines for data processing
- Develop interactive dashboards and reports
- Improve customer retention strategies
- Support business intelligence and decision-making

---

## Technologies Used

| Technology | Purpose |
|------------|---------|
| Python | Core Programming |
| Pandas | Data Processing |
| NumPy | Numerical Computation |
| Scikit-learn | Machine Learning |
| Matplotlib | Data Visualization |
| Seaborn | Statistical Analysis |
| SQL | Database Management |
| Power BI / Tableau | Dashboard Visualization |
| Jupyter Notebook | Development Environment |

---

## Machine Learning Algorithms

The following algorithms are used for churn prediction:

- Logistic Regression
- Random Forest
- Gradient Boosting
- Decision Tree

---

## Dataset

### IBM Telco Customer Churn Dataset

The dataset includes:

- Customer demographics
- Subscription details
- Internet services
- Billing information
- Contract details
- Customer tenure
- Churn status

### Important Features

- Gender
- SeniorCitizen
- Partner
- Dependents
- Tenure
- InternetService
- Contract
- PaymentMethod
- MonthlyCharges
- TotalCharges
- Churn

---

## Features

### Data Processing
- Data Cleaning
- Missing Value Handling
- Encoding
- Data Transformation
- Normalization

### Analytics
- Customer Segmentation
- Churn Analysis
- KPI Monitoring
- Retention Analytics

### Dashboard
- Interactive Visualizations
- Churn Insights
- Revenue Analysis
- Customer Reports

---

## Installation

### Clone Repository

```bash
git clone https://github.com/Abee-85/telecom-churn-intelligence-dashboard.git
```

### Move to Project Directory

```bash
cd telecom-churn-intelligence-dashboard
```

### Install Required Packages

```bash
pip install -r requirements.txt
```

---

## Running the Project

### Run Python Application

```bash
python main.py
```

### OR Open Jupyter Notebook

```bash
jupyter notebook
```

---

## Model Evaluation Metrics

| Model | Accuracy | AUC-ROC | Precision | Recall | F1 Score |
|------|----------|----------|-----------|--------|----------|
| Logistic Regression | 79.91% | 84.03% | 64.26% | 54.81% | 59.16% |
| Gradient Boosting | 80.13% | 84.49% | 66.55% | 50.53% | 57.45% |
| Random Forest | 79.21% | 82.25% | 63.73% | 50.27% | 56.20% |
| Decision Tree | 72.95% | 66.80% | 50.66% | 52.37% | 51.50% |

### Best Performing Model

✅ Logistic Regression is recommended for deployment due to balanced performance and higher recall for identifying potential churn customers.

---

## Churn Analysis & Business Findings

| Segment | Churn Rate | Risk |
|---------|------------|------|
| Month-to-Month Contract | 42.71% | 🔴 Critical |
| 0–12 Month Tenure | 47.68% | 🔴 Critical |
| Electronic Check Payment | 45.29% | 🔴 Critical |
| Fiber Optic Internet | 41.89% | 🔴 Critical |
| Senior Citizens | 41.68% | 🔴 Critical |
| One-Year Contract | 11.27% | 🟡 Low |
| Two-Year Contract | 2.83% | 🟢 Safe |
| Auto-Pay Users | ~16% | 🟢 Safe |

### Key Findings

- Customers with month-to-month contracts are most likely to churn.
- New customers show significantly higher churn rates.
- Electronic check payment users are high-risk customers.
- Long-term contracts reduce churn drastically.
- Auto-pay services improve customer retention.
- Fiber optic internet users show elevated churn behavior.

---

## Dashboard Insights

The dashboard provides:

- Customer Churn Rate
- Service Usage Analysis
- Revenue Impact Analysis
- Customer Segmentation
- Retention Analytics
- Predictive Business Insights

---

## Future Enhancements

- Real-time churn prediction
- Deep Learning integration
- Cloud deployment
- Automated ETL pipelines
- API integration
- Advanced BI reporting

---

## Applications

- Telecom Industry
- Customer Retention Systems
- Business Intelligence
- Predictive Analytics
- CRM Analytics

---

## Conclusion

This project demonstrates the integration of Machine Learning, ETL, and Business Intelligence techniques to develop an intelligent telecom churn prediction system. The solution helps telecom companies identify customers likely to churn and improve customer retention strategies through data-driven insights.

---

## License

MIT License

---

## Author

Your Name  
MCA Final Year Project
