select
  date_trunc(first_order_at, month) as first_order_month
  ,count(distinct customer_id) as n_customers
from {{ref('customers')}}
group by 1