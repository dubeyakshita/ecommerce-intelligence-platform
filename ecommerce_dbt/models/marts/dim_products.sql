{{ config(
    materialized='table',
    schema='mart'
) }}

SELECT
    p.product_id,
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    AVG(r.review_score) AS avg_review_score
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_order_items') }} oi
    ON p.product_id = oi.product_id
LEFT JOIN {{ ref('stg_reviews') }} r
    ON oi.order_id = r.order_id
GROUP BY
    p.product_id,
    p.product_category_name
