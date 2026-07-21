with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_team_gameweek_snapshot') }}

),

renamed as (

    select

        ---------- ids
        id as snapshot_id,
        fantasy_team_id,
        gameweek_id,
        active_captain_id,
        active_vice_captain_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,

        ---------- numerics
        gameweek as gameweek_number,
        total_points,
        rank as gameweek_rank,
        goals_scored,
        assists,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
