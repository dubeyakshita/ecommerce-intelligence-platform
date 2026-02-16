-- Top 10 revenue-generating products
SELECT 
    product_id,
    total_revenue
FROM mart.dim_products
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 highest spending customers
SELECT
    customer_id,
    total_spent
FROM mart.dim_customers
ORDER BY total_spent DESC
LIMIT 10;

-- Monthly revenue trend
SELECT
    DATE_TRUNC('month', order_purchase_ts) AS month,
    SUM(total_order_value) AS monthly_revenue
FROM mart.fact_orders
GROUP BY month
ORDER BY month;

-- Average order value by customer state
SELECT
    customer_state,
    AVG(total_order_value) AS avg_order_value
FROM mart.fact_orders f
JOIN mart.dim_customers c
    ON f.customer_id = c.customer_id   
GROUP BY customer_state
ORDER BY avg_order_value DESC;

-- Average review score by product category
SELECT
    product_category_name,
    AVG(avg_review_score) AS avg_category_review_score
FROM mart.dim_products
GROUP BY product_category_name
ORDER BY avg_category_review_score DESC;

-- Customer retention analysis: Number of customers who made repeat purchases
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM mart.fact_orders
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_orders DESC;

