{% test greater_than_zero(model, column_name) %}

with validation as (

    select
        {{ column_name }} as validation_field

    from {{ model }}

),

validation_errors as (

    select
        validation_field

    from validation
    -- if this is true, then even_field is actually odd!
    where validation_field <= 0

)

select *
from validation_errors

{% endtest %}