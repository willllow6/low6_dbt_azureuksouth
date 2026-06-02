with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'league_entry') }}

),

renamed as (

    select

        ---------- ids
        id as league_entry_id,
        league_id,
        user_id,
        fantasy_team_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,

        ---------- numerics
        points as league_points,
        rank as league_rank,
        game_week as gameweek,

        ---------- timestamps
        joined_at::timestamp_ntz as joined_at

    from source

)

select * from renamed
