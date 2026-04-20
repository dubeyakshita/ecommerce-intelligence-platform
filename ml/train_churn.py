import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_auc_score
import joblib
from datetime import datetime

# -------------------------------
# 1. DB Connection
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
# 2. Load Data
# -------------------------------

query = "SELECT * FROM analytics_mart.customer_churn_features"
df = pd.read_sql(query, engine)

print(f"Loaded {len(df)} customers")

# -------------------------------
# 3. Feature Selection
# -------------------------------

feature_cols = [
    "total_orders",
    "total_revenue",
    "avg_order_value",
    "total_items",
    "avg_review_score",
    "recent_orders",
    "recent_revenue"
]

X = df[feature_cols].copy()
y = df["is_churned"]

# Handle missing values
X["avg_review_score"] = X["avg_review_score"].fillna(
    X["avg_review_score"].mean()
)

# Log transform
X["total_revenue"] = np.log1p(X["total_revenue"])
X["avg_order_value"] = np.log1p(X["avg_order_value"])

# -------------------------------
# 4. Train-Test Split
# -------------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# -------------------------------
# 5. Scaling
# -------------------------------

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# -------------------------------
# 6. Model (Handle Imbalance)
# -------------------------------

model = LogisticRegression(class_weight="balanced", max_iter=1000)
model.fit(X_train_scaled, y_train)

# -------------------------------
# 7. Evaluation
# -------------------------------

y_pred = model.predict(X_test_scaled)
y_prob = model.predict_proba(X_test_scaled)[:, 1]

print("\nClassification Report:\n")
print(classification_report(y_test, y_pred))

roc = roc_auc_score(y_test, y_prob)
print(f"ROC-AUC Score: {roc:.4f}")

# -------------------------------
# 8. Save Model
# -------------------------------

joblib.dump(model, "churn_model.pkl")
joblib.dump(scaler, "churn_scaler.pkl")

# -------------------------------
# 9. Write Predictions to DB
# -------------------------------

df["churn_probability"] = model.predict_proba(
    scaler.transform(X)
)[:, 1]

output = df[["customer_id", "churn_probability"]].copy()
output["created_at"] = datetime.utcnow()

output.to_sql(
    "customer_churn_predictions",
    engine,
    schema="mart",
    if_exists="replace",
    index=False
)

print("\nChurn predictions saved to mart.customer_churn_predictions")