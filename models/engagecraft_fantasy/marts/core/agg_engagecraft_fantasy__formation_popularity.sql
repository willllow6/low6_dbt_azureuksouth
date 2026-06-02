with

fantasy_teams as (

    select
        coalesce(formation, 'Not set') as formation,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('dim_engagecraft_fantasy__fantasy_teams') }}

),

aggregated as (

    select
        formation,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        count(*) as total_teams
    from fantasy_teams
    group by 1, 2, 3, 4, 5

),

with_pct as (

    select
        formation,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        total_teams,
        round(
            total_teams / sum(total_teams) over (),
            4
        ) as pct_of_teams
    from aggregated

)

select * from with_pct
