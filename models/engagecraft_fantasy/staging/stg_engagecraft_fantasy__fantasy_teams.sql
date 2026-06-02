with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_team') }}

),

renamed as (

    select

        ---------- ids
        id as fantasy_team_id,
        user_id,
        tournament_calendar_id as tournament_id,
        captain_fantasy_player_id,
        vice_captain_fantasy_player_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        team_name,
        formation,

        ---------- numerics
        budget_remaining,
        transfers_used,
        substitutions_used,
        pending_transfer_count,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
