import pandas as pd
from sqlalchemy import create_engine
import os

DB_URL = "postgresql://ecommerce:ecommerce@localhost:5432/ecommerce_db"

engine = create_engine(DB_URL)

DATA_PATH = "../data/raw"

FILES = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_products_dataset.csv": "products",
    "olist_order_payments_dataset.csv": "payments",
    "olist_order_reviews_dataset.csv": "reviews",
}

def load_csv(file_name, table_name):
    file_path = os.path.join(DATA_PATH, file_name)

    print(f"Loading {file_name} into raw.{table_name}...")

    df = pd.read_csv(file_path)
    df.columns = df.columns.str.lower()

    df.to_sql(
        table_name,
        engine,
        schema="raw",
        if_exists="replace",
        index=False
    )

    print(f"✓ Loaded raw.{table_name} ({len(df)} rows)\n")


if __name__ == "__main__":
    for file_name, table_name in FILES.items():
        load_csv(file_name, table_name)

    print("All raw tables loaded successfully!")
