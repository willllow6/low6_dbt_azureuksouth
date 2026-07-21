with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'league') }}

),

renamed as (

    select

        ---------- ids
        id as league_id,
        tournament_calendar_id as tournament_id,
        commissioner_user_id,
        regenerated_from_league_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        name as league_name,
        description,
        join_code,
        type as league_type,
        country_code,
        club_id,

        ---------- numerics
        start_gameweek,

        ---------- booleans
        is_public,
        is_celebrity,
        roll_over_league,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
