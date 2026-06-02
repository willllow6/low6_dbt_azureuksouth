with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_player_matchday') }}

),

renamed as (

    select

        ---------- ids
        id as player_matchday_id,
        fantasy_player_id,
        matchday_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,

        ---------- numerics
        points as matchday_points,
        goal_bonus_normal_points,
        goal_bonus_captain_points,
        minutes_played,
        bonus_points,

        ---------- semi-structured
        stats,

        ---------- timestamps
        max_captain_reached_at::timestamp_ntz as max_captain_reached_at,
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
