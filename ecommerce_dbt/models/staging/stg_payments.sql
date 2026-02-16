{{ config(
    materialized='table',
    schema='staging'
) }}

SELECT
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM {{ source('raw', 'payments') }}
