# 🤖 Model Evaluation Results
## Telecom Customer Churn Prediction

**Dataset:** IBM Telco Customer Churn (7,043 records)  
**Train/Test Split:** 80% / 20% (stratified)  
**Train set:** 5,634 records | **Test set:** 1,409 records  
**Class balance:** 73.46% retained / 26.54% churned

---

## Performance Summary Table

| Model | Accuracy | AUC-ROC | Precision | Recall | F1-Score |
|-------|----------|---------|-----------|--------|----------|
| ⭐ **Logistic Regression** | **79.91%** | **84.03%** | 64.26% | **54.81%** | 59.16% |
| Gradient Boosting | 80.13% | 84.49% | **66.55%** | 50.53% | 57.45% |
| Random Forest | 79.21% | 82.25% | 63.73% | 50.27% | 56.20% |
| Decision Tree | 72.95% | 66.80% | 50.66% | 52.37% | 51.50% |

---

## Detailed Results per Model

### 1. Logistic Regression ⭐ RECOMMENDED

```
Hyperparameters: solver=lbfgs, max_iter=1000, C=1.0, random_state=42

              precision    recall  f1-score   support
           0       0.84      0.89      0.86      1035
           1       0.64      0.55      0.59       374

    accuracy                           0.80      1409
   macro avg       0.74      0.72      0.73      1409
weighted avg       0.79      0.80      0.79      1409

Confusion Matrix:
                Predicted 0   Predicted 1
Actual 0 (TN)      920           115
Actual 1 (FN)      169           205

AUC-ROC: 0.8403
```

**Why selected:** Highest recall (54.81%) minimises missed churners — the most costly error. AUC-ROC within 0.46% of best model. Fully interpretable feature coefficients enable CRM integration and business explanation.

---

### 2. Gradient Boosting

```
Hyperparameters: n_estimators=100, learning_rate=0.1, max_depth=3, random_state=42

              precision    recall  f1-score   support
           0       0.83      0.91      0.87      1035
           1       0.67      0.51      0.57       374

    accuracy                           0.80      1409

AUC-ROC: 0.8449  ← Highest raw AUC
```

**Note:** Best AUC-ROC but lower recall than LR. Recommended when raw discrimination power matters more than interpretability.

---

### 3. Random Forest

```
Hyperparameters: n_estimators=100, random_state=42, n_jobs=-1

              precision    recall  f1-score   support
           0       0.83      0.90      0.86      1035
           1       0.64      0.50      0.56       374

    accuracy                           0.79      1409

AUC-ROC: 0.8225
```

**Note:** Provides reliable feature importance scores. Used for feature importance analysis in dashboard.

---

### 4. Decision Tree

```
Hyperparameters: criterion=gini, max_depth=None, random_state=42

              precision    recall  f1-score   support
           0       0.83      0.82      0.82      1035
           1       0.51      0.52      0.51       374

    accuracy                           0.73      1409

AUC-ROC: 0.6680
```

**Note:** Most interpretable (single tree) but prone to overfitting — lowest AUC-ROC. Included for baseline comparison.

---

## Top 10 Feature Importances (Random Forest)

| Rank | Feature | Importance |
|------|---------|-----------|
| 1 | TotalCharges | 18.68% |
| 2 | MonthlyCharges | 17.92% |
| 3 | tenure | 15.43% |
| 4 | Contract_Month-to-month | 7.96% |
| 5 | PaymentMethod_Electronic check | 5.01% |
| 6 | OnlineSecurity_No | 4.96% |
| 7 | TechSupport_No | 4.36% |
| 8 | gender | 2.79% |
| 9 | InternetService_Fiber optic | 2.78% |
| 10 | OnlineBackup_No | 2.71% |

---

## Model Selection Rationale

```
Decision Criteria:
┌─────────────────────────────┬──────┬──────┬──────┬──────┐
│ Criterion                   │  LR  │  DT  │  RF  │  GB  │
├─────────────────────────────┼──────┼──────┼──────┼──────┤
│ Highest Recall              │  ✅  │      │      │      │
│ Highest AUC-ROC             │      │      │      │  ✅  │
│ Best Interpretability       │  ✅  │  ✅  │      │      │
│ CRM Integration Ready       │  ✅  │      │      │      │
│ Fastest Inference           │  ✅  │  ✅  │      │      │
│ Lowest False Negatives      │  ✅  │      │      │      │
├─────────────────────────────┼──────┼──────┼──────┼──────┤
│ SCORE                       │  5   │  2   │  0   │  1   │
└─────────────────────────────┴──────┴──────┴──────┴──────┘
```

**Winner: Logistic Regression** — best balance of recall, interpretability, and business deployability.

---

## Business Impact Projection

| Intervention | At-Risk Customers | Estimated Revenue Protected |
|-------------|------------------|----------------------------|
| Model scoring (monthly) | ~700 high-risk flagged | $52,000/month |
| Contract conversion campaign | 1,869 churned × 18% reduction | $370,000/year |
| Early tenure programme | 2,175 new × 12% reduction | $146,000/year |
| Combined strategy | 563–845 customers saved | **$504,000+/year** |

*Based on avg churned customer monthly charge of $74.44*
