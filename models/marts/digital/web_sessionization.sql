with pageviews as (
    select * from `dbt-tutorial-324521.dbt_bsorensen.user_stitching`
)
,minutes_between_sessions as (
select 
   id
   ,visitor_id
   ,session_recorded_at
   ,date_diff(
      session_recorded_at, 
      lag(session_recorded_at) over (partition by visitor_id order by session_recorded_at), 
      second
    ) / 60.0 as minutes_since_last_session
from pageviews
)  
,new_sessions as (
select 
   id
   ,visitor_id
   ,session_recorded_at
   ,case when coalesce(minutes_since_last_session > 30.0, true) then 1 else 0 end as is_new_session
from minutes_between_sessions
) 
,final as (
select 
   id
   ,sum(is_new_session) over (partition by visitor_id order by session_recorded_at) as session_id
from new_sessions
) 
select 
   pageviews.id 
   ,concat(pageviews.visitor_id, '__s', final.session_id) as session_id 
   ,pageviews.visitor_id
   ,pageviews.customer_id
   ,pageviews.device_type
   ,pageviews.page 
   ,pageviews.session_recorded_at 
   ,pageviews.original_visitor_id
from pageviews 
left join final on
    pageviews.id = final.id
order by pageviews.session_recorded_at
