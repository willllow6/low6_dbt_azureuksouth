-- One row per site (tenant) per UK day with sales (production instances only). Definitions:
--   dau / wau / mau        distinct players with an entry on the day / trailing 7 / 28 days
--   new_players            first-ever entry on the site that day
--   reactivated_players    active today after more than 28 days without an entry
--   returning_players      active today, neither new nor reactivated
--   payout_known           ticket credit amount, else the prize's known value
--   payout_estimated       payout_known with unvalued prizes filled by their tier estimate
--                          (see rpt_seven_days__contest_prize_tier_summary)
--   net_revenue_estimated  gross_revenue - payout_estimated
--   incomplete_purchases   purchases with no completed_at (bought but not finished)
-- Trailing averages are over calendar days with sales. Every player pays, so revenue per DAU is also revenue per paying user. "Lapsed" activity
-- means lapsed from our games: players may still be playing competitor games in the lobby.

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

purchases as (

    select *
    from {{ ref('fct_seven_days__purchases') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prizes as (

    select *
    from {{ ref('dim_seven_days__prizes') }}

),

prize_tiers as (

    select *
    from {{ ref('rpt_seven_days__contest_prize_tier_summary') }}

),

prod_entries as (

    select
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        e.contest_id,
        e.purchase_id,
        e.entry_date_uk,
        e.entry_fee,
        coalesce(e.won_prize_amount, p.prize_value)         as payout_known,
        case
            when e.is_winner
            then coalesce(e.won_prize_amount, p.prize_value, t.tier_avg_prize_value)
        end                                                 as payout_estimated
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    left join prizes as p
        on e.prize_id = p.prize_id
    left join prize_tiers as t
        on  e.contest_id = t.contest_id
        and e.won_prize_tier = t.prize_tier
        and e.is_winner
    where c.is_prod

),

player_days as (

    select
        tenant_id,
        user_id,
        entry_date_uk,
        lag(entry_date_uk) over (
            partition by tenant_id, user_id order by entry_date_uk
        )                                                   as previous_entry_date_uk
    from prod_entries
    group by 1, 2, 3

),

player_mix as (

    select
        tenant_id,
        entry_date_uk,
        count(*)                                            as dau,
        count_if(previous_entry_date_uk is null)            as new_players,
        count_if(datediff(day, previous_entry_date_uk, entry_date_uk) > 28)
                                                            as reactivated_players,
        count_if(datediff(day, previous_entry_date_uk, entry_date_uk) <= 28)
                                                            as returning_players
    from player_days
    group by 1, 2

),

rolling_users as (

    select
        d.tenant_id,
        d.entry_date_uk,
        count(distinct case
            when p.entry_date_uk > dateadd(day, -7, d.entry_date_uk) then p.user_id
        end)                                                as wau,
        count(distinct p.user_id)                           as mau
    from player_mix as d
    inner join player_days as p
        on  d.tenant_id = p.tenant_id
        and p.entry_date_uk >  dateadd(day, -28, d.entry_date_uk)
        and p.entry_date_uk <= d.entry_date_uk
    group by 1, 2

),

sales as (

    select
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        entry_date_uk,
        count(*)                                            as entries,
        count(distinct purchase_id)                         as purchases,
        count(distinct contest_id)                          as instances_with_sales,
        sum(entry_fee)                                      as gross_revenue,
        coalesce(sum(payout_known), 0)                      as payout_known,
        coalesce(sum(payout_estimated), 0)                  as payout_estimated
    from prod_entries
    group by 1, 2, 3, 4, 5

),

incomplete as (

    select
        p.tenant_id,
        p.purchase_date_uk                                  as entry_date_uk,
        count_if(p.completed_at is null)                    as incomplete_purchases
    from purchases as p
    inner join contests as c
        on p.contest_id = c.contest_id
    where c.is_prod
    group by 1, 2

),

daily as (

    select
        s.*,
        m.dau,
        r.wau,
        r.mau,
        m.new_players,
        m.returning_players,
        m.reactivated_players,
        coalesce(i.incomplete_purchases, 0)                 as incomplete_purchases
    from sales as s
    inner join player_mix as m
        on  s.tenant_id = m.tenant_id
        and s.entry_date_uk = m.entry_date_uk
    inner join rolling_users as r
        on  s.tenant_id = r.tenant_id
        and s.entry_date_uk = r.entry_date_uk
    left join incomplete as i
        on  s.tenant_id = i.tenant_id
        and s.entry_date_uk = i.entry_date_uk

),

final as (

    select
        entry_date_uk,
        client_id,
        tenant_id,
        tenant_name,
        game_type,

        -- players
        dau,
        wau,
        mau,
        round(dau / nullif(mau, 0), 4)                              as stickiness,
        new_players,
        returning_players,
        reactivated_players,

        -- sales
        entries,
        purchases,
        instances_with_sales,
        incomplete_purchases,
        round(incomplete_purchases / nullif(purchases, 0), 4)       as incomplete_purchase_rate,
        gross_revenue,
        round(gross_revenue / nullif(dau, 0), 2)                    as revenue_per_player,
        round(purchases / nullif(dau, 0), 2)                        as purchases_per_player,
        round(gross_revenue / nullif(purchases, 0), 2)              as average_purchase_value,

        -- payout and net revenue
        payout_known,
        payout_estimated,
        gross_revenue - payout_estimated                            as net_revenue_estimated,
        round(payout_known / nullif(gross_revenue, 0), 4)           as actual_rtp_known,
        round(payout_estimated / nullif(gross_revenue, 0), 4)       as actual_rtp_estimated,

        -- trailing averages (for spotting anomalies)
        round(avg(gross_revenue) over (
            partition by tenant_id order by entry_date_uk
            range between interval '6 days' preceding and current row
        ), 2)                                                       as gross_revenue_7d_avg,
        round(avg(gross_revenue) over (
            partition by tenant_id order by entry_date_uk
            range between interval '27 days' preceding and current row
        ), 2)                                                       as gross_revenue_28d_avg,
        round(avg(dau) over (
            partition by tenant_id order by entry_date_uk
            range between interval '6 days' preceding and current row
        ), 1)                                                       as dau_7d_avg,
        round(avg(dau) over (
            partition by tenant_id order by entry_date_uk
            range between interval '27 days' preceding and current row
        ), 1)                                                       as dau_28d_avg
    from daily

)

select * from final
