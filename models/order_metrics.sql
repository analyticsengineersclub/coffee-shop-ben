{{
   config(materialized='table')
}}

select
   order_id
   ,count(*) as n_products 
   ,count(distinct product_id) as n_unique_products
from {{source('coffee_shop', 'order_items')}}
group by 1