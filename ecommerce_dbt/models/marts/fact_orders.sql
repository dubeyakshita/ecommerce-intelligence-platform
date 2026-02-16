{{ config(
    materialized='table',
    schema='mart'
) }}

SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_ts,
    SUM(oi.price) AS total_product_value,
    SUM(oi.freight_value) AS total_freight_value,
    SUM(oi.price + oi.freight_value) AS total_order_value
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_order_items') }} oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_purchase_ts
