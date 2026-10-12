-- One row per game instance per UK day it had sales: revenue, payout and RTP, player mix,
-- engagement, retention, win rates and spend concentration, by days since the instance's first
-- sale. Definitions:
--   new_players          the player's first-ever entry on the site (tenant) was in this instance
--                        on this day (each player is new exactly once, so this sums across rows)
--   returning_players    active players who had already played on the site (any game, any earlier
--                        time, including another instance earlier the same day)
--   new_to_game_players  first play of this game name (any instance / price) on the site
--   d1 / d7_retention    of players playing this instance for the first time that day, share
--                        active on the site (any game) 1 / 7 days later; null until mature
--   second_play_rate     of new_players, share who made a second purchase on the site (ever)
--   repeat_purchase_rate share of active players with 2+ purchases in this instance that day
--   small_win            a win whose prize value (known, else tier estimate) <= ticket price
--   top_prize_hits       tier 1 wins
--   _known / _estimated  prize values known only / with unvalued tiers estimated
--                        (see rpt_seven_days__contest_prize_tier_summary)

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

prize_tiers as (

    select *
    from {{ ref('rpt_seven_days__contest_prize_tier_summary') }}

),

contest_rtp as (

    select *
    from {{ ref('rpt_seven_days__contest_performance_summary') }}

),

user_activity as (

    select *
    from {{ ref('fct_seven_days__user_activity_daily') }}

),

prod_entries as (

    select
        e.contest_id,
        e.tenant_id,
        e.user_id,
        c.contest_name,
        e.entry_date_uk                                     as activity_date_uk,
        e.entered_at,
        e.purchase_id,
        e.entry_fee,
        e.is_winner,
        e.won_prize_tier,
        p.prize_value                                       as prize_value_known,
        coalesce(p.prize_value, t.tier_avg_prize_value)     as prize_value_estimated
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

player_day as (

    select
        contest_id,
        tenant_id,
        user_id,
        contest_name,
        activity_date_uk,
        min(entered_at)                                     as first_entered_at,
        count(*)                                            as entries,
        sum(entry_fee)                                      as spend,
        count(distinct purchase_id)                         as purchases,
        count_if(is_winner)                                 as wins,
        count_if(is_winner and prize_value_estimated <= entry_fee) as small_wins,
        count_if(is_winner and won_prize_tier = 1)          as top_prize_hits,
        sum(prize_value_known)                              as payout_known,
        sum(prize_value_estimated)                          as payout_estimated
    from prod_entries
    group by 1, 2, 3, 4, 5

),

player_site as (

    select
        tenant_id,
        user_id,
        min_by(contest_id, first_entered_at)                as site_first_contest_id,
        min(activity_date_uk)                               as site_first_date,
        sum(purchases)                                      as site_purchases
    from player_day
    group by 1, 2

),

player_flags as (

    select
        d.*,
        d.contest_id = s.site_first_contest_id
            and d.activity_date_uk = s.site_first_date      as is_new_to_site,
        d.activity_date_uk = min(d.activity_date_uk) over (
            partition by d.tenant_id, d.user_id, d.contest_name
        )                                                   as is_new_to_game,
        d.activity_date_uk = min(d.activity_date_uk) over (
            partition by d.contest_id, d.user_id
        )                                                   as is_new_to_contest,
        s.site_purchases,
        row_number() over (
            partition by d.contest_id, d.activity_date_uk
            order by d.spend desc, d.user_id
        )                                                   as spend_rank,
        count(*) over (
            partition by d.contest_id, d.activity_date_uk
        )                                                   as day_players
    from player_day as d
    inner join player_site as s
        on  d.tenant_id = s.tenant_id
        and d.user_id = s.user_id

),

player_retention as (

    select
        f.*,
        a1.user_id is not null                              as returned_d1,
        a7.user_id is not null                              as returned_d7
    from player_flags as f
    left join user_activity as a1
        on  f.tenant_id = a1.tenant_id
        and f.user_id = a1.user_id
        and a1.activity_date_uk = dateadd(day, 1, f.activity_date_uk)
    left join user_activity as a7
        on  f.tenant_id = a7.tenant_id
        and f.user_id = a7.user_id
        and a7.activity_date_uk = dateadd(day, 7, f.activity_date_uk)

),

daily as (

    select
        contest_id,
        activity_date_uk,
        sum(entries)                                        as entries,
        sum(purchases)                                      as purchases,
        sum(spend)                                          as gross_revenue,
        sum(payout_known)                                   as payout_known,
        sum(payout_estimated)                               as payout_estimated,
        count(*)                                            as active_players,
        count_if(is_new_to_site)                            as new_players,
        count_if(not is_new_to_site)                        as returning_players,
        count_if(is_new_to_game)                            as new_to_game_players,
        count_if(is_new_to_contest)                         as new_to_contest_players,
        count_if(is_new_to_contest and returned_d1)         as retained_d1_players,
        count_if(is_new_to_contest and returned_d7)         as retained_d7_players,
        count_if(is_new_to_site and site_purchases >= 2)    as new_players_with_second_play,
        count_if(purchases >= 2)                            as repeat_purchase_players,
        median(spend)                                       as median_spend_per_player,
        percentile_cont(0.9) within group (order by spend)  as p90_spend_per_player,
        sum(case when spend_rank <= ceil(day_players * 0.01) then spend end)
                                                            as top_1pct_players_revenue,
        sum(wins)                                           as wins,
        sum(small_wins)                                     as small_wins,
        sum(top_prize_hits)                                 as top_prize_hits
    from player_retention
    group by 1, 2

),

final as (

    select
        d.contest_id,
        c.client_id,
        c.tenant_id,
        c.tenant_name,
        c.game_type,
        c.contest_name,
        c.contest_status,
        c.ticket_price,
        d.activity_date_uk,
        datediff(
            day,
            min(d.activity_date_uk) over (partition by d.contest_id),
            d.activity_date_uk
        )                                                   as days_since_launch,

        -- revenue, payout, RTP
        d.gross_revenue,
        d.payout_known,
        d.payout_estimated,
        round(d.payout_known / nullif(d.gross_revenue, 0), 4)       as actual_rtp_known,
        round(d.payout_estimated / nullif(d.gross_revenue, 0), 4)   as actual_rtp_estimated,
        r.theoretical_rtp_known,
        r.theoretical_rtp_estimated,

        -- players
        d.active_players,
        d.new_players,
        d.returning_players,
        d.new_to_game_players,
        d.new_to_contest_players,

        -- engagement
        d.entries,
        d.purchases,
        round(d.entries / nullif(d.active_players, 0), 2)           as plays_per_player,
        round(d.gross_revenue / nullif(d.active_players, 0), 2)     as spend_per_player,
        round(d.gross_revenue / nullif(d.purchases, 0), 2)          as average_stake,

        -- retention (site level; null until the day has fully passed)
        case
            when dateadd(day, 1, d.activity_date_uk) < cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
            then round(d.retained_d1_players / nullif(d.new_to_contest_players, 0), 4)
        end                                                         as d1_retention,
        case
            when dateadd(day, 7, d.activity_date_uk) < cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
            then round(d.retained_d7_players / nullif(d.new_to_contest_players, 0), 4)
        end                                                         as d7_retention,
        round(d.new_players_with_second_play / nullif(d.new_players, 0), 4)
                                                                    as second_play_rate,
        round(d.repeat_purchase_players / nullif(d.active_players, 0), 4)
                                                                    as repeat_purchase_rate,

        -- wins
        d.wins,
        round(d.wins / nullif(d.entries, 0), 4)                     as win_rate,
        d.small_wins,
        round(d.small_wins / nullif(d.entries, 0), 4)               as small_win_rate,
        d.top_prize_hits,

        -- spend concentration
        d.median_spend_per_player,
        round(d.p90_spend_per_player, 2)                            as p90_spend_per_player,
        round(d.top_1pct_players_revenue / nullif(d.gross_revenue, 0), 4)
                                                                    as top_1pct_revenue_share,

        -- running totals
        sum(d.entries) over (
            partition by d.contest_id order by d.activity_date_uk
            rows between unbounded preceding and current row
        )                                                           as entries_to_date,
        sum(d.gross_revenue) over (
            partition by d.contest_id order by d.activity_date_uk
            rows between unbounded preceding and current row
        )                                                           as gross_revenue_to_date,
        sum(d.payout_estimated) over (
            partition by d.contest_id order by d.activity_date_uk
            rows between unbounded preceding and current row
        )                                                           as payout_estimated_to_date
    from daily as d
    inner join contests as c
        on d.contest_id = c.contest_id
    left join contest_rtp as r
        on d.contest_id = r.contest_id

)

select * from final
