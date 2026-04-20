import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import joblib
from datetime import datetime

# -------------------------------
# 1. Database Connection
# -------------------------------

DB_USER = "ecommerce"
DB_PASSWORD = "ecommerce"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "ecommerce_db"

engine = create_engine(
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# -------------------------------
# 2. Load Feature Table
# -------------------------------

query = "SELECT * FROM analytics_mart.customer_features"
df = pd.read_sql(query, engine)

print(f"Loaded {len(df)} customers")

# -------------------------------
# 3. Prepare Features
# -------------------------------

feature_cols = [
    "total_orders",
    "total_revenue",
    "avg_order_value",
    "total_items",
    "avg_review_score",
    "recency_days"
]

X = df[feature_cols].copy()

# Handle missing review scores
X["avg_review_score"] = X["avg_review_score"].fillna(
    X["avg_review_score"].mean()
)

# Log transform skewed features
X["total_revenue"] = np.log1p(X["total_revenue"])
X["avg_order_value"] = np.log1p(X["avg_order_value"])

X["recency_days"] = X["recency_days"] / X["recency_days"].max()
X["recency_days"] = np.log1p(X["recency_days"])

X["spend_per_item"] = X["total_revenue"] / (X["total_items"] + 1)
X["value_density"] = X["total_revenue"] / (X["total_orders"] + 1)

# -------------------------------
# 4. Scale Features
# -------------------------------

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# -------------------------------
# 5. Find Best K
# -------------------------------

best_k = None
best_score = -1
best_model = None

print("\nEvaluating K values...\n")

for k in range(3, 7):
    kmeans = KMeans(n_clusters=k, random_state=42)
    labels = kmeans.fit_predict(X_scaled)
    score = silhouette_score(X_scaled, labels)

    print(f"K={k}, Silhouette Score={score:.4f}")

    if score > best_score:
        best_score = score
        best_k = k
        best_model = kmeans

print(f"\nBest K selected: {best_k} with Silhouette Score: {best_score:.4f}")

# -------------------------------
# 6. Train Final Model
# -------------------------------

df["segment_id"] = best_model.labels_

# -------------------------------
# 7. Save Model Artifacts
# -------------------------------

joblib.dump(best_model, "kmeans_model.pkl")
joblib.dump(scaler, "scaler.pkl")

print("Model and scaler saved.")

# -------------------------------
# 8. Write Segments Back to DB
# -------------------------------

output = df[["customer_id", "segment_id"]].copy()
output["created_at"] = datetime.utcnow()

output.to_sql(
    "customer_segments",
    engine,
    schema="mart",
    if_exists="replace",
    index=False
)

print("Segmentation completed and saved to mart.customer_segments")