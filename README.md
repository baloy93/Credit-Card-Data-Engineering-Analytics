# 💳 Credit Card Data Engineering & Analytics

![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Microsoft%20Azure-blue)
![Language](https://img.shields.io/badge/Language-Python%20%7C%20SQL%20%7C%20PySpark-orange)
![Reporting](https://img.shields.io/badge/Reporting-Power%20BI-yellow)

---

## 📌 Project Overview

An end-to-end data engineering solution built on **Microsoft Azure** for credit card analytics and fraud intelligence. The project ingests raw CSV files from **Azure Data Lake Storage**, transforms them through a **Medallion Architecture**, and delivers business-ready insights through an executive **Power BI dashboard**.

---

## 🏗️ Architecture

```
Azure Data Lake Storage (CSV files)
            │
            ▼
   Azure Data Factory Pipeline
   (Metadata-driven: Lookup + ForEach + Copy)
            │
            ▼
      Bronze Layer (Raw)
            │
            ▼
   Mapping Data Flows (Cleansing)
            │
            ▼
      Silver Layer (Cleaned)
            │
            ▼
  T-SQL Stored Procedures (SCD Type 2)
            │
            ▼
       Gold Layer (Star Schema)
            │
            ▼
      Power BI Dashboard
```

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|------------|
| Source | Azure Data Lake Storage Gen2 (CSV) |
| Ingestion | Azure Data Factory Pipeline |
| Storage | Azure SQL Database |
| Transformation | Mapping Data Flows |
| Business Logic | T-SQL Stored Procedures (SCD Type 2) |
| Data Quality | PySpark Notebooks / T-SQL |
| Reporting | Power BI |
| Data Generation | Python (Faker library) |

---

## 📂 Repository Structure

```
Credit-Card-Data-Engineering-Analytics/
│
├── Architecture/        # Architecture diagrams
├── datasets/            # Source CSV datasets
├── my scripts/          # Python data generation scripts
├── screenshorts/        # Dashboard screenshots
├── visuals/             # Architecture visuals
│
├── README.md
├── CHANGELOG.md
└── .gitignore
```

---

## 🔄 Data Pipeline

### 🟫 Bronze Layer — Raw Ingestion
- Metadata-driven pipeline reads JSON config file
- ForEach loop dynamically iterates over each table
- CSV files copied from ADLS into staging tables
- Full audit trail preserved

### 🟩 Silver Layer — Cleansed Data
- Mapping Data Flows apply cleansing rules
- Trim, initCap, fix nulls, remove duplicates
- Data written to `staging_clean` tables

### 🟨 Gold Layer — Star Schema
- T-SQL stored procedures apply SCD Type 2 logic
- Dimension tables loaded with full history tracking
- Fact table populated joining all dimensions

---

## 📊 Data Model

**Star Schema with 1 Fact Table + 4 Dimension Tables:**

| Table | Description |
|-------|-------------|
| `Fact_Transactions` | Grain: one transaction row |
| `Dim_Customer` | SCD Type 2 — tracks relocations & changes |
| `Dim_Card` | SCD Type 2 — tracks card upgrades & status |
| `Dim_Merchant` | SCD Type 2 — tracks category & risk changes |
| `Dim_Date` | Calendar intelligence, weekend flag, quarter |

---

## 📈 Power BI Dashboard

5 executive dashboard pages:

| Page | Purpose |
|------|---------|
| Executive Overview | KPIs, revenue trends, fraud heatmap |
| Customer Intelligence | Segmentation, top customers, SCD audit trail |
| Fraud & Risk | Fraud patterns, high-risk transactions, gauge |
| Merchant Analytics | Performance, spend categories, trends |
| Data Governance | Quality scorecard, change history, audit trail |

---

## ✅ Data Quality Results

| Table | Quality Score |
|-------|--------------|
| Dim_Customer | 95%+ |
| Dim_Card | 99%+ |
| Dim_Merchant | 100% |
| Fact_Transactions | 99%+ |
| Foreign Key Integrity | 100% |

---

## 🗂️ Dataset

Synthetic South African credit card transaction dataset:
- **500+** customers across 20 South African cities
- **60+** merchants across 5 categories
- **50,000+** transactions spanning 5 years
- **4-5%** realistic fraud rate
- SCD Type 2 changes included

---

## 💡 Business Insights

| Insight | Recommendation |
|---------|---------------|
| Fraud concentrated in specific merchants | Tighten controls on high-risk merchants |
| Online is the biggest fraud channel | Add verification for large online transactions |
| Platinum/Business cardholders drive revenue | VIP treatment for top customers |
| Young customers are future value | Build loyalty pathways early |
| Weekend transactions have higher fraud rates | Enable stricter weekend fraud checks |

---

## 👤 Author

**Kulani Baloyi**
Data Engineering | Microsoft Azure | Azure Data Factory | Power BI | Python | SQL

---

*Credit Card Data Engineering & Analytics | 2026*
