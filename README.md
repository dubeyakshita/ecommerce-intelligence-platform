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

## 🎯 Key Engineering Concepts Demonstrated

Layered data warehouse architecture

ELT pattern (not ETL)

Containerized infrastructure

Modular transformation modeling

Dependency management with dbt ref()

Source declarations

Data quality enforcement

Reproducible builds

## 🔜 Next Phase

Planned Phase 2 extension:

Feature engineering layer

Customer segmentation

Product recommendation system

ML model training using warehouse outputs

Model output reintegration into analytics layer

## 👩‍💻 Author

Akshita Dubey
Berlin, Germany
