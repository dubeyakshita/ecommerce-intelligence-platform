# 🛒 E-Commerce Intelligence Platform (DE + ML Project)

## 📌 Overview

This project is an end-to-end **Data Engineering + Machine Learning platform** built on top of the Olist Brazilian E-Commerce dataset.

It demonstrates how to:

- Build a structured data warehouse using **PostgreSQL + dbt**
- Engineer features for analytics and ML
- Implement **customer segmentation (unsupervised ML)**
- Build a **churn prediction model (supervised ML)**
- Store ML outputs back into the warehouse

---

## 🏗 Architecture


Raw CSV Data
↓
PostgreSQL (Docker)
↓
dbt (Staging → Mart Models)
↓
Feature Tables
↓
Python ML Pipelines
↓
Predictions written back to warehouse


---

## ⚙️ Tech Stack

- **Data Warehouse**: PostgreSQL (Docker)
- **Transformation**: dbt
- **Programming**: Python
- **ML Libraries**: scikit-learn, pandas
- **Orchestration (manual)**: CLI-based workflow

---

## 📊 Data Modeling

### Layers

- **Raw Layer**
  - CSV ingestion into PostgreSQL

- **Staging Layer (dbt)**
  - Data cleaning and standardization

- **Mart Layer (dbt)**
  - Star-schema inspired models:
    - `fact_orders`
    - `dim_customers`
    - `customer_features`

---

## 🧠 Phase 2A — Customer Segmentation

### 🎯 Objective

Segment customers based on purchasing behavior.

---

### 🧾 Features Used

- total_orders  
- total_revenue  
- avg_order_value  
- total_items  
- avg_review_score  
- recency_days  

---

### ⚙️ Feature Engineering

- Log transformation applied to handle skewed distributions
- Standard scaling applied before clustering

---

### 🤖 Model

- Algorithm: **KMeans Clustering**
- K selection: Silhouette score (tested K=3 to 6)
- Best K: **4**
- Silhouette Score: ~**0.31**

---

### 📊 Results

Identified customer segments primarily based on spending behavior:

- Low-value customers  
- Mid-value customers  
- High-value customers  

---

### ⚠️ Key Insight

Most customers in the dataset placed only **one order**, limiting segmentation depth.

As a result, clustering was driven primarily by **monetary features** rather than frequency.

---

### 📤 Output

Segment assignments stored in:


mart.customer_segments


---

## 🔮 Phase 2B — Churn Prediction

### 🎯 Objective

Predict whether a customer is likely to churn.

---

### 🧠 Churn Definition

A customer is considered **churned** if:

> No purchase in the last **90 days** relative to dataset's latest date.

---

### ⚠️ Important ML Challenge

Initial model suffered from **data leakage**, producing perfect results.

This was fixed by:

- Separating **feature window (90–180 days)**  
- From **churn window (last 90 days)**  

---

### 🧾 Features Used

- total_orders  
- total_revenue  
- avg_order_value  
- total_items  
- avg_review_score  
- recent_orders (90–180 days window)  
- recent_revenue (90–180 days window)  

---

### 🤖 Model

- Algorithm: **Logistic Regression**
- Class imbalance handled using:
  - `class_weight="balanced"`

---

### 📊 Results

- ROC-AUC: **~0.64**
- Model captures moderate predictive signal

---

### 🧠 Key Insight

> After removing data leakage, model performance dropped to realistic levels, highlighting the importance of correct temporal feature engineering.

---

### 📤 Output

Churn predictions stored in:


mart.customer_churn_predictions


---

## 🔥 Key Learnings

- Importance of **feature engineering over model complexity**
- Handling **class imbalance** in real datasets
- Detecting and fixing **data leakage**
- Designing **time-aware ML pipelines**
- Integrating ML outputs back into a data warehouse

---

## 🚀 How to Run the Project

### 1. Start Infrastructure


docker-compose up -d


---

### 2. Run dbt Models


cd ecommerce_dbt
dbt run
dbt test


---

### 3. Run ML Pipelines

#### Segmentation


python ml/train_segmentation.py


#### Churn Prediction


python ml/train_churn.py


---

## 📌 Future Improvements

- Add dashboard layer (Metabase / Superset)
- Improve feature richness (product/category-level behavior)
- Introduce model monitoring & retraining pipelines
- Add orchestration (Airflow / Prefect)

---

## 🎯 Project Goal

This project is designed to demonstrate a **hybrid Data Engineer + ML Engineer skillset**, with a focus on:

- Structured data modeling  
- Feature engineering pipelines  
- Production-style ML integration  

---