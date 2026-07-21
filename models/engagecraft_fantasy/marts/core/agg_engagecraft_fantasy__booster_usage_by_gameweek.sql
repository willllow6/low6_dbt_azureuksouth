with

activations as (

    select
        gameweek_booster_id,
        fantasy_team_id,
        gameweek_id,
        booster_id,
        is_cancelled
    from {{ ref('fct_engagecraft_fantasy__booster_activations') }}

),

booster_info as (

    select
        booster_id,
        booster_code,
        booster_name
    from {{ ref('stg_engagecraft_fantasy__boosters') }}

),

gameweeks as (

    select
        gameweek_id,
        gameweek_number,
        gameweek_name,
        starts_at,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('dim_engagecraft_fantasy__gameweeks') }}

),

aggregated as (

    select
        a.gameweek_id,
        a.booster_id,
        count(*) as total_activations,
        sum(case when a.is_cancelled then 1 else 0 end) as cancelled_activations,
        count(*) - sum(case when a.is_cancelled then 1 else 0 end) as net_activations,
        count(distinct a.fantasy_team_id) as teams_using_booster
    from activations as a
    group by 1, 2

),

enriched as (

    select
        ag.gameweek_id,
        g.gameweek_number,
        g.gameweek_name,
        g.starts_at,
        ag.booster_id,
        bi.booster_code,
        bi.booster_name,
        g.client_id,
        g.tenant_id,
        g.tenant_name,
        g.game_type,
        ag.total_activations,
        ag.cancelled_activations,
        ag.net_activations,
        ag.teams_using_booster
    from aggregated as ag
    left join gameweeks as g
        on ag.gameweek_id = g.gameweek_id
    left join booster_info as bi
        on ag.booster_id = bi.booster_id

)

select * from enriched
