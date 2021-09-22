## Think about when you might want to use a view vs. a table. What are the relevant tradeoffs? 

When it comes to building data models, my first instinct is that when query performance allows, views are generally preferable to tables because they simply take up less space in your database. In most cases, if you materialized all your staging and mart models as tables, you'd end up with a lot of duplicated information (e.g. the same column of `order_id`s repeated in each table). Then again, depending on the context, maybe storage isn't always a huge concern and you would prefer to speed up your queries with table materializations wherever possible. I'm also not very sure about how to weigh the extra computational power it would take to execute a complex view against the extra storage space taken up by a table. 

Models materialized as tables would also be more prone to data staleness if, for instance, the time between a source table update and your model update is significant. A view written against the source table can fetch the fresh data once the source is updated, whereas there might be some non-trivial wait time to query a table model that's out of sync with the source while its own refresh job is stuck in the queue. Then again, sometimes "stale" (or rather persistent) data is good! For instance, if you implemented a randomization for A/B testing or an RCT in a view, you'd need to store that in a table to keep track of your assignments over time. The same logic would apply to any "snapshot" model meant to capture the state of the data at a given point in time. 

There's always a tradeoff, but my gut says that views are generally a wise starting place for most modeling projects, and that tables should mainly be considered when you start to run into performance constraints or need to fulfill a special use case. 

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