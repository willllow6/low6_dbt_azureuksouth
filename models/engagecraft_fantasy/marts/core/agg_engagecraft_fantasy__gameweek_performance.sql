with

gameweeks as (

    select
        gameweek_id,
        tournament_id,
        gameweek_number,
        gameweek_name,
        gameweek_status,
        starts_at,
        ends_at,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('dim_engagecraft_fantasy__gameweeks') }}

),

team_perf as (

    select
        gameweek_id,
        count(distinct fantasy_team_id) as teams_with_scores,
        avg(total_points) as avg_team_points,
        max(total_points) as top_team_points,
        sum(total_points) as total_points_distributed
    from {{ ref('fct_engagecraft_fantasy__team_gameweek_snapshots') }}
    group by 1

),

transfers_confirmed as (

    select
        gameweek_id,
        count(*) as transfers_confirmed
    from {{ ref('fct_engagecraft_fantasy__transfers') }}
    where transfer_status = 'applied'
    group by 1

),

boosters_applied as (

    select
        gameweek_id,
        count(*) as boosters_applied,
        count(distinct fantasy_team_id) as teams_using_boosters
    from {{ ref('fct_engagecraft_fantasy__booster_activations') }}
    where is_cancelled = false
    group by 1

)

select
    g.gameweek_id,
    g.tournament_id,
    g.gameweek_number,
    g.gameweek_name,
    g.gameweek_status,
    g.starts_at,
    g.ends_at,
    g.client_id,
    g.tenant_id,
    g.tenant_name,
    g.game_type,
    coalesce(tp.teams_with_scores, 0) as teams_with_scores,
    tp.avg_team_points,
    tp.top_team_points,
    coalesce(tp.total_points_distributed, 0) as total_points_distributed,
    coalesce(t.transfers_confirmed, 0) as transfers_confirmed,
    coalesce(b.boosters_applied, 0) as boosters_applied,
    coalesce(b.teams_using_boosters, 0) as teams_using_boosters
from gameweeks as g
left join team_perf as tp
    on g.gameweek_id = tp.gameweek_id
left join transfers_confirmed as t
    on g.gameweek_id = t.gameweek_id
left join boosters_applied as b
    on g.gameweek_id = b.gameweek_id
