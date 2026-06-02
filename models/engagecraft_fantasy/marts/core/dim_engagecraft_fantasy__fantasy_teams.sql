with

fantasy_teams as (

    select *
    from {{ ref('stg_engagecraft_fantasy__fantasy_teams') }}

),

users as (

    select
        user_id,
        username
    from {{ ref('stg_engagecraft_fantasy__users') }}

),

joined as (

    select
        ft.fantasy_team_id,
        ft.user_id,
        u.username,
        ft.tournament_id,
        ft.client_id,
        ft.tenant_id,
        ft.tenant_name,
        ft.game_type,
        ft.team_name,
        ft.formation,
        ft.budget_remaining,
        ft.captain_fantasy_player_id,
        ft.vice_captain_fantasy_player_id,
        ft.transfers_used,
        ft.substitutions_used,
        ft.pending_transfer_count,
        ft.created_at,
        ft.updated_at
    from fantasy_teams as ft
    left join users as u
        on ft.user_id = u.user_id

)

select * from joined
