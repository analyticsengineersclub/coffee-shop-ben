with source as (
    select * from {{ source('web_tracking', 'pageviews') }}
),

renamed as (
    select 
        id,
        visitor_id,
        customer_id,
        device_type,
        page,
        -- timestamps 
        timestamp as session_recorded_at
    from source 
)

select * from renamed 