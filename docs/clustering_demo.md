## How should we cluster our data models to improve performance?

### Describe the clustering strategy you want to implement. What are the potential trade-offs?

I'm going to implement clustering for the `order_item_revenues` model I created for a previous exercise. Assuming we'll want to use the model to say something about our customers (e.g. an LTV analysis), I'm going to first partition by `customer_id`, meaning all orders and order items associated with a given customer should be stored in the same block in the database. Since the `customer_id` is verified to be non-null by a dbt test statement, I'm not very concerned about skew. Clustering by `customer_id` instead of, say, `order_id` means we can more efficiently execute joins to the `customers` table or related models. Since we're choosing to cluster by `customer_id`, there's no need to implement a secondary partition by `order_id`, since each order should only be associated to one customer. The other options would be to cluster by `product_id` or `order_created_at`, but I'm assuming customers will be the focus of our analysis and configuring my model with that in mind. 

### Implement this clustering strategy in your dbt project

I added the following snippet to the top of my `marts/finance/order_item_revenues.sql` model in a new file/model called `order_item_revenues_v2.sql`. I also changed the materialization of the original model to a `table` to make the comparison apples to apples. 

```{sql}
{{ config(
    materialized='table',
    partition_by={
      "field": "customer_id",
      "data_type": "string"
    }
)}}
```

### Verify that this improved query times. Can you come up with a query where this change will slow down the query speed?

I ran the LTV query I wrote last week (swapping in `v2` of the original `order_item_revenues` model) to test whether the clustering made a difference. I chose this query because it's fairly complex and involves partitioning by `customer_id` — since the data is already clustered by `customer_id`, the calculation of each customer's LTV-helper rows should happen more efficiently. 

With the original model, a `select *` from the LTV model took 22.0 seconds and 26.1 MB to process. With `v2`, the same query took 12.7 seconds and 26.1 MB — it was nearly twice as fast. 


I can't think of a query that would be slower with this clustering implementation than without. My intuition is that while clustering by customer isn't optimal for every type of query, it's unlikely to be _worse_ than a random distribution across blocks. Though maybe I'm not thinking about this correctly. That said, I can imagine queries where a different clustering strategy would be the more efficient choice. It might make sense to partition by `order_created_at` instead, if we're mostly interested in tracking seasonality or other time-focused trends. 