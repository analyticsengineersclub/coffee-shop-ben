{% set product_categories = ['coffee beans', 'merch', 'brewing supplies'] %}

select
  date_trunc(order_created_at, month) as date_month,
  {% for product_category in product_categories %}
  sum(case when product_category = '{{ product_category }}' then price_at_order_creation end) 
    as {{ product_category | replace(" ", "_" )}}_amount{% if not loop.last %},{% endif %}
  {% endfor %}
-- you may have to `ref` a different model here, depending on what you've built previously
from {{ ref('order_item_revenues') }}
group by 1

