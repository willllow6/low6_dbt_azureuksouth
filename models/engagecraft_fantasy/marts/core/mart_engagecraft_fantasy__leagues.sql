with

leagues as (

    select *
    from {{ ref('dim_engagecraft_fantasy__leagues') }}

),

leagues_joined as (

    select
        league_id,
        count(*) as total_joined
    from {{ ref('fct_engagecraft_fantasy__league_entries') }}
    group by 1

),

joined as (

    select
        l.league_id,
        l.league_name,
        l.league_type,
        l.tournament_id,
        l.commissioner_user_id,
        l.regenerated_from_league_id,
        l.is_public,
        l.is_celebrity,
        l.roll_over_league,
        l.country_code,
        l.club_id,
        l.start_gameweek,
        l.client_id,
        l.tenant_id,
        l.tenant_name,
        l.game_type,
        coalesce(lj.total_joined, 0) as total_joined,
        l.created_at,
        l.updated_at
    from leagues as l
    left join leagues_joined as lj
        on l.league_id = lj.league_id

)

select * from joined
