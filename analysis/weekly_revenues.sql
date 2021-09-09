with order_item_revenues as (
    select * from ref('order_item_revenues')
)

select 
   date_trunc(order_created_at, week)
   ,product_category
   ,customer_type
   ,sum(price_at_order_creation) as total_revenues
from order_item_revenues
group by 1, 2, 3
order by 1, 2, 3
