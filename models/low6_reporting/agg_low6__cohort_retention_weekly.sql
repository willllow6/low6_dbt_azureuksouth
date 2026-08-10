{{ config(materialized='table') }}

-- One row per (game_id, game_type, tenant_name, cohort_week, activity_week).
-- cohort_week / activity_week are Mondays in US Eastern time, per the low6_reporting
-- standard (distinct from the Europe/London local_timezone used in per-domain aggs).
-- Users who never entered are excluded entirely -- they never appear in {game}_entries.

with

--------------------------------------------------------------------------------
-- prizekings_comps
-- Split into two games by contest_type -- 'Spot the Ball' and 'Raffle' -- instead
-- of using the tenant as the game name (tenant_name is still tracked separately).
--------------------------------------------------------------------------------

pk_entries as (

    select
        e.user_id,
        t.tenant_name,
        case c.contest_type
            when 'spot_the_ball' then 'prizekings_comps_spot_the_ball'
            when 'draw' then 'prizekings_comps_raffle'
        end as game_id,
        case c.contest_type
            when 'spot_the_ball' then 'Spot the Ball'
            when 'draw' then 'Raffle'
        end as game_name,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', e.entered_at) as date)) as activity_week
    from {{ ref('fct_prizekings_comps__entries') }} as e
    inner join {{ ref('dim_prizekings_comps__tenants') }} as t
        on e.tenant_id = t.tenant_id
    inner join {{ ref('dim_prizekings_comps__contests') }} as c
        on e.contest_sk = c.contest_sk

),

pk_cohort_weeks as (

    select user_id, tenant_name, game_id, game_name, min(activity_week) as cohort_week
    from pk_entries
    group by 1, 2, 3, 4

),

pk_cohort_sizes as (

    select cohort_week, tenant_name, game_id, count(distinct user_id) as cohort_size
    from pk_cohort_weeks
    group by 1, 2, 3

),

pk_user_activity as (

    select
        e.user_id,
        cw.tenant_name,
        cw.game_id,
        cw.game_name,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from pk_entries as e
    inner join pk_cohort_weeks as cw
        on e.user_id = cw.user_id
        and e.tenant_name = cw.tenant_name
        and e.game_id = cw.game_id

),

game_prizekings_comps as (

    select
        ua.game_id,
        ua.game_name,
        'prize_competition' as game_type,
        'prizekings' as client_id,
        'adfprizekingsraffle' as source_schema,
        'low6_azureuksouth' as source_database,
        ua.tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from pk_user_activity as ua
    inner join pk_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
        and ua.tenant_name = cs.tenant_name
        and ua.game_id = cs.game_id
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- pivot_bracket (single game / single tenant)
--------------------------------------------------------------------------------

pvt_entries as (

    select
        user_id,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', entered_at::timestamp_ntz) as date)) as activity_week
    from {{ ref('fct_pivot_bracket__entries') }}

),

pvt_cohort_weeks as (

    select user_id, min(activity_week) as cohort_week
    from pvt_entries
    group by 1

),

pvt_cohort_sizes as (

    select cohort_week, count(distinct user_id) as cohort_size
    from pvt_cohort_weeks
    group by 1

),

pvt_user_activity as (

    select
        e.user_id,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from pvt_entries as e
    inner join pvt_cohort_weeks as cw
        on e.user_id = cw.user_id

),

game_pivot_bracket as (

    select
        'pivot_bracket' as game_id,
        'Pivot Bracket' as game_name,
        'bracket' as game_type,
        'pivot' as client_id,
        'adfpivotbracket' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from pvt_user_activity as ua
    inner join pvt_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- tipman_pickem (single-tenant)
--------------------------------------------------------------------------------

tip_entries as (

    select
        user_id,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', entered_at) as date)) as activity_week
    from {{ ref('fct_tipman_pickem__entries') }}

),

tip_cohort_weeks as (

    select user_id, min(activity_week) as cohort_week
    from tip_entries
    group by 1

),

tip_cohort_sizes as (

    select cohort_week, count(distinct user_id) as cohort_size
    from tip_cohort_weeks
    group by 1

),

tip_user_activity as (

    select
        e.user_id,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from tip_entries as e
    inner join tip_cohort_weeks as cw
        on e.user_id = cw.user_id

),

game_tipman_pickem as (

    select
        'tipman_pickem' as game_id,
        'Tipman Pickem' as game_name,
        'pickem' as game_type,
        'tipman' as client_id,
        'adftipmanpickem' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from tip_user_activity as ua
    inner join tip_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- engagecraft_fantasy (single-tenant)
--------------------------------------------------------------------------------

eng_entries as (

    select
        user_id,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', joined_at) as date)) as activity_week
    from {{ ref('fct_engagecraft_fantasy__league_entries') }}

),

eng_cohort_weeks as (

    select user_id, min(activity_week) as cohort_week
    from eng_entries
    group by 1

),

eng_cohort_sizes as (

    select cohort_week, count(distinct user_id) as cohort_size
    from eng_cohort_weeks
    group by 1

),

eng_user_activity as (

    select
        e.user_id,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from eng_entries as e
    inner join eng_cohort_weeks as cw
        on e.user_id = cw.user_id

),

game_engagecraft_fantasy as (

    select
        'engagecraft_fantasy' as game_id,
        'EngageCraft Fantasy' as game_name,
        'fantasy' as game_type,
        'engagecraft' as client_id,
        'adfengagecraftfantasy' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from eng_user_activity as ua
    inner join eng_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- oddschecker_spintowin (single-tenant)
--------------------------------------------------------------------------------

occ_entries as (

    select
        user_id,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', spun_at) as date)) as activity_week
    from {{ ref('fct_oddschecker_spintowin__spins') }}

),

occ_cohort_weeks as (

    select user_id, min(activity_week) as cohort_week
    from occ_entries
    group by 1

),

occ_cohort_sizes as (

    select cohort_week, count(distinct user_id) as cohort_size
    from occ_cohort_weeks
    group by 1

),

occ_user_activity as (

    select
        e.user_id,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from occ_entries as e
    inner join occ_cohort_weeks as cw
        on e.user_id = cw.user_id

),

game_oddschecker_spintowin as (

    select
        'oddschecker_spintowin' as game_id,
        'Oddschecker Spin to Win' as game_name,
        'instant_win' as game_type,
        'oddschecker' as client_id,
        'adfoddscheckerspintowin' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from occ_user_activity as ua
    inner join occ_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- seven_days -- four products, each its own game_id; multi-tenant by site.
-- Test games (is_prod = false, surfaced as game_name = 'Test') are excluded.
--------------------------------------------------------------------------------

sd_entries as (

    select
        user_id,
        game_name,
        tenant_name,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', created_at) as date)) as activity_week
    from {{ ref('mart_seven_days__entries') }}
    where game_name != 'Test'

),

sd_cohort_weeks as (

    select user_id, game_name, tenant_name, min(activity_week) as cohort_week
    from sd_entries
    group by 1, 2, 3

),

sd_cohort_sizes as (

    select cohort_week, game_name, tenant_name, count(distinct user_id) as cohort_size
    from sd_cohort_weeks
    group by 1, 2, 3

),

sd_user_activity as (

    select
        e.user_id,
        cw.game_name,
        cw.tenant_name,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from sd_entries as e
    inner join sd_cohort_weeks as cw
        on e.user_id = cw.user_id
        and e.game_name = cw.game_name
        and e.tenant_name = cw.tenant_name

),

game_seven_days as (

    select
        'seven_days_' || lower(replace(ua.game_name, ' ', '_')) as game_id,
        ua.game_name,
        'instant_win' as game_type,
        '7days_performance' as client_id,
        'adf7days' as source_schema,
        'low6_azureuksouth' as source_database,
        ua.tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from sd_user_activity as ua
    inner join sd_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
        and ua.game_name = cs.game_name
        and ua.tenant_name = cs.tenant_name
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- itv_spinoff (single-tenant)
--------------------------------------------------------------------------------

itv_entries as (

    select
        user_id,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', attempted_at::timestamp_ntz) as date)) as activity_week
    from {{ ref('itv_spinoff__quiz_attempts') }}

),

itv_cohort_weeks as (

    select user_id, min(activity_week) as cohort_week
    from itv_entries
    group by 1

),

itv_cohort_sizes as (

    select cohort_week, count(distinct user_id) as cohort_size
    from itv_cohort_weeks
    group by 1

),

itv_user_activity as (

    select
        e.user_id,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from itv_entries as e
    inner join itv_cohort_weeks as cw
        on e.user_id = cw.user_id

),

game_itv_spinoff as (

    select
        'itv_spinoff' as game_id,
        'ITV Spin Off' as game_name,
        'daily_quiz' as game_type,
        'itv' as client_id,
        'adfitvspinoff' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from itv_user_activity as ua
    inner join itv_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- itv_spinoff_live (live_quiz, single-tenant)
--------------------------------------------------------------------------------

itv_live_entries as (

    select
        user_id,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', attempted_at::timestamp_ntz) as date)) as activity_week
    from {{ ref('int_itv_spinoff__live_quiz_attempts') }}
    where quiz_id in (
        '54f7c2d5-5afc-4d40-bb6f-24eb5ee3267a',
        '8c2d077b-d7a3-49ad-9648-fb36fde1cea0',
        'f64efe62-ba48-4ea2-a227-2bc375bfbe22',
        '044ec7c1-1af0-4817-8cff-d9f79475972e'
    )

),

itv_live_cohort_weeks as (

    select user_id, min(activity_week) as cohort_week
    from itv_live_entries
    group by 1

),

itv_live_cohort_sizes as (

    select cohort_week, count(distinct user_id) as cohort_size
    from itv_live_cohort_weeks
    group by 1

),

itv_live_user_activity as (

    select
        e.user_id,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from itv_live_entries as e
    inner join itv_live_cohort_weeks as cw
        on e.user_id = cw.user_id

),

game_itv_spinoff_live as (

    select
        'itv_spinoff_live' as game_id,
        'ITV Spin Off Live' as game_name,
        'live_quiz' as game_type,
        'itv' as client_id,
        'adfitvspinofflive' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from itv_live_user_activity as ua
    inner join itv_live_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

),

--------------------------------------------------------------------------------
-- gaming1 (pickem, multi-tenant)
--------------------------------------------------------------------------------

-- tenant_name is resolved via e.tenant_id -> dim_gaming1__tenants (the contest's tenant), not from
-- dim_gaming1__users: gaming1's users.location is null for every row in production, so a user's
-- tenant can't be resolved off the user record alone.
g1_entries as (

    select
        e.user_id,
        coalesce(t.tenant_name, e.client_id) as tenant_name,
        date_trunc('week', cast(convert_timezone('UTC', 'America/New_York', e.entered_at) as date)) as activity_week
    from {{ ref('fct_gaming1__entries') }} as e
    left join {{ ref('dim_gaming1__tenants') }} as t
        on e.tenant_id = t.tenant_id

),

g1_cohort_weeks as (

    select user_id, tenant_name, min(activity_week) as cohort_week
    from g1_entries
    group by 1, 2

),

g1_cohort_sizes as (

    select cohort_week, tenant_name, count(distinct user_id) as cohort_size
    from g1_cohort_weeks
    group by 1, 2

),

g1_user_activity as (

    select
        e.user_id,
        cw.tenant_name,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from g1_entries as e
    inner join g1_cohort_weeks as cw
        on e.user_id = cw.user_id
        and e.tenant_name = cw.tenant_name

),

game_gaming1 as (

    select
        'gaming1' as game_id,
        'Gaming1' as game_name,
        'pickem' as game_type,
        'gaming1' as client_id,
        'adfgaming1picks' as source_schema,
        'low6_azureuksouth' as source_database,
        ua.tenant_name,
        ua.cohort_week,
        ua.activity_week,
        ua.weeks_since_cohort,
        cs.cohort_size,
        count(distinct ua.user_id) as retained_users,
        round(count(distinct ua.user_id) / nullif(cs.cohort_size, 0), 4) as retention_rate
    from g1_user_activity as ua
    inner join g1_cohort_sizes as cs
        on ua.cohort_week = cs.cohort_week
        and ua.tenant_name = cs.tenant_name
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, cs.cohort_size

)

select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_prizekings_comps
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_pivot_bracket
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_tipman_pickem
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_engagecraft_fantasy
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_oddschecker_spintowin
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_seven_days
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_itv_spinoff
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_itv_spinoff_live
union all
select
    game_id, game_name, game_type, client_id, source_schema, source_database,
    tenant_name, cohort_week, activity_week, weeks_since_cohort, cohort_size,
    retained_users, retention_rate
from game_gaming1
