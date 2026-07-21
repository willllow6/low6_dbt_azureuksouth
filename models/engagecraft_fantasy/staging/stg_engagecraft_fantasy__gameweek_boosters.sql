with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'gameweek_booster') }}

),

renamed as (

    select

        ---------- ids
        id as gameweek_booster_id,
        fantasy_team_id,
        gameweek_id,
        booster_id,
        player_12th_man_id,
        max_captain_player_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,

        ---------- numerics
        max_captain_points,

        ---------- booleans
        is_cancelled,
        processed,

        ---------- timestamps
        max_captain_reached_at::timestamp_ntz as max_captain_reached_at,
        activated_at::timestamp_ntz as activated_at,
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
