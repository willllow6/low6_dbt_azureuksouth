-- One row per site (tenant) per UK week (Monday start), production instances only. Splits
-- each week's active players and revenue by where they came from:
--   new_players          first-ever entry on the site this week
--   retained_players     also active last week
--   reactivated_players  active this week, not last week, but at some earlier week
--   churned_players      active last week, not this week (churned from our games: they may
--                        still be playing competitor games in the lobby)
--   expansion / contraction_revenue
--                        retained players' change in spend vs last week (up / down)
--   churned_revenue      last week's spend of this week's churned players
--   quick_ratio          (new + reactivated) / churned players; above 1 the base is growing
-- active_players = new + retained + reactivated; last week's active = retained + churned.
-- The current week is partial (is_complete_week = false), so its churn is overstated.

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prod_entries as (

    select
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        date_trunc('week', e.entry_date_uk)                 as activity_week,
        e.entry_fee
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod

),

tenants as (

    select distinct
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from prod_entries

),

user_weeks as (

    select
        tenant_id,
        user_id,
        activity_week,
        sum(entry_fee)                                      as spend
    from prod_entries
    group by 1, 2, 3

),

user_week_history as (

    select
        *,
        lag(activity_week) over (
            partition by tenant_id, user_id order by activity_week
        )                                                   as previous_week,
        lag(spend) over (
            partition by tenant_id, user_id order by activity_week
        )                                                   as previous_spend,
        lead(activity_week) over (
            partition by tenant_id, user_id order by activity_week
        )                                                   as next_week
    from user_weeks

),

active as (

    select
        tenant_id,
        activity_week,
        count(*)                                            as active_players,
        count_if(previous_week is null)                     as new_players,
        count_if(previous_week = dateadd(week, -1, activity_week))
                                                            as retained_players,
        count_if(previous_week < dateadd(week, -1, activity_week))
                                                            as reactivated_players,
        sum(spend)                                          as gross_revenue,
        sum(case when previous_week is null then spend else 0 end)
                                                            as new_revenue,
        sum(case when previous_week = dateadd(week, -1, activity_week) then spend else 0 end)
                                                            as retained_revenue,
        sum(case when previous_week < dateadd(week, -1, activity_week) then spend else 0 end)
                                                            as reactivated_revenue,
        sum(case
            when previous_week = dateadd(week, -1, activity_week)
            then greatest(spend - previous_spend, 0) else 0
        end)                                                as expansion_revenue,
        sum(case
            when previous_week = dateadd(week, -1, activity_week)
            then least(spend - previous_spend, 0) else 0
        end)                                                as contraction_revenue
    from user_week_history
    group by 1, 2

),

-- a player active in week W with no entry in W+1 churns in W+1
churned as (

    select
        tenant_id,
        dateadd(week, 1, activity_week)                     as activity_week,
        count(*)                                            as churned_players,
        sum(spend)                                          as churned_revenue
    from user_week_history
    where next_week is null
        or next_week > dateadd(week, 1, activity_week)
    group by 1, 2

),

final as (

    select
        a.activity_week,
        t.client_id,
        a.tenant_id,
        t.tenant_name,
        t.game_type,
        a.activity_week < date_trunc(
            'week', cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
        )                                                           as is_complete_week,

        -- players
        a.active_players,
        a.new_players,
        a.retained_players,
        a.reactivated_players,
        coalesce(c.churned_players, 0)                              as churned_players,
        round(a.retained_players / nullif(lag(a.active_players) over (
            partition by a.tenant_id order by a.activity_week
        ), 0), 4)                                                   as week_on_week_retention,
        round((a.new_players + a.reactivated_players)
            / nullif(c.churned_players, 0), 2)                      as quick_ratio,

        -- revenue
        a.gross_revenue,
        a.new_revenue,
        a.retained_revenue,
        a.reactivated_revenue,
        a.expansion_revenue,
        a.contraction_revenue,
        coalesce(c.churned_revenue, 0)                              as churned_revenue
    from active as a
    inner join tenants as t
        on a.tenant_id = t.tenant_id
    left join churned as c
        on  a.tenant_id = c.tenant_id
        and a.activity_week = c.activity_week

)

select * from final
