with

snapshots as (

    select *
    from {{ ref('stg_engagecraft_fantasy__team_gameweek_snapshots') }}
    where team_state is not null

),

flattened as (

    select
        snapshots.fantasy_team_id,
        snapshots.gameweek_id,
        snapshots.gameweek_number,
        snapshots.client_id,
        snapshots.tenant_id,
        snapshots.tenant_name,
        snapshots.game_type,
        player.value:fantasyPlayerId::varchar as fantasy_player_id,
        player.value:positionSlot::integer as position_slot,
        player.value:entryType::varchar as entry_type,
        snapshots.team_state:captainFantasyPlayerId::varchar as captain_fantasy_player_id,
        snapshots.team_state:viceCaptainFantasyPlayerId::varchar as vice_captain_fantasy_player_id
    from snapshots,
        lateral flatten(input => snapshots.team_state:players) as player

),

enriched as (

    select
        fantasy_team_id,
        gameweek_id,
        gameweek_number,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        fantasy_player_id,
        position_slot,
        entry_type,
        entry_type = 'original' as is_starter,
        fantasy_player_id = captain_fantasy_player_id as is_captain,
        fantasy_player_id = vice_captain_fantasy_player_id as is_vice_captain
    from flattened

)

select * from enriched
