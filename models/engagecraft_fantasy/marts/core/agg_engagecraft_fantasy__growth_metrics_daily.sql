with

date_spine as (

    select dateadd(day, seq4(), '{{ var("engagecraft_fantasy_start_date") }}'::date) as date_day
    from table(generator(rowcount => 600))
    where dateadd(day, seq4(), '{{ var("engagecraft_fantasy_start_date") }}'::date) <= sysdate()

),

registrations as (

    select
        cast(created_at as date) as date_day,
        count(*) as registrations,
        count(*) as pre_mini_reg_registrations,
        sum(case when favourite_club_id is not null then 1 else 0 end) as post_mini_reg_registrations
    from {{ ref('dim_engagecraft_fantasy__users') }}
    group by 1

),

teams_created as (

    select
        cast(created_at as date) as date_day,
        count(*) as teams_created
    from {{ ref('dim_engagecraft_fantasy__fantasy_teams') }}
    group by 1

),

transfers_confirmed as (

    select
        cast(applied_at as date) as date_day,
        count(*) as transfers_confirmed
    from {{ ref('fct_engagecraft_fantasy__transfers') }}
    where transfer_status = 'applied'
    group by 1

),

boosters_applied as (

    select
        cast(activated_at as date) as date_day,
        count(*) as boosters_applied
    from {{ ref('fct_engagecraft_fantasy__booster_activations') }}
    where is_cancelled = false
    group by 1

),

my_created_leagues as (

    select
        cast(created_at as date) as date_day,
        count(*) as my_created_leagues
    from {{ ref('dim_engagecraft_fantasy__leagues') }}
    where league_type = 'mini_league'
    group by 1

),

leagues_joined as (

    select
        cast(le.joined_at as date) as date_day,
        count(*) as total_leagues_joined,
        sum(case when l.league_type = 'club' then 1 else 0 end) as club_leagues_joined,
        sum(case when l.league_type = 'national' then 1 else 0 end) as national_leagues_joined,
        sum(case when l.league_type = 'mini_league' then 1 else 0 end) as my_created_leagues_joined
    from {{ ref('fct_engagecraft_fantasy__league_entries') }} as le
    left join {{ ref('dim_engagecraft_fantasy__leagues') }} as l
        on le.league_id = l.league_id
    group by 1

)

select
    d.date_day,
    'engagecraft' as client_id,
    'engagecraft' as tenant_id,
    'engagecraft' as tenant_name,
    'fantasy' as game_type,
    coalesce(r.registrations, 0) as registrations,
    coalesce(r.pre_mini_reg_registrations, 0) as pre_mini_reg_registrations,
    coalesce(r.post_mini_reg_registrations, 0) as post_mini_reg_registrations,
    coalesce(tc.teams_created, 0) as teams_created,
    coalesce(tr.transfers_confirmed, 0) as transfers_confirmed,
    coalesce(ba.boosters_applied, 0) as boosters_applied,
    coalesce(mc.my_created_leagues, 0) as my_created_leagues,
    coalesce(lj.total_leagues_joined, 0) as total_leagues_joined,
    coalesce(lj.club_leagues_joined, 0) as club_leagues_joined,
    coalesce(lj.national_leagues_joined, 0) as national_leagues_joined,
    coalesce(lj.my_created_leagues_joined, 0) as my_created_leagues_joined
from date_spine as d
left join registrations as r
    on d.date_day = r.date_day
left join teams_created as tc
    on d.date_day = tc.date_day
left join transfers_confirmed as tr
    on d.date_day = tr.date_day
left join boosters_applied as ba
    on d.date_day = ba.date_day
left join my_created_leagues as mc
    on d.date_day = mc.date_day
left join leagues_joined as lj
    on d.date_day = lj.date_day
