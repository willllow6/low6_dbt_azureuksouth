with

source as (

    select *
    from {{ source('pivot_bracket', 'user_selection') }}

),

renamed as (

    select

        ----------  ids
        id as entry_id,
        user_id,
        bracket_id as contest_id,

        ---------- strings
        tiebreaker_answer as tiebreaker_selection,

        ---------- numerics
        points,

        ---------- booleans

        ---------- dates
        cast(created_at as date) as created_date,
        cast(convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as date) as created_date_et,

        ---------- timestamps
        created_at,
        convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as created_at_et,
        updated_at


    from source

)

select * from renamed