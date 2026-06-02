with

matchdays as (

    select
        matchday_id,
        tournament_id,
        matchday_number,
        matchday_name,
        matchday_status,
        starts_at,
        ends_at,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('dim_engagecraft_fantasy__matchdays') }}

),

team_perf as (

    select
        matchday_id,
        count(distinct fantasy_team_id) as teams_with_scores,
        avg(total_points) as avg_team_points,
        max(total_points) as top_team_points,
        sum(total_points) as total_points_distributed
    from {{ ref('fct_engagecraft_fantasy__team_matchday_snapshots') }}
    group by 1

),

transfers_confirmed as (

    select
        target_matchday_id as matchday_id,
        count(*) as transfers_confirmed
    from {{ ref('fct_engagecraft_fantasy__transfers') }}
    where transfer_status = 'applied'
    group by 1

),

boosters_applied as (

    select
        matchday_id,
        count(*) as boosters_applied,
        count(distinct fantasy_team_id) as teams_using_boosters
    from {{ ref('fct_engagecraft_fantasy__booster_activations') }}
    where is_cancelled = false
    group by 1

)

select
    m.matchday_id,
    m.tournament_id,
    m.matchday_number,
    m.matchday_name,
    m.matchday_status,
    m.starts_at,
    m.ends_at,
    m.client_id,
    m.tenant_id,
    m.tenant_name,
    m.game_type,
    coalesce(tp.teams_with_scores, 0) as teams_with_scores,
    tp.avg_team_points,
    tp.top_team_points,
    coalesce(tp.total_points_distributed, 0) as total_points_distributed,
    coalesce(t.transfers_confirmed, 0) as transfers_confirmed,
    coalesce(b.boosters_applied, 0) as boosters_applied,
    coalesce(b.teams_using_boosters, 0) as teams_using_boosters
from matchdays as m
left join team_perf as tp
    on m.matchday_id = tp.matchday_id
left join transfers_confirmed as t
    on m.matchday_id = t.matchday_id
left join boosters_applied as b
    on m.matchday_id = b.matchday_id
