with

scores as (

    select *
    from {{ ref('fct_engagecraft_fantasy__player_gameweek_scores') }}

),

players as (

    select
        fantasy_player_id,
        player_id,
        full_name,
        fantasy_position,
        playing_position,
        team_name,
        team_short_name,
        tournament_group,
        nationality,
        ownership_pct
    from {{ ref('dim_engagecraft_fantasy__players') }}

),

gameweeks as (

    select
        gameweek_id,
        gameweek_number,
        gameweek_name,
        starts_at,
        ends_at
    from {{ ref('dim_engagecraft_fantasy__gameweeks') }}

),

joined as (

    select
        s.player_gameweek_id,
        s.fantasy_player_id,
        s.gameweek_id,
        p.player_id,
        p.full_name,
        p.fantasy_position,
        p.playing_position,
        p.team_name,
        p.team_short_name,
        p.tournament_group,
        p.nationality,
        p.ownership_pct,
        g.gameweek_number,
        g.gameweek_name,
        g.starts_at,
        g.ends_at,
        s.gameweek_points,
        s.goal_bonus_normal_points,
        s.goal_bonus_captain_points,
        s.minutes_played,
        s.ppm_points,
        s.client_id,
        s.tenant_id,
        s.tenant_name,
        s.game_type,
        s.created_at,
        s.updated_at
    from scores as s
    left join players as p
        on s.fantasy_player_id = p.fantasy_player_id
    left join gameweeks as g
        on s.gameweek_id = g.gameweek_id

)

select * from joined
