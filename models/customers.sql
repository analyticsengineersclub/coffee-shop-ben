with customer_orders as (

   select 
      orders.customer_id
      ,count(distinct orders.id) as n_orders 
      ,min(orders.created_at) as first_order_at 
   from `analytics-engineers-club.coffee_shop.orders` orders
   group by 1
)

select 
   customers.id as customer_id,
   customers.name as full_name, 
   customers.email as email_address, 
   customer_orders.n_orders, 
   customer_orders.first_order_at
from `analytics-engineers-club.coffee_shop.customers` customers 
left join customer_orders on customers.id = customer_orders.customer_id 
order by first_order_at asc