{{ config(
    materialized='table'
) }}

with source as (
    select * from {{ source('coffee_shop', 'orders') }}
)
select 
   customer_id
   ,address 
   ,state 
   ,zip
   ,count(distinct id) as n_orders
from source 
group by 1, 2, 3, 4