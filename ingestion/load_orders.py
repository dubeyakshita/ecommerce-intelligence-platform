import pandas as pd
from sqlalchemy import create_engine

DB_URL = "postgresql://ecommerce:ecommerce@localhost:5432/ecommerce_db"

engine = create_engine(DB_URL)

def load_orders():
    file_path = "../data/raw/olist_orders_dataset.csv"
    
    df = pd.read_csv(file_path)
    df.columns = df.columns.str.lower()

    df.to_sql(
        "orders",
        engine,
        schema="raw",
        if_exists="replace",
        index=False
    )

    print("Orders loaded successfully!")

if __name__ == "__main__":
    load_orders()
