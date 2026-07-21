with

snapshots as (

    select *
    from {{ ref('fct_engagecraft_fantasy__team_gameweek_snapshots') }}

),

fantasy_teams as (

    select
        fantasy_team_id,
        user_id,
        username,
        tournament_id,
        team_name,
        formation,
        budget_remaining
    from {{ ref('dim_engagecraft_fantasy__fantasy_teams') }}

),

gameweeks as (

    select
        gameweek_id,
        gameweek_number,
        gameweek_name,
        gameweek_status,
        starts_at,
        ends_at
    from {{ ref('dim_engagecraft_fantasy__gameweeks') }}

),

captain as (

    select
        fantasy_player_id,
        full_name as captain_name
    from {{ ref('dim_engagecraft_fantasy__players') }}

),

vice_captain as (

    select
        fantasy_player_id,
        full_name as vice_captain_name
    from {{ ref('dim_engagecraft_fantasy__players') }}

),

joined as (

    select
        s.snapshot_id,
        s.fantasy_team_id,
        s.gameweek_id,
        ft.user_id,
        ft.username,
        ft.tournament_id,
        ft.team_name,
        ft.formation,
        ft.budget_remaining,
        g.gameweek_number,
        g.gameweek_name,
        g.gameweek_status,
        g.starts_at,
        g.ends_at,
        s.total_points,
        s.gameweek_rank,
        s.goals_scored,
        s.assists,
        c.captain_name,
        vc.vice_captain_name,
        s.client_id,
        s.tenant_id,
        s.tenant_name,
        s.game_type,
        s.created_at,
        s.updated_at
    from snapshots as s
    left join fantasy_teams as ft
        on s.fantasy_team_id = ft.fantasy_team_id
    left join gameweeks as g
        on s.gameweek_id = g.gameweek_id
    left join captain as c
        on s.active_captain_id = c.fantasy_player_id
    left join vice_captain as vc
        on s.active_vice_captain_id = vc.fantasy_player_id

)

select * from joined
