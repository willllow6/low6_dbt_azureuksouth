with

source as (

    select *
    from {{ source('pivot_bracket', 'teams') }}

),

renamed as (

    select

        ----------  ids
        id as team_id,
        tournament_id,
        region_id,

        ---------- strings
        name as team_name,

        ---------- numerics
        seed,

        ---------- booleans

        ---------- dates
        cast(created_at as date) as created_date,

        ---------- timestamps
        created_at,
        updated_at

    from source


)

select * from renamed