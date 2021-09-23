## Write a query and test the timing of how long it takes the query to run under different conditions. 

Each materialization is based on the following query: 

```{sql}
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
```

When querying both models for the first time, the table had marginally better performance, but the difference was essentially erased once the queries had been cached. 

```{sql}
-- 2.5 sec elapsed, 14.8 MB processed --> .1 sec elapsed, cached
select * from `dbt-tutorial-324521.dbt_bsorensen.orders_count_table`;

-- 3.8 sec elapsed, 21.8 MB processed --> 0.0 sec elapsed, cached
select * from `dbt-tutorial-324521.dbt_bsorensen.orders_count_view`; 
```

The benefits of caching were lost, however, once the test query changed. When writing a `select count(*)` instead of `select *` on both models, the table was once again faster and cheaper. So it seems like caching would be most helpful if a single query had to be run multiple times a day, but otherwise its advantages are somewhat limited. 

If this were a bigger and/or more complex model, then the performance differences would deserve more careful consideration. But for a relatively simple model like this a view does about just as well as a table, and would be my preference.