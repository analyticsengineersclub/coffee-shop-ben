with raw_spine as (
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2021-01-01' as date)",
    end_date="cast('2022-01-01' as date)"
   )
}}
)
select 
   date_day 
   ,date_trunc(date_day, week) as date_week
   ,date_trunc(date_day, month) as date_month
from raw_spine 