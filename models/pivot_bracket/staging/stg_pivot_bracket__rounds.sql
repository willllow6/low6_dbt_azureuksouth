with

source as (

    select *
    from {{ source('pivot_bracket', 'rounds') }}

),

renamed as (

    select

        ----------  ids
        id as round_id,

        ---------- strings
        name as round_name,

        ---------- numerics
        value as round_number,

        ---------- booleans

        ---------- dates
        cast(created_at as date) as created_date,

        ---------- timestamps
        created_at

    from source


)

select * from renamed