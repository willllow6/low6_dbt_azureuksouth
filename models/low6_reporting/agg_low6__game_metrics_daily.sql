{{ config(materialized='table') }}

-- One row per (date_day, game_id, game_type, tenant_name), covering every active game domain.
-- purchases/gross_revenue/dpu/first_purchases/wpu/mpu are populated for seven_days (each
-- session is a ticket purchase) and prizekings_comps (each wallet deposit is treated as a
-- purchase for this table). All other domains leave these columns null -- oddschecker prize
-- payouts are payouts, not purchases. See agg_{domain}__financial_metrics_daily for domains
-- with a proper financial model.

with

date_spine as (

    select dateadd(day, seq4(), '2025-01-01'::date) as date_day
    from table(generator(rowcount => 1500))
    where dateadd(day, seq4(), '2025-01-01'::date) <= current_date()

),

--------------------------------------------------------------------------------
-- prizekings_comps (prize_competition, multi-tenant)
-- One row per tenant -- previously split into two games by contest_type ('Spot the
-- Ball' and 'Raffle'), but that duplicated tenant-level metrics (registrations,
-- wallet deposits) identically onto both rows, since neither is tied to a single
-- contest_type. Collapsed back to a single game_id per tenant.
--------------------------------------------------------------------------------

pk_entries_raw as (

    select
        e.user_id,
        e.client_id,
        t.tenant_name,
        cast(e.entered_at as date) as date_day
    from {{ ref('fct_prizekings_comps__entries') }} as e
    inner join {{ ref('dim_prizekings_comps__tenants') }} as t
        on e.tenant_id = t.tenant_id

),

pk_combos as (

    select distinct client_id, tenant_name from pk_entries_raw

),

pk_spine_combos as (

    select d.date_day, c.client_id, c.tenant_name
    from date_spine as d
    cross join pk_combos as c

),

pk_daily as (

    select
        date_day,
        tenant_name,
        count(*) as entries,
        count(distinct user_id) as dau
    from pk_entries_raw
    group by 1, 2

),

pk_wau as (

    select
        sp.date_day,
        sp.tenant_name,
        count(distinct e.user_id) as wau
    from pk_spine_combos as sp
    left join pk_entries_raw as e
        on e.tenant_name = sp.tenant_name
        and e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1, 2

),

pk_mau as (

    select
        sp.date_day,
        sp.tenant_name,
        count(distinct e.user_id) as mau
    from pk_spine_combos as sp
    left join pk_entries_raw as e
        on e.tenant_name = sp.tenant_name
        and e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1, 2

),

pk_first_entries as (

    select date_day, tenant_name, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            tenant_name,
            row_number() over (partition by user_id order by date_day) as rn
        from pk_entries_raw
    )
    where rn = 1
    group by 1, 2

),

pk_regs_raw as (

    select
        date_day,
        tenant_name,
        sum(new_registrations) as registrations
    from {{ ref('agg_prizekings_comps__registration_metrics_daily') }}
    group by 1, 2

),

-- Wallet deposits, treated as purchases for this table.
pk_deposits_raw as (

    select
        d.user_id,
        t.tenant_name,
        cast(d.transaction_created_at as date) as date_day,
        d.amount as revenue
    from {{ ref('fct_prizekings_comps__deposits') }} as d
    inner join {{ ref('dim_prizekings_comps__tenants') }} as t
        on d.tenant_id = t.tenant_id

),

pk_deposits_daily as (

    select
        date_day,
        tenant_name,
        count(*) as purchases,
        sum(revenue) as gross_revenue,
        count(distinct user_id) as dpu
    from pk_deposits_raw
    group by 1, 2

),

pk_wpu as (

    select
        sp.date_day,
        sp.tenant_name,
        count(distinct p.user_id) as wpu
    from pk_spine_combos as sp
    left join pk_deposits_raw as p
        on p.tenant_name = sp.tenant_name
        and p.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1, 2

),

pk_mpu as (

    select
        sp.date_day,
        sp.tenant_name,
        count(distinct p.user_id) as mpu
    from pk_spine_combos as sp
    left join pk_deposits_raw as p
        on p.tenant_name = sp.tenant_name
        and p.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1, 2

),

pk_first_purchases as (

    select date_day, tenant_name, count(distinct user_id) as first_purchases
    from (
        select
            user_id,
            tenant_name,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from pk_deposits_raw
    )
    where rn = 1
    group by 1, 2

),

game_prizekings_comps as (

    select
        sp.date_day,
        'prizekings_comps' as game_id,
        'Prizekings' as game_name,
        'prize_competition' as game_type,
        'prizekings' as client_id,
        'adfprizekingsraffle' as source_schema,
        'low6_azureuksouth' as source_database,
        sp.tenant_name,
        coalesce(reg.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        coalesce(dep.purchases, 0) as purchases,
        coalesce(dep.gross_revenue, 0) as gross_revenue,
        coalesce(dep.dpu, 0) as dpu,
        coalesce(fp.first_purchases, 0) as first_purchases,
        coalesce(wp.wpu, 0) as wpu,
        coalesce(mp.mpu, 0) as mpu
    from pk_spine_combos as sp
    left join pk_daily as d on sp.date_day = d.date_day and sp.tenant_name = d.tenant_name
    left join pk_wau as w on sp.date_day = w.date_day and sp.tenant_name = w.tenant_name
    left join pk_mau as m on sp.date_day = m.date_day and sp.tenant_name = m.tenant_name
    left join pk_first_entries as fe
        on sp.date_day = fe.date_day and sp.tenant_name = fe.tenant_name
    left join pk_regs_raw as reg on sp.date_day = reg.date_day and sp.tenant_name = reg.tenant_name
    left join pk_deposits_daily as dep on sp.date_day = dep.date_day and sp.tenant_name = dep.tenant_name
    left join pk_wpu as wp on sp.date_day = wp.date_day and sp.tenant_name = wp.tenant_name
    left join pk_mpu as mp on sp.date_day = mp.date_day and sp.tenant_name = mp.tenant_name
    left join pk_first_purchases as fp on sp.date_day = fp.date_day and sp.tenant_name = fp.tenant_name
    where sp.date_day >= (select min(date_day) from pk_entries_raw)

),

--------------------------------------------------------------------------------
-- pivot_bracket (bracket, single game / single tenant)
-- Staging carries no client_id/tenant_id/game_type -- hardcoded here. Customer-level
-- tenant/game-name splitting was dropped; treated as one game with no tenant.
--------------------------------------------------------------------------------

pvt_entries_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', 'America/New_York', entered_at::timestamp_ntz) as date) as date_day
    from {{ ref('fct_pivot_bracket__entries') }}

),

pvt_users_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', 'America/New_York', created_at::timestamp_ntz) as date) as date_day
    from {{ ref('dim_pivot_bracket__users') }}

),

pvt_daily as (

    select date_day, count(*) as entries, count(distinct user_id) as dau
    from pvt_entries_raw
    group by 1

),

pvt_wau as (

    select
        sp.date_day,
        count(distinct e.user_id) as wau
    from date_spine as sp
    left join pvt_entries_raw as e
        on e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1

),

pvt_mau as (

    select
        sp.date_day,
        count(distinct e.user_id) as mau
    from date_spine as sp
    left join pvt_entries_raw as e
        on e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1

),

pvt_regs as (

    select date_day, count(distinct user_id) as registrations
    from pvt_users_raw
    group by 1

),

pvt_first_entries as (

    select date_day, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from pvt_entries_raw
    )
    where rn = 1
    group by 1

),

game_pivot_bracket as (

    select
        sp.date_day,
        'pivot_bracket' as game_id,
        'Pivot Bracket' as game_name,
        'bracket' as game_type,
        'pivot' as client_id,
        'adfpivotbracket' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from date_spine as sp
    left join pvt_daily as d on sp.date_day = d.date_day
    left join pvt_wau as w on sp.date_day = w.date_day
    left join pvt_mau as m on sp.date_day = m.date_day
    left join pvt_regs as r on sp.date_day = r.date_day
    left join pvt_first_entries as fe on sp.date_day = fe.date_day
    where sp.date_day >= (select min(date_day) from pvt_entries_raw)

),

--------------------------------------------------------------------------------
-- tipman_pickem (pickem, single-tenant)
--------------------------------------------------------------------------------

tip_entries_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date) as date_day
    from {{ ref('fct_tipman_pickem__entries') }}

),

tip_users_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', registered_at) as date) as date_day
    from {{ ref('dim_tipman_pickem__users') }}

),

tip_daily as (

    select date_day, count(*) as entries, count(distinct user_id) as dau
    from tip_entries_raw
    group by 1

),

tip_wau as (

    select
        sp.date_day,
        count(distinct e.user_id) as wau
    from date_spine as sp
    left join tip_entries_raw as e
        on e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1

),

tip_mau as (

    select
        sp.date_day,
        count(distinct e.user_id) as mau
    from date_spine as sp
    left join tip_entries_raw as e
        on e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1

),

tip_regs as (

    select date_day, count(distinct user_id) as registrations
    from tip_users_raw
    group by 1

),

tip_first_entries as (

    select date_day, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from tip_entries_raw
    )
    where rn = 1
    group by 1

),

game_tipman_pickem as (

    select
        sp.date_day,
        'tipman_pickem' as game_id,
        'Tipman Pickem' as game_name,
        'pickem' as game_type,
        'tipman' as client_id,
        'adftipmanpickem' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from date_spine as sp
    left join tip_daily as d on sp.date_day = d.date_day
    left join tip_wau as w on sp.date_day = w.date_day
    left join tip_mau as m on sp.date_day = m.date_day
    left join tip_regs as r on sp.date_day = r.date_day
    left join tip_first_entries as fe on sp.date_day = fe.date_day
    where sp.date_day >= (select min(date_day) from tip_entries_raw)

),

--------------------------------------------------------------------------------
-- engagecraft_fantasy (fantasy, single-tenant)
--------------------------------------------------------------------------------

eng_entries_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', joined_at) as date) as date_day
    from {{ ref('fct_engagecraft_fantasy__league_entries') }}

),

eng_users_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', created_at) as date) as date_day
    from {{ ref('dim_engagecraft_fantasy__users') }}

),

eng_daily as (

    select date_day, count(*) as entries, count(distinct user_id) as dau
    from eng_entries_raw
    group by 1

),

eng_wau as (

    select
        sp.date_day,
        count(distinct e.user_id) as wau
    from date_spine as sp
    left join eng_entries_raw as e
        on e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1

),

eng_mau as (

    select
        sp.date_day,
        count(distinct e.user_id) as mau
    from date_spine as sp
    left join eng_entries_raw as e
        on e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1

),

eng_regs as (

    select date_day, count(distinct user_id) as registrations
    from eng_users_raw
    group by 1

),

eng_first_entries as (

    select date_day, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from eng_entries_raw
    )
    where rn = 1
    group by 1

),

game_engagecraft_fantasy as (

    select
        sp.date_day,
        'engagecraft_fantasy' as game_id,
        'EngageCraft Fantasy' as game_name,
        'fantasy' as game_type,
        'engagecraft' as client_id,
        'adfengagecraftfantasy' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from date_spine as sp
    left join eng_daily as d on sp.date_day = d.date_day
    left join eng_wau as w on sp.date_day = w.date_day
    left join eng_mau as m on sp.date_day = m.date_day
    left join eng_regs as r on sp.date_day = r.date_day
    left join eng_first_entries as fe on sp.date_day = fe.date_day
    where sp.date_day >= (select min(date_day) from eng_entries_raw)

),

--------------------------------------------------------------------------------
-- oddschecker_spintowin (single-tenant)
-- game_type is 'instant_win' as hardcoded in stg_oddschecker_spintowin__users --
-- carried through as-is even though the domain name suggests 'spin_to_win'.
--------------------------------------------------------------------------------

occ_entries_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', spun_at) as date) as date_day
    from {{ ref('fct_oddschecker_spintowin__spins') }}

),

occ_users_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', registered_at) as date) as date_day
    from {{ ref('fct_oddschecker_spintowin__registrations') }}

),

occ_daily as (

    select date_day, count(*) as entries, count(distinct user_id) as dau
    from occ_entries_raw
    group by 1

),

occ_wau as (

    select
        sp.date_day,
        count(distinct e.user_id) as wau
    from date_spine as sp
    left join occ_entries_raw as e
        on e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1

),

occ_mau as (

    select
        sp.date_day,
        count(distinct e.user_id) as mau
    from date_spine as sp
    left join occ_entries_raw as e
        on e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1

),

occ_regs as (

    select date_day, count(distinct user_id) as registrations
    from occ_users_raw
    group by 1

),

occ_first_entries as (

    select date_day, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from occ_entries_raw
    )
    where rn = 1
    group by 1

),

game_oddschecker_spintowin as (

    select
        sp.date_day,
        'oddschecker_spintowin' as game_id,
        'Oddschecker Spin to Win' as game_name,
        'instant_win' as game_type,
        'oddschecker' as client_id,
        'adfoddscheckerspintowin' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from date_spine as sp
    left join occ_daily as d on sp.date_day = d.date_day
    left join occ_wau as w on sp.date_day = w.date_day
    left join occ_mau as m on sp.date_day = m.date_day
    left join occ_regs as r on sp.date_day = r.date_day
    left join occ_first_entries as fe on sp.date_day = fe.date_day
    where sp.date_day >= (select min(date_day) from occ_entries_raw)

),

--------------------------------------------------------------------------------
-- seven_days -- four distinct instant-win products under one domain, each its
-- own game_id, multi-tenant by site. No registration source exists for this
-- domain (raw sources are sessions + games only), so registrations is proxied
-- by first_entries (a user's first entry into that game/tenant).
-- Test games (is_prod = false, surfaced as game_name = 'Test') are excluded.
--------------------------------------------------------------------------------

sd_entries_raw as (

    select
        user_id,
        game_name,
        tenant_name,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', created_at) as date) as date_day
    from {{ ref('mart_seven_days__entries') }}
    where game_name != 'Test'

),

sd_combos as (

    select distinct game_name, tenant_name from sd_entries_raw

),

sd_spine_combos as (

    select d.date_day, c.game_name, c.tenant_name
    from date_spine as d
    cross join sd_combos as c

),

sd_daily as (

    select
        date_day,
        game_name,
        tenant_name,
        count(*) as entries,
        count(distinct user_id) as dau
    from sd_entries_raw
    group by 1, 2, 3

),

sd_wau as (

    select
        sp.date_day,
        sp.game_name,
        sp.tenant_name,
        count(distinct e.user_id) as wau
    from sd_spine_combos as sp
    left join sd_entries_raw as e
        on e.game_name = sp.game_name
        and e.tenant_name = sp.tenant_name
        and e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1, 2, 3

),

sd_mau as (

    select
        sp.date_day,
        sp.game_name,
        sp.tenant_name,
        count(distinct e.user_id) as mau
    from sd_spine_combos as sp
    left join sd_entries_raw as e
        on e.game_name = sp.game_name
        and e.tenant_name = sp.tenant_name
        and e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1, 2, 3

),

sd_first_entries as (

    select date_day, game_name, tenant_name, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            game_name,
            tenant_name,
            date_day,
            row_number() over (partition by user_id, game_name order by date_day) as rn
        from sd_entries_raw
    )
    where rn = 1
    group by 1, 2, 3

),

-- Each session is one purchase (grouping one or more tickets bought together), not each
-- entry/ticket -- so purchases/dpu/wpu/mpu/first_purchases are computed at session grain.
sd_purchases_raw as (

    select
        session_id,
        user_id,
        game_name,
        tenant_name,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', created_at) as date) as date_day,
        sum(ticket_price) as revenue
    from {{ ref('mart_seven_days__entries') }}
    where game_name != 'Test'
    group by 1, 2, 3, 4, 5

),

sd_purchases_daily as (

    select
        date_day,
        game_name,
        tenant_name,
        count(*) as purchases,
        sum(revenue) as gross_revenue,
        count(distinct user_id) as dpu
    from sd_purchases_raw
    group by 1, 2, 3

),

sd_wpu as (

    select
        sp.date_day,
        sp.game_name,
        sp.tenant_name,
        count(distinct p.user_id) as wpu
    from sd_spine_combos as sp
    left join sd_purchases_raw as p
        on p.game_name = sp.game_name
        and p.tenant_name = sp.tenant_name
        and p.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1, 2, 3

),

sd_mpu as (

    select
        sp.date_day,
        sp.game_name,
        sp.tenant_name,
        count(distinct p.user_id) as mpu
    from sd_spine_combos as sp
    left join sd_purchases_raw as p
        on p.game_name = sp.game_name
        and p.tenant_name = sp.tenant_name
        and p.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1, 2, 3

),

sd_first_purchases as (

    select date_day, game_name, tenant_name, count(distinct user_id) as first_purchases
    from (
        select
            user_id,
            game_name,
            tenant_name,
            date_day,
            row_number() over (partition by user_id, game_name order by date_day) as rn
        from sd_purchases_raw
    )
    where rn = 1
    group by 1, 2, 3

),

game_seven_days as (

    select
        sp.date_day,
        'seven_days_' || lower(replace(sp.game_name, ' ', '_')) as game_id,
        sp.game_name as game_name,
        'instant_win' as game_type,
        '7days_performance' as client_id,
        'adf7days' as source_schema,
        'low6_azureuksouth' as source_database,
        sp.tenant_name,
        coalesce(fe.first_entries, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        coalesce(pd.purchases, 0) as purchases,
        coalesce(pd.gross_revenue, 0) as gross_revenue,
        coalesce(pd.dpu, 0) as dpu,
        coalesce(fp.first_purchases, 0) as first_purchases,
        coalesce(wp.wpu, 0) as wpu,
        coalesce(mp.mpu, 0) as mpu
    from sd_spine_combos as sp
    left join sd_daily as d
        on sp.date_day = d.date_day and sp.game_name = d.game_name and sp.tenant_name = d.tenant_name
    left join sd_wau as w
        on sp.date_day = w.date_day and sp.game_name = w.game_name and sp.tenant_name = w.tenant_name
    left join sd_mau as m
        on sp.date_day = m.date_day and sp.game_name = m.game_name and sp.tenant_name = m.tenant_name
    left join sd_first_entries as fe
        on sp.date_day = fe.date_day and sp.game_name = fe.game_name and sp.tenant_name = fe.tenant_name
    left join sd_purchases_daily as pd
        on sp.date_day = pd.date_day and sp.game_name = pd.game_name and sp.tenant_name = pd.tenant_name
    left join sd_wpu as wp
        on sp.date_day = wp.date_day and sp.game_name = wp.game_name and sp.tenant_name = wp.tenant_name
    left join sd_mpu as mp
        on sp.date_day = mp.date_day and sp.game_name = mp.game_name and sp.tenant_name = mp.tenant_name
    left join sd_first_purchases as fp
        on sp.date_day = fp.date_day and sp.game_name = fp.game_name and sp.tenant_name = fp.tenant_name
    where sp.date_day >= (select min(date_day) from sd_entries_raw)

),

--------------------------------------------------------------------------------
-- itv_spinoff (daily_quiz, single-tenant)
-- No model in this domain carries client_id/tenant_id/game_type -- hardcoded here.
--------------------------------------------------------------------------------

itv_entries_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', attempted_at::timestamp_ntz) as date) as date_day
    from {{ ref('itv_spinoff__quiz_attempts') }}

),

itv_users_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', created_at::timestamp_ntz) as date) as date_day
    from {{ ref('itv_spinoff__users') }}

),

itv_daily as (

    select date_day, count(*) as entries, count(distinct user_id) as dau
    from itv_entries_raw
    group by 1

),

itv_wau as (

    select
        sp.date_day,
        count(distinct e.user_id) as wau
    from date_spine as sp
    left join itv_entries_raw as e
        on e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1

),

itv_mau as (

    select
        sp.date_day,
        count(distinct e.user_id) as mau
    from date_spine as sp
    left join itv_entries_raw as e
        on e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1

),

itv_regs as (

    select date_day, count(distinct user_id) as registrations
    from itv_users_raw
    group by 1

),

itv_first_entries as (

    select date_day, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from itv_entries_raw
    )
    where rn = 1
    group by 1

),

game_itv_spinoff as (

    select
        sp.date_day,
        'itv_spinoff' as game_id,
        'ITV Spin Off' as game_name,
        'daily_quiz' as game_type,
        'itv' as client_id,
        'adfitvspinoff' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from date_spine as sp
    left join itv_daily as d on sp.date_day = d.date_day
    left join itv_wau as w on sp.date_day = w.date_day
    left join itv_mau as m on sp.date_day = m.date_day
    left join itv_regs as r on sp.date_day = r.date_day
    left join itv_first_entries as fe on sp.date_day = fe.date_day
    where sp.date_day >= (select min(date_day) from itv_entries_raw)

),

--------------------------------------------------------------------------------
-- itv_spinoff_live (live_quiz, single-tenant)
-- Scheduled synchronous quiz feature of the itv_spinoff domain, sourced from the
-- itv_spinoff_live source tables. Same user base as itv_spinoff -- registrations
-- is left null here rather than double-counting itv_spinoff's registrations.
--------------------------------------------------------------------------------

itv_live_entries_raw as (

    select
        user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', attempted_at::timestamp_ntz) as date) as date_day
    from {{ ref('int_itv_spinoff__live_quiz_attempts') }}
    where quiz_id in (
        '54f7c2d5-5afc-4d40-bb6f-24eb5ee3267a',
        '8c2d077b-d7a3-49ad-9648-fb36fde1cea0',
        'f64efe62-ba48-4ea2-a227-2bc375bfbe22',
        '044ec7c1-1af0-4817-8cff-d9f79475972e'
    )

),

itv_live_daily as (

    select date_day, count(*) as entries, count(distinct user_id) as dau
    from itv_live_entries_raw
    group by 1

),

itv_live_wau as (

    select
        sp.date_day,
        count(distinct e.user_id) as wau
    from date_spine as sp
    left join itv_live_entries_raw as e
        on e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1

),

itv_live_mau as (

    select
        sp.date_day,
        count(distinct e.user_id) as mau
    from date_spine as sp
    left join itv_live_entries_raw as e
        on e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1

),

itv_live_first_entries as (

    select date_day, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            row_number() over (partition by user_id order by date_day) as rn
        from itv_live_entries_raw
    )
    where rn = 1
    group by 1

),

game_itv_spinoff_live as (

    select
        sp.date_day,
        'itv_spinoff_live' as game_id,
        'ITV Spin Off Live' as game_name,
        'live_quiz' as game_type,
        'itv' as client_id,
        'adfitvspinofflive' as source_schema,
        'low6_azureuksouth' as source_database,
        null as tenant_name,
        null::integer as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from date_spine as sp
    left join itv_live_daily as d on sp.date_day = d.date_day
    left join itv_live_wau as w on sp.date_day = w.date_day
    left join itv_live_mau as m on sp.date_day = m.date_day
    left join itv_live_first_entries as fe on sp.date_day = fe.date_day
    where sp.date_day >= (select min(date_day) from itv_live_entries_raw)

),

--------------------------------------------------------------------------------
-- gaming1 (pickem, multi-tenant)
--------------------------------------------------------------------------------

-- tenant_name is resolved via e.tenant_id -> dim_gaming1__tenants (the contest's tenant), not from
-- dim_gaming1__users: gaming1's users.location is null for every row in production, so a user's
-- tenant can't be resolved off the user record alone. Registrations reuse
-- agg_gaming1__registration_metrics_daily's per-tenant resolution (via each user's first entry).
g1_entries_raw as (

    select
        e.user_id,
        coalesce(t.tenant_name, e.client_id) as tenant_name,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', e.entered_at) as date) as date_day
    from {{ ref('fct_gaming1__entries') }} as e
    left join {{ ref('dim_gaming1__tenants') }} as t
        on e.tenant_id = t.tenant_id

),

g1_combos as (

    select distinct tenant_name from g1_entries_raw

),

g1_spine_combos as (

    select d.date_day, c.tenant_name
    from date_spine as d
    cross join g1_combos as c

),

g1_daily as (

    select
        date_day,
        tenant_name,
        count(*) as entries,
        count(distinct user_id) as dau
    from g1_entries_raw
    group by 1, 2

),

g1_wau as (

    select
        sp.date_day,
        sp.tenant_name,
        count(distinct e.user_id) as wau
    from g1_spine_combos as sp
    left join g1_entries_raw as e
        on e.tenant_name = sp.tenant_name
        and e.date_day between dateadd(day, -6, sp.date_day) and sp.date_day
    group by 1, 2

),

g1_mau as (

    select
        sp.date_day,
        sp.tenant_name,
        count(distinct e.user_id) as mau
    from g1_spine_combos as sp
    left join g1_entries_raw as e
        on e.tenant_name = sp.tenant_name
        and e.date_day between dateadd(day, -27, sp.date_day) and sp.date_day
    group by 1, 2

),

g1_first_entries as (

    select date_day, tenant_name, count(distinct user_id) as first_entries
    from (
        select
            user_id,
            date_day,
            tenant_name,
            row_number() over (partition by user_id order by date_day) as rn
        from g1_entries_raw
    )
    where rn = 1
    group by 1, 2

),

g1_regs as (

    select
        date_day,
        tenant_name,
        sum(new_registrations) as registrations
    from {{ ref('agg_gaming1__registration_metrics_daily') }}
    group by 1, 2

),

game_gaming1 as (

    select
        sp.date_day,
        'gaming1' as game_id,
        'Gaming1' as game_name,
        'pickem' as game_type,
        'gaming1' as client_id,
        'adfgaming1picks' as source_schema,
        'low6_azureuksouth' as source_database,
        sp.tenant_name,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.entries, 0) as entries,
        coalesce(d.dau, 0) as dau,
        coalesce(w.wau, 0) as wau,
        coalesce(m.mau, 0) as mau,
        coalesce(fe.first_entries, 0) as first_entries,
        null::integer as purchases,
        null::number as gross_revenue,
        null::integer as dpu,
        null::integer as first_purchases,
        null::integer as wpu,
        null::integer as mpu
    from g1_spine_combos as sp
    left join g1_daily as d on sp.date_day = d.date_day and sp.tenant_name = d.tenant_name
    left join g1_wau as w on sp.date_day = w.date_day and sp.tenant_name = w.tenant_name
    left join g1_mau as m on sp.date_day = m.date_day and sp.tenant_name = m.tenant_name
    left join g1_first_entries as fe on sp.date_day = fe.date_day and sp.tenant_name = fe.tenant_name
    left join g1_regs as r on sp.date_day = r.date_day and sp.tenant_name = r.tenant_name
    where sp.date_day >= (select min(date_day) from g1_entries_raw)

)

select * from game_prizekings_comps
union all
select * from game_pivot_bracket
union all
select * from game_tipman_pickem
union all
select * from game_engagecraft_fantasy
union all
select * from game_oddschecker_spintowin
union all
select * from game_seven_days
union all
select * from game_itv_spinoff
union all
select * from game_itv_spinoff_live
union all
select * from game_gaming1
