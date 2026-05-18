# Expected SQL Outputs

These are the expected headline outputs based on the current dataset and Python analysis:

## Overall churn

| Metric | Value |
|---|---:|
| Total customers | 7043 |
| Churned customers | 1869 |
| Overall churn rate | 26.54% |

## Contract-wise churn

| Contract Type | Churn Rate |
|---|---:|
| Month-to-month | 42.71% |
| One year | 11.27% |
| Two year | 2.83% |

## Internet service churn

| Internet Service | Churn Rate |
|---|---:|
| Fiber optic | 41.89% |
| DSL | 18.96% |
| No internet | 7.40% |

## Payment method churn

| Payment Method | Churn Rate |
|---|---:|
| Electronic check | 45.29% |
| Mailed check | 19.11% |
| Bank transfer (automatic) | 16.71% |
| Credit card (automatic) | 15.24% |

## Best predictive model

| Model | Accuracy | Precision | Recall | F1 Score | ROC-AUC |
|---|---:|---:|---:|---:|---:|
| Logistic Regression | 0.8070 | 0.6594 | 0.5642 | 0.6081 | 0.8416 |
| Random Forest | 0.7793 | 0.6054 | 0.4840 | 0.5379 | 0.8231 |

## Key interpretation

- Highest retention risk occurs in month-to-month, fiber-optic, and electronic-check segments.
- The first 12 months of tenure are the most vulnerable churn period.
- Logistic Regression is the recommended model for dashboard scoring because it balances performance and interpretability.
