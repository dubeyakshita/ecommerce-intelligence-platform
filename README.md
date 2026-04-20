# 📦 E-Commerce Intelligence Platform  
*A Modern ELT Data Engineering Project using Docker, PostgreSQL & dbt*

---

## 🚀 Overview

This project implements a layered ELT data warehouse for an e-commerce dataset (Olist Brazilian E-Commerce dataset).

The objective is to design a production-style analytics architecture using modern data engineering tools:

- Containerized infrastructure
- Raw → Staging → Mart modeling
- Modular transformations with dbt
- Data quality testing
- Dependency-based orchestration

This project serves as a portfolio-ready demonstration of end-to-end data engineering workflow.

---

## 🏗 Architecture

    RAW (CSV Data)
         ↓
    STAGING (Cleaned & Standardized)
         ↓
    MART (Fact & Dimension Models)


### Layers

### 1️⃣ Raw Layer
- Data loaded into PostgreSQL using Python ingestion scripts
- No transformation logic
- Mirrors source CSV schema

### 2️⃣ Staging Layer (dbt models)
- Column renaming
- Type casting
- Standardization
- Clean interface between raw and analytics layer

### 3️⃣ Mart Layer (dbt models)
- `fact_orders`
- `dim_customers`
- `dim_products`

Implements star-schema style modeling for analytical queries.

---

## 🔄 Data Lineage (dbt DAG)

The transformation workflow is dependency-driven using `ref()` in dbt.

- Raw sources declared using `source()`
- Staging models depend on raw tables
- Mart models depend on staging models
- dbt builds models in correct order automatically

Generate documentation with:

dbt docs generate
dbt docs serve


## 🧪 Data Quality Testing

Data integrity is enforced using dbt tests:

- `not_null`
- `unique`
- `relationships` (foreign key validation)

Run tests using:

dbt test


## 🛠 Tech Stack

- Python 3.11
- Docker & Docker Compose
- PostgreSQL 15
- dbt (Postgres adapter)
- VS Code

---

## 📁 Project Structure
```
ecommerce-intelligence-platform/
│
├── docker-compose.yml
├── ingestion/
│ └── load_raw_tables.py
│
├── data/
│ └── (Olist dataset CSV files)
│
├── ecommerce_dbt/
│ ├── dbt_project.yml
│ ├── models/
│ │ ├── staging/
│ │ └── marts/
│ └── ...
│
└── README.md
```

## ⚙️ How to Run Locally

### 1️⃣ Start PostgreSQL via Docker

docker compose up -d


### 2️⃣ Load Raw Data

python ingestion/load_raw_tables.py


### 3️⃣ Run dbt Transformations

cd ecommerce_dbt
dbt run


### 4️⃣ Run Data Tests

dbt test


### 5️⃣ View Lineage Graph


### 5️⃣ View Lineage Graph

dbt docs generate
dbt docs serve


## 📊 Analytical Capabilities

The mart layer supports:

- Monthly revenue analysis
- Customer lifetime value
- Product-level performance
- Order-level revenue breakdown
- Review score aggregation

Example Query:

```sql
SELECT
    DATE_TRUNC('month', order_purchase_ts) AS month,
    SUM(total_order_value) AS monthly_revenue
FROM mart.fact_orders
GROUP BY month
ORDER BY month;
```

## 🎯 Key Engineering Concepts Demonstrated

- Layered data warehouse architecture
- ELT pattern (not ETL)
- Containerized infrastructure
- Modular transformation modeling
- Dependency management with dbt ref()
- Source declarations
- Data quality enforcement
- Reproducible builds

# 🧠 Customer Segmentation (Phase 2A)

## Objective

Segment customers based on purchasing behavior using unsupervised learning.

## Feature Engineering

Customer-level features were created using dbt:

- total_orders
- total_revenue
- avg_order_value
- total_items
- avg_review_score
- recency_days

## Transformations applied:

- Log transformation (to handle skewed distributions)
- Standard scaling

## Model
Algorithm: KMeans clustering
K selection: Silhouette score (tested K=3 to 6)
Best K: 4
Silhouette Score: ~0.31

## Results

Identified customer segments based primarily on spending behavior:

- Low-value customers
- Mid-value customers
- High-value customers

## Key Insight

Most customers in the dataset placed only one order, limiting behavioral segmentation depth. As a result, clustering was primarily driven by monetary features rather than frequency.

## Output

Segment assignments are stored in:
mart.customer_segments

## 👩‍💻 Author

Akshita Dubey

Berlin, Germany
