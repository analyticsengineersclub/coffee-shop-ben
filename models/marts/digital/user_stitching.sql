-- Each customer_id can have multiple visitor_ids
-- Arbitrarily select one of the associated visitor_ids and overwrite the raw visitor_id with a join
with page_views as (
    select * from {{ ref('stg_coffeeshop__pageviews') }}
)
, assign_visitor_id as ( 
select 
   customer_id
   ,max(visitor_id) as visitor_id 
from page_views 
group by 1 
)
, final as (
select  
   page_views.id
   ,coalesce(assign_visitor_id.visitor_id, page_views.visitor_id) as visitor_id
   ,page_views.customer_id
   ,page_views.device_type
   ,page_views.page
   ,page_views.session_recorded_at
   ,page_views.visitor_id as original_visitor_id
from page_views 
left join assign_visitor_id on page_views.customer_id = assign_visitor_id.customer_id
)
select * from final 
