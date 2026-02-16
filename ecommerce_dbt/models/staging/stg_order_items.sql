{{ config(
    materialized='table',
    schema='staging'
) }}

SELECT
    order_id,
    product_id,
    seller_id,
    price,
    freight_value
FROM {{ source('raw', 'order_items') }}
