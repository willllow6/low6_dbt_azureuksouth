-- One row per site (tenant) per first-entry cohort week per activity week (production
-- instances only). Standard cohort columns plus revenue for LTV curves:
--   cohort_week                Monday of the UK week of the player's first entry on the site
--   retained_users             cohort players with an entry in activity_week
--   cohort_revenue             cohort players' spend in activity_week
--   cumulative_revenue_per_player / cumulative_net_revenue_known_per_player
--                              spend (less known payout: ticket credit amount, else the
--                              prize's known value) per cohort player up to activity_week
-- Every week from the cohort week to the current week has a row, including weeks with no
-- retained players, so the cumulative curves have no gaps.

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prizes as (

    select *
    from {{ ref('dim_seven_days__prizes') }}

),

prod_entries as (

    select
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        date_trunc('week', e.entry_date_uk)                 as activity_week,
        e.entered_at,
        e.entry_fee,
        coalesce(e.won_prize_amount, p.prize_value, 0)      as payout_known
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    left join prizes as p
        on e.prize_id = p.prize_id
    where c.is_prod

),

user_weeks as (

    select
        tenant_id,
        user_id,
        activity_week,
        sum(entry_fee)                                      as spend,
        sum(payout_known)                                   as payout_known
    from prod_entries
    group by 1, 2, 3

),

user_cohorts as (

    select
        tenant_id,
        user_id,
        min(activity_week)                                  as cohort_week
    from user_weeks
    group by 1, 2

),

tenants as (

    select distinct
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from prod_entries

),

cohorts as (

    select
        tenant_id,
        cohort_week,
        count(*)                                            as cohort_size
    from user_cohorts
    group by 1, 2

),

weeks as (

    select distinct
        tenant_id,
        activity_week
    from user_weeks

),

cohort_activity as (

    select
        c.tenant_id,
        c.cohort_week,
        w.activity_week,
        count(*)                                            as retained_users,
        sum(w.spend)                                        as cohort_revenue,
        sum(w.payout_known)                                 as cohort_payout_known
    from user_cohorts as c
    inner join user_weeks as w
        on  c.tenant_id = w.tenant_id
        and c.user_id = w.user_id
    group by 1, 2, 3

),

spine as (

    select
        c.tenant_id,
        c.cohort_week,
        w.activity_week,
        c.cohort_size
    from cohorts as c
    inner join weeks as w
        on  c.tenant_id = w.tenant_id
        and w.activity_week >= c.cohort_week

),

final as (

    select
        s.cohort_week,
        s.activity_week,
        t.client_id,
        s.tenant_id,
        t.tenant_name,
        t.game_type,
        datediff(week, s.cohort_week, s.activity_week)              as weeks_since_cohort,
        s.cohort_size,
        coalesce(a.retained_users, 0)                               as retained_users,
        round(coalesce(a.retained_users, 0) / s.cohort_size, 4)     as retention_rate,
        coalesce(a.cohort_revenue, 0)                               as cohort_revenue,
        round(sum(coalesce(a.cohort_revenue, 0)) over (
            partition by s.tenant_id, s.cohort_week order by s.activity_week
            rows between unbounded preceding and current row
        ) / s.cohort_size, 2)                                       as cumulative_revenue_per_player,
        round(sum(coalesce(a.cohort_revenue, 0) - coalesce(a.cohort_payout_known, 0)) over (
            partition by s.tenant_id, s.cohort_week order by s.activity_week
            rows between unbounded preceding and current row
        ) / s.cohort_size, 2)                                       as cumulative_net_revenue_known_per_player
    from spine as s
    inner join tenants as t
        on s.tenant_id = t.tenant_id
    left join cohort_activity as a
        on  s.tenant_id = a.tenant_id
        and s.cohort_week = a.cohort_week
        and s.activity_week = a.activity_week

)

select * from final
