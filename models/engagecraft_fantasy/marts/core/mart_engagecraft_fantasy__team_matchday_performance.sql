with

snapshots as (

    select *
    from {{ ref('fct_engagecraft_fantasy__team_matchday_snapshots') }}

),

fantasy_teams as (

    select
        fantasy_team_id,
        user_id,
        username,
        tournament_id,
        team_name,
        formation,
        budget_remaining,
        captain_fantasy_player_id,
        vice_captain_fantasy_player_id
    from {{ ref('dim_engagecraft_fantasy__fantasy_teams') }}

),

matchdays as (

    select
        matchday_id,
        matchday_number,
        matchday_name,
        matchday_status,
        starts_at,
        ends_at
    from {{ ref('dim_engagecraft_fantasy__matchdays') }}

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
        s.matchday_id,
        ft.user_id,
        ft.username,
        ft.tournament_id,
        ft.team_name,
        ft.formation,
        ft.budget_remaining,
        m.matchday_number,
        m.matchday_name,
        m.matchday_status,
        m.starts_at,
        m.ends_at,
        s.total_points,
        s.matchday_rank,
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
    left join matchdays as m
        on s.matchday_id = m.matchday_id
    left join captain as c
        on ft.captain_fantasy_player_id = c.fantasy_player_id
    left join vice_captain as vc
        on ft.vice_captain_fantasy_player_id = vc.fantasy_player_id

)

select * from joined
