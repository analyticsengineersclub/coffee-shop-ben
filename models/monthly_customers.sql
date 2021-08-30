select
  date_trunc(first_order_at, month) as first_order_month
  ,count(distinct customer_id) as n_customers
from `dbt-tutorial-324521.dbt_bsorensen.customers`
group by 1