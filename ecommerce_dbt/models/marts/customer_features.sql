{{ config(
    materialized='table',
    schema='mart'
) }}

with customer_metrics as (

    select
        f.customer_id,
        count(distinct f.order_id) as total_orders,
        sum(coalesce(f.total_order_value, 0)) as total_revenue,
        avg(coalesce(f.total_order_value, 0)) as avg_order_value,
        sum(coalesce(f.total_items, 0)) as total_items,
        avg(f.review_score) as avg_review_score,
        max(f.order_purchase_ts) as last_order_date
    from {{ ref('fact_orders') }} f
    group by f.customer_id

),

final as (

    select
        cm.customer_id,
        cm.total_orders,
        cm.total_revenue,
        cm.avg_order_value,
        cm.total_items,
        cm.avg_review_score,
        date_part('day', current_date - cm.last_order_date) as recency_days,
        c.customer_city,
        c.customer_state
    from customer_metrics cm
    join {{ ref('dim_customers') }} c
        on cm.customer_id = c.customer_id

)

select * from final
