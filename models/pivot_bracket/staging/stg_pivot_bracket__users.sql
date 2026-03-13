with

source as (

    select *
    from {{ source('pivot_bracket', 'users') }}
    
),

renamed as (

    select

        ----------  ids
        id as user_id,
        customer_id,
        account_number,

        ---------- strings
        first_name,
        last_name,
        email,
        phone,
        username,
        country,
        city,
        state,
        allow_marketing_notifications as has_consented_marketing,

        ---------- numerics

        ---------- booleans

        ---------- dates
        cast(created_at as date) as created_date,
        cast(convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as date) as created_date_et,
        date_of_birth,

        ---------- timestamps
        created_at,
        convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as created_at_et,
        updated_at

    from source


)

select * from renamed