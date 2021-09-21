with order_items as (
    select * from {{ ref('stg_coffeeshop__order_items') }}
),
orders as (
    select * from {{ ref('stg_coffeeshop__orders') }}
),
product_prices as (
    select * from {{ ref('stg_coffeeshop__product_prices') }}
),
products as (
    select * from {{ ref('stg_coffeeshop__products') }}
)

select 
   orders.order_id 
   ,orders.customer_id
   ,products.product_id 
   ,products.category as product_category
   ,case when row_number() over (partition by orders.customer_id order by orders.created_at) > 1 then 'Returning'
         when row_number() over (partition by orders.customer_id order by orders.created_at) = 1 then 'New'
    end as customer_type
   ,product_prices.price as price_at_order_creation
   ,orders.created_at as order_created_at
from orders 
left join order_items  
  on orders.order_id = order_items.order_id
left join products on 
  order_items.product_id = products.product_id
left join product_prices 
  on order_items.product_id = product_prices.product_id
  and orders.created_at between product_prices.created_at and product_prices.ended_at