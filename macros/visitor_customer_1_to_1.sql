{% test visitor_customer_1_to_1(model, column_name) %}

with validation as (
    select 
       {{column_name}}
       ,count(distinct visitor_id) as n_visitor_ids
    from {{model}}
    where {{column_name}} is not null
    group by 1
)
, validation_errors as (
    select * from validation 
    where n_visitor_ids > 1
)
select * from validation_errors

{% endtest %}