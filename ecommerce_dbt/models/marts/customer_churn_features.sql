{{ config(
    materialized='table',
    schema='mart'
) }}

-- 1. Last order per customer
with last_order as (

    select
        customer_id,
        max(order_purchase_ts) as last_order_date
    from {{ ref('fact_orders') }}
    group by customer_id

),

-- 2. Global reference date (latest date in dataset)
reference_date as (

    select
        max(order_purchase_ts) as max_date
    from {{ ref('fact_orders') }}

),

-- 3. Recent activity (last 90 days before max date)
recent_activity as (

    select
        f.customer_id,
        count(*) as recent_orders,
        sum(f.total_order_value) as recent_revenue
    from {{ ref('fact_orders') }} f
    cross join reference_date r
    where f.order_purchase_ts >= r.max_date - interval '180 days'
    and f.order_purchase_ts < r.max_date - interval '90 days'
    group by f.customer_id

),

-- 4. Base table (join everything)
base as (

    select
        cf.*,
        lo.last_order_date,
        coalesce(ra.recent_orders, 0) as recent_orders,
        coalesce(ra.recent_revenue, 0) as recent_revenue
    from {{ ref('customer_features') }} cf
    join last_order lo
        on cf.customer_id = lo.customer_id
    left join recent_activity ra
        on cf.customer_id = ra.customer_id

),

-- 5. Final with churn label
final as (

    select
        b.*,
        case
            when (r.max_date - b.last_order_date) > interval '90 days' then 1
            else 0
        end as is_churned
    from base b
    cross join reference_date r

)

select * from final