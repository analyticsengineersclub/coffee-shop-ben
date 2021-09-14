with order_item_revenues as (
    select * from {{ ref('order_item_revenues') }}
)
,week_dim as  (
    select distinct
       date_trunc(date_series, week) as week_date
    from unnest(
        generate_date_array(
            date('2021-01-01'), 
            date('2021-05-31'), 
            interval 1 day
        )
    ) as date_series
)
,week_customer_dim as (
    select distinct 
        week_date 
        ,customer_id 
    from week_dim 
    cross join (
        select distinct customer_id from {{ ref('customers') }}
    )
) 
, revenue_by_week  as (
    select 
        customer_id
        ,date(date_trunc(order_created_at, week)) as order_created_week
        ,sum(price_at_order_creation) as revenue 
    from order_item_revenues 
    group by 1, 2
)
, cumulative as (
   select 
      week_customer_dim.week_date
      ,week_customer_dim.customer_id
      ,revenue_by_week.revenue
      ,sum(revenue_by_week.revenue) over (partition by week_customer_dim.customer_id order by week_customer_dim.week_date) as cumulative_revenue
   from week_customer_dim  
   left join revenue_by_week on
        week_customer_dim.week_date = revenue_by_week.order_created_week and 
        week_customer_dim.customer_id = revenue_by_week.customer_id

) 
, final as (
    select 
        rank() over (partition by customer_id order by week_date) as week 
        ,week_date
        ,customer_id 
        ,coalesce(revenue, 0) as revenue
        ,cumulative_revenue
    from cumulative
    where cumulative_revenue is not null
)
select * from final 
order by customer_id, week 