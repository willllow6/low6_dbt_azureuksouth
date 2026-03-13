with

source as (

    select *
    from {{ source('pivot_bracket', 'customers') }}

),

renamed as (

    select

        ----------  ids
        id as customer_id,

        ---------- strings
        name as customer_name,
        contact_name,
        contact_email,

        ---------- numerics

        ---------- booleans
        is_active,

        ---------- dates
        cast(created_at as date) as created_date,
        cast(convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as date) as created_date_et,

        ---------- timestamps
        created_at,
        updated_at 

    from source


)

select * from renamed
