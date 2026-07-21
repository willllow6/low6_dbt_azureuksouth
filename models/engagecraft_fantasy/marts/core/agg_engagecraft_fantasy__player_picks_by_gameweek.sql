with

player_scores as (

    select
        player_gameweek_id,
        fantasy_player_id,
        gameweek_id,
        gameweek_points,
        minutes_played,
        ppm_points,
        goal_bonus_normal_points,
        goal_bonus_captain_points
    from {{ ref('fct_engagecraft_fantasy__player_gameweek_scores') }}

),

selection_counts as (

    select
        fantasy_player_id,
        count(distinct fantasy_team_id) as times_selected,
        sum(case when is_starter then 1 else 0 end) as times_started,
        sum(case when is_captain then 1 else 0 end) as times_captained,
        sum(case when is_vice_captain then 1 else 0 end) as times_vice_captained
    from {{ ref('fct_engagecraft_fantasy__selections') }}
    group by 1

),

players as (

    select
        fantasy_player_id,
        full_name,
        fantasy_position,
        playing_position,
        team_name,
        team_short_name,
        nationality,
        ownership_pct,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('dim_engagecraft_fantasy__players') }}

),

gameweeks as (

    select
        gameweek_id,
        gameweek_number,
        gameweek_name,
        starts_at
    from {{ ref('dim_engagecraft_fantasy__gameweeks') }}

),

enriched as (

    select
        ps.gameweek_id,
        g.gameweek_number,
        g.gameweek_name,
        g.starts_at,
        ps.fantasy_player_id,
        p.full_name,
        p.fantasy_position,
        p.playing_position,
        p.team_name,
        p.team_short_name,
        p.nationality,
        p.ownership_pct,
        p.client_id,
        p.tenant_id,
        p.tenant_name,
        p.game_type,
        coalesce(sc.times_selected, 0) as times_selected,
        coalesce(sc.times_started, 0) as times_started,
        coalesce(sc.times_captained, 0) as times_captained,
        coalesce(sc.times_vice_captained, 0) as times_vice_captained,
        ps.gameweek_points,
        ps.minutes_played,
        ps.ppm_points,
        ps.goal_bonus_normal_points,
        ps.goal_bonus_captain_points
    from player_scores as ps
    left join players as p
        on ps.fantasy_player_id = p.fantasy_player_id
    left join gameweeks as g
        on ps.gameweek_id = g.gameweek_id
    left join selection_counts as sc
        on ps.fantasy_player_id = sc.fantasy_player_id

)

select * from enriched
