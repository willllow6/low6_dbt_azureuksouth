with

source as (

    select *
    from {{ source('pivot_bracket', 'brackets') }}

),

renamed as (

    select

        ----------  ids
        id as contest_id,
        customer_id,
        tournament_id,
        template_id,
        theme_id,
        -- 'BKT_' || competition as contest_sk,

        ---------- strings
        name as contest_name,
        description as contest_description,
        status as contest_status,
        bracket_type as contest_type,

        ---------- numerics

        ---------- booleans

        ---------- dates
        cast(convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as date) as created_date_et,

        ---------- timestamps
        opens_at as contest_opens_at,
        convert_timezone('UTC','America/New_York',opens_at::timestamp_ntz) as contest_opens_at_et,
        closes_at as contest_closes_at,
        convert_timezone('UTC','America/New_York',closes_at::timestamp_ntz) as contest_closes_at_et,
        tournament_start as contest_starts_at,
        convert_timezone('UTC','America/New_York',tournament_start::timestamp_ntz) as contest_starts_at_et,
        tournament_end as contest_ends_at,
        convert_timezone('UTC','America/New_York',tournament_end::timestamp_ntz) as contest_ends_at_et,
        created_at,
        convert_timezone('UTC','America/New_York',created_at::timestamp_ntz) as created_at_et,
        updated_at 

    from source


)

select * from renamed
