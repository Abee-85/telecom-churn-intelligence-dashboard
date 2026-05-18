# 📐 System Diagrams
## Telecom Customer Churn Intelligence Dashboard

All diagrams are written in **Mermaid syntax** — render at [mermaid.live](https://mermaid.live) or in any Markdown viewer with Mermaid support (GitHub, VS Code, Notion).

---

## 1. High-Level Architecture

```mermaid
graph TD
    CSV[📁 IBM Telco CSV<br/>7,043 records · 21 features]
    ETL[⚙️ ETL Pipeline<br/>extract → transform → load]
    DW[🗄️ Star Schema Warehouse<br/>FACT_CHURN + 4 DIM Tables]
    ML[🤖 ML Module<br/>LR · DT · RF · GBT]
    DASH[📊 BI Dashboard<br/>6-Tab Interactive · Chart.js]
    PBI[📊 Power BI<br/>DAX Measures · KPI Cards]
    RPT[📄 Reports<br/>Notebooks · Docs]

    CSV --> ETL
    ETL --> DW
    ETL --> ML
    DW --> DASH
    DW --> PBI
    ML --> DASH
    ML --> PBI
    DASH --> RPT
    PBI --> RPT
```

---

## 2. DFD Level 0 — Context Diagram

```mermaid
graph LR
    DS([🗄️ IBM Telco<br/>Dataset])
    SYS[[Churn Intelligence<br/>Platform]]
    MGR([👔 Business<br/>Manager])
    ANA([🔬 Data<br/>Analyst])
    DS -->|raw customer data| SYS
    SYS -->|churn reports + recommendations| MGR
    SYS -->|model metrics + data quality| ANA
    ANA -->|pipeline runs + queries| SYS
```

---

## 3. DFD Level 1 — Main Processes

```mermaid
graph TD
    DS[(Raw CSV)]
    P1[P1: Extract &<br/>Validate Data]
    P2[P2: Transform &<br/>Engineer Features]
    P3[P3: Load to<br/>Warehouse]
    P4[P4: Train ML<br/>Models]
    P5[P5: Render<br/>Dashboard]

    DS1[(Cleaned Data)]
    DS2[(Star Schema DB)]
    DS3[(Trained Models)]

    DS --> P1 --> DS1
    DS1 --> P2 --> DS1
    DS1 --> P3 --> DS2
    DS1 --> P4 --> DS3
    DS2 --> P5
    DS3 --> P5
```

---

## 4. DFD Level 2 — ETL Sub-Processes

```mermaid
flowchart TD
    A[Raw CSV Input] --> B[Read with pd.read_csv]
    B --> C{Schema Check<br/>21 columns?}
    C -- Fail --> D[Raise ValueError]
    C -- Pass --> E[Null Detection<br/>TotalCharges blanks]
    E --> F[Numeric Coercion<br/>pd.to_numeric errors=coerce]
    F --> G[Impute Nulls<br/>fillna 0.0]
    G --> H[Encode Churn<br/>Yes→1 No→0]
    H --> I[Create TenureCohort<br/>pd.cut 4 bins]
    I --> J[Load DIM Tables<br/>4 dimension tables]
    J --> K[Load FACT_CHURN<br/>7,043 rows]
    K --> L{Row Count<br/>== 7,043?}
    L -- Fail --> M[Assert Error]
    L -- Pass --> N[✅ Warehouse Ready]
```

---

## 5. Entity Relationship Diagram

```mermaid
erDiagram
    DIM_CUSTOMER {
        int customer_sk PK
        string customer_id UK
        string gender
        int senior_citizen
        string partner
        string dependents
    }
    DIM_CONTRACT {
        int contract_sk PK
        string contract_type
        string payment_method
        string paperless_billing
    }
    DIM_SERVICE {
        int service_sk PK
        string internet_service
        string phone_service
        string online_security
        string tech_support
        string streaming_tv
    }
    DIM_DATE {
        int date_sk PK
        int tenure_months
        string tenure_bucket
        int cohort_order
    }
    FACT_CHURN {
        int fact_sk PK
        int customer_sk FK
        int contract_sk FK
        int service_sk FK
        int date_sk FK
        float monthly_charges
        float total_charges
        int churn_flag
        float churn_probability
        string risk_segment
    }

    DIM_CUSTOMER ||--o{ FACT_CHURN : "has"
    DIM_CONTRACT ||--o{ FACT_CHURN : "applies to"
    DIM_SERVICE  ||--o{ FACT_CHURN : "subscribed"
    DIM_DATE     ||--o{ FACT_CHURN : "at tenure"
```

---

## 6. Star Schema Diagram

```mermaid
graph TD
    FACT["⭐ FACT_CHURN<br/>━━━━━━━━━━━━━━━━━━<br/>fact_sk PK<br/>customer_sk FK<br/>contract_sk FK<br/>service_sk FK<br/>date_sk FK<br/>monthly_charges<br/>total_charges<br/>churn_flag ← MEASURE<br/>churn_probability ← MEASURE<br/>risk_segment ← MEASURE"]

    DC["DIM_CUSTOMER<br/>━━━━━━━━━━━━━━━━━━<br/>customer_sk PK<br/>customer_id UK<br/>gender<br/>senior_citizen<br/>partner<br/>dependents"]

    DK["DIM_CONTRACT<br/>━━━━━━━━━━━━━━━━━━<br/>contract_sk PK<br/>contract_type<br/>payment_method<br/>paperless_billing"]

    DS["DIM_SERVICE<br/>━━━━━━━━━━━━━━━━━━<br/>service_sk PK<br/>internet_service<br/>phone_service<br/>online_security<br/>tech_support<br/>streaming_tv"]

    DD["DIM_DATE<br/>━━━━━━━━━━━━━━━━━━<br/>date_sk PK<br/>tenure_months<br/>tenure_bucket<br/>cohort_order"]

    DC --- FACT
    DK --- FACT
    DS --- FACT
    DD --- FACT
```

---

## 7. ML Workflow

```mermaid
flowchart TD
    A[Cleaned Dataset<br/>7,043 records] --> B[Binary Encode<br/>Yes/No → 1/0]
    B --> C[One-Hot Encode<br/>Categoricals → dummies]
    C --> D[Standard Scale<br/>Numerics]
    D --> E[Train/Test Split<br/>80% / 20% stratified]
    E --> F1[Logistic Regression<br/>lbfgs · max_iter=1000]
    E --> F2[Decision Tree<br/>criterion=gini]
    E --> F3[Random Forest<br/>100 trees · n_jobs=-1]
    E --> F4[Gradient Boosting<br/>100 trees · lr=0.1]
    F1 & F2 & F3 & F4 --> G[Evaluate Each Model<br/>Accuracy · AUC · Precision<br/>Recall · F1 · Confusion Matrix]
    G --> H{Select Best<br/>Model}
    H --> I[⭐ Logistic Regression<br/>AUC=84.03% · Recall=54.81%]
    I --> J[Save .pkl via joblib]
    J --> K[Deploy as Churn Scorer<br/>score new customers monthly]
```

---

## 8. Retention Strategy Framework

```mermaid
graph TD
    A[📊 Churn Analysis<br/>26.54% overall rate] --> B[🔴 Critical Segments<br/>M2M · New Customers<br/>Elec. Check · Fiber Optic]
    A --> C[🟡 High-Risk Segments<br/>No Security · Paperless<br/>Senior Citizens]
    B --> D[🎯 Contract Conversion<br/>Incentivise annual plans<br/>Est. −18% M2M churn]
    B --> E[🎯 Onboarding Programme<br/>Month 1/3/6 outreach<br/>Est. −12% new cust churn]
    B --> F[🎯 Auto-Pay Migration<br/>Bill credit for switch<br/>Est. −20% combined]
    C --> G[🎯 Bundle Promotions<br/>Security + Tech Support<br/>Est. −27% with add-ons]
    C --> H[🎯 Senior Loyalty Tier<br/>Simplified billing + support<br/>Est. −10% senior churn]
    D & E & F & G & H --> I[💰 Combined Impact<br/>563–845 customers saved<br/>$504,000+ revenue protected]
```
