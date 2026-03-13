with

source as (

    select *
    from {{ source('pivot_bracket', 'tournaments') }}

),

renamed as (

    select

        ----------  ids
        id as tournament_id,

        ---------- strings
        name as tournament_name,
        description as tournament_description,
        status as tournament_status,

        ---------- numerics

        ---------- booleans

        ---------- dates
        cast(created_at as date) as created_date,
        cast(convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as date) as created_date_et,

        ---------- timestamps
        opens_at as tournament_opens_at,
        closes_at as tournament_closes_at,
        start_date as tournament_starts_at,
        end_date as tournament_ends_at,
        created_at,
        updated_at 

    from source


)

select * from renamed
