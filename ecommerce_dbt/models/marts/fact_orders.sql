{{ config(
    materialized='table',
    schema='mart'
) }}

with order_items_agg as (

    select
        order_id,
        count(*) as total_items,
        sum(price) as total_product_value,
        sum(freight_value) as total_freight_value,
        sum(price + freight_value) as total_order_value
    from {{ ref('stg_order_items') }}
    group by order_id

),

order_reviews_agg as (

    select
        order_id,
        avg(review_score) as review_score
    from {{ ref('stg_reviews') }}
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.order_purchase_ts,
    oi.total_items,
    oi.total_product_value,
    oi.total_freight_value,
    oi.total_order_value,
    r.review_score
from {{ ref('stg_orders') }} o
left join order_items_agg oi
    on o.order_id = oi.order_id
left join order_reviews_agg r
    on o.order_id = r.order_id
