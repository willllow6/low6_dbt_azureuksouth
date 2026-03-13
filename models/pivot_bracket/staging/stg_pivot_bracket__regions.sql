with

source as (

    select *
    from {{ source('pivot_bracket', 'regions') }}

),

renamed as (

    select

        ----------  ids
        id as region_id,

        ---------- strings
        name as region_name,
        position,

        ---------- numerics

        ---------- booleans

        ---------- dates
        cast(created_at as date) as created_date,

        ---------- timestamps
        created_at,
        updated_at

    from source


)

select * from renamed