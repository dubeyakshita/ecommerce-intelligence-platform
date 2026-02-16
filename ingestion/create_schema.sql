CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA mart;

SELECT count(*) from raw.orders;

CREATE TABLE staging.stg_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_ts,
    CAST(order_approved_at AS TIMESTAMP) AS order_approved_ts,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_carrier_ts,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_ts,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_ts
FROM raw.orders;

SELECT COUNT(*) FROM staging.stg_orders;

SELECT COUNT(*) 
FROM staging.stg_orders
WHERE order_id IS NULL;

SELECT order_id, COUNT(*)
FROM staging.stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM raw.order_items;

CREATE TABLE staging.stg_customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM raw.customers;

SELECT COUNT(*) FROM staging.stg_customers;

CREATE TABLE staging.stg_order_items AS
SELECT
    order_id,
    product_id,
    seller_id,
    price,
    freight_value
FROM raw.order_items;

SELECT COUNT(*) FROM staging.stg_order_items;

CREATE TABLE staging.stg_products AS
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.products;

SELECT COUNT(*) FROM staging.stg_products;

CREATE TABLE staging.stg_payments AS
SELECT
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM raw.payments;

SELECT COUNT(*) FROM staging.stg_payments;

CREATE TABLE staging.stg_reviews AS
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_message,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_ts,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_ts
FROM raw.reviews;

SELECT COUNT(*) FROM staging.stg_reviews;

CREATE TABLE mart.fact_orders AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_ts,
    SUM(oi.price) AS total_product_value,
    SUM(oi.freight_value) AS total_freight_value,
    SUM(oi.price + oi.freight_value) AS total_order_value
FROM staging.stg_orders o
JOIN staging.stg_order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_purchase_ts;


CREATE TABLE mart.dim_customers AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    MIN(o.order_purchase_ts) AS first_order_ts,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(f.total_order_value) AS total_spent
FROM staging.stg_customers c
LEFT JOIN staging.stg_orders o
    ON c.customer_id = o.customer_id
LEFT JOIN mart.fact_orders f
    ON o.order_id = f.order_id
GROUP BY
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state;

CREATE TABLE mart.dim_products AS
SELECT
    p.product_id,
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    AVG(r.review_score) AS avg_review_score
FROM staging.stg_products p
LEFT JOIN staging.stg_order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN staging.stg_reviews r
    ON oi.order_id = r.order_id
GROUP BY
    p.product_id,
    p.product_category_name;

DROP TABLE mart.dim_customers;

CREATE TABLE mart.dim_customers AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    MIN(o.order_purchase_ts) AS first_order_ts,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(f.total_order_value), 0) AS total_spent
FROM staging.stg_customers c
LEFT JOIN staging.stg_orders o
    ON c.customer_id = o.customer_id
LEFT JOIN mart.fact_orders f
    ON o.order_id = f.order_id
GROUP BY
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state;

DROP SCHEMA staging CASCADE;
DROP SCHEMA mart CASCADE;

CREATE SCHEMA staging;
CREATE SCHEMA mart;













