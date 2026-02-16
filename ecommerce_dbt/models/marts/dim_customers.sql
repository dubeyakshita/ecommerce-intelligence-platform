{{ config(
    materialized='table',
    schema='mart'
) }}

SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    MIN(o.order_purchase_ts) AS first_order_ts,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(f.total_order_value), 0) AS total_spent
FROM {{ ref('stg_customers') }} c
LEFT JOIN {{ ref('stg_orders') }} o
    ON c.customer_id = o.customer_id
LEFT JOIN {{ ref('fact_orders') }} f
    ON o.order_id = f.order_id
GROUP BY
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state
