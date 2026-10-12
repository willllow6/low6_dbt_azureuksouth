-- One row per game instance (contest × tenant): sales, entrants and the prize structure
-- (overall payout odds, tier-1 prizes, theoretical and realised RTP) for pricing analysis.
-- RTP is "known": it only counts prizes with a value (parsed from the name or the
-- seven_days_prize_values seed); unvalued_win_probability shows the gap. "_estimated" RTP
-- fills unvalued tiers from rpt_seven_days__contest_prize_tier_summary.

with

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prizes as (

    select *
    from {{ ref('dim_seven_days__prizes') }}

),

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

purchases as (

    select *
    from {{ ref('fct_seven_days__purchases') }}

),

prize_tiers as (

    select *
    from {{ ref('rpt_seven_days__contest_prize_tier_summary') }}

),

tier_estimates as (

    select
        contest_id,
        sum(expected_value_per_ticket)                      as expected_prize_value_per_ticket_estimated,
        sum(case when tier_value_basis != 'known' then expected_value_per_ticket end)
                                                            as estimated_tier_ev,
        count_if(tier_value_basis != 'known')               as estimated_tier_count,
        sum(value_paid_estimated)                           as prize_value_paid_estimated
    from prize_tiers
    group by 1

),

entry_metrics as (

    select
        contest_id,
        count(*)                                            as total_entries,
        count(distinct user_id)                             as unique_entrants,
        count(distinct case when user_entry_number = 1 then user_id end) as first_time_entrants,
        count_if(is_winner)                                 as paid_out_entries
    from entries
    group by 1

),

-- one row per player per instance, with site-level (tenant) context for each player
player_contest as (

    select
        e.contest_id,
        e.tenant_id,
        e.user_id,
        c.contest_name,
        min(e.entered_at)                                   as first_entered_at,
        sum(e.entry_fee)                                    as spend
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod
    group by 1, 2, 3, 4

),

player_ranked as (

    select
        *,
        row_number() over (
            partition by contest_id order by spend desc, user_id
        )                                                   as spend_rank,
        count(*) over (partition by contest_id)             as contest_players,
        sum(spend) over (partition by contest_id)           as contest_spend,
        sum(spend) over (
            partition by contest_id order by spend desc, user_id
            rows between unbounded preceding and current row
        )                                                   as cumulative_spend,
        contest_id = first_value(contest_id) over (
            partition by tenant_id, user_id, contest_name order by first_entered_at, contest_id
        )                                                   as is_new_to_game,
        contest_id = first_value(contest_id) over (
            partition by tenant_id, user_id order by first_entered_at, contest_id
        )                                                   as is_new_to_site,
        sum(spend) over (partition by tenant_id, user_id)   as site_lifetime_spend
    from player_contest

),

player_site_rank as (

    select
        *,
        percent_rank() over (
            partition by tenant_id order by site_lifetime_spend
        )                                                   as site_spend_percentile
    from (
        select distinct tenant_id, user_id, site_lifetime_spend
        from player_ranked
    )

),

spend_metrics as (

    select
        r.contest_id,
        count_if(r.is_new_to_game)                          as users_new_to_game,
        count_if(r.is_new_to_site)                          as users_new_to_site,
        round(avg(r.spend), 2)                              as avg_spend_per_player,
        median(r.spend)                                     as median_spend_per_player,
        round(percentile_cont(0.9) within group (order by r.spend), 2)
                                                            as p90_spend_per_player,
        round(percentile_cont(0.99) within group (order by r.spend), 2)
                                                            as p99_spend_per_player,
        max(r.spend)                                        as max_spend_per_player,
        count_if(r.spend_rank <= ceil(r.contest_players * 0.01)) as top_1pct_spenders,
        sum(case when r.spend_rank <= ceil(r.contest_players * 0.01) then r.spend end)
                                                            as top_1pct_spenders_revenue,
        count_if(r.spend_rank <= ceil(r.contest_players * 0.10)) as top_10pct_spenders,
        sum(case when r.spend_rank <= ceil(r.contest_players * 0.10) then r.spend end)
                                                            as top_10pct_spenders_revenue,
        count_if(r.cumulative_spend - r.spend < r.contest_spend * 0.5)
                                                            as players_for_half_of_revenue,
        count_if(r.spend >= {{ var('seven_days_big_spender_threshold') }})
                                                            as big_spenders,
        sum(case when r.spend >= {{ var('seven_days_big_spender_threshold') }} then r.spend end)
                                                            as big_spenders_revenue,
        count_if(r.spend >= {{ var('seven_days_whale_threshold') }})
                                                            as whales,
        sum(case when r.spend >= {{ var('seven_days_whale_threshold') }} then r.spend end)
                                                            as whales_revenue,
        count_if(s.site_spend_percentile >= 0.99)           as site_top_1pct_players,
        sum(case when s.site_spend_percentile >= 0.99 then r.spend end)
                                                            as site_top_1pct_players_revenue
    from player_ranked as r
    inner join player_site_rank as s
        on  r.tenant_id = s.tenant_id
        and r.user_id = s.user_id
    group by 1

),

wins_by_prize as (

    select
        contest_id,
        prize_id,
        count(*)                                            as times_won
    from entries
    where prize_id is not null
    group by 1, 2

),

prize_paid as (

    select
        w.contest_id,
        sum(w.times_won * p.prize_value)                    as prize_value_paid_known,
        sum(case when p.prize_value is null then w.times_won end) as unvalued_prizes_won
    from wins_by_prize as w
    inner join prizes as p
        on w.prize_id = p.prize_id
    group by 1

),

purchase_metrics as (

    select
        contest_id,
        count(*)                                            as purchases,
        sum(purchase_price)                                 as gross_revenue
    from purchases
    group by 1

),

prize_structure as (

    select
        contest_id,
        count(*)                                            as prize_count,
        count(distinct prize_tier)                          as prize_tier_count,
        sum(prize_probability)                              as win_probability,
        listagg(case when prize_tier = 1 then prize_name end, ' | ')
            within group (order by odds_denominator, prize_sort_order) as tier_1_prizes,
        sum(case when prize_tier = 1 then prize_probability end) as tier_1_win_probability,
        max(prize_value)                                    as top_prize_value,
        count(prize_value)                                  as valued_prize_count,
        count_if(prize_value is null)                       as unvalued_prize_count,
        coalesce(sum(case when prize_value is null then prize_probability end), 0)
                                                            as unvalued_win_probability,
        sum(expected_value_per_ticket)                      as expected_prize_value_per_ticket
    from prizes
    group by 1

),

final as (

    select
        -- standard columns
        c.contest_id,
        c.client_id,
        c.tenant_id,
        c.tenant_name,
        c.game_type,
        c.contest_name,
        c.contest_status,
        c.starts_at,
        c.ends_at,
        coalesce(e.total_entries, 0)                        as total_entries,
        coalesce(e.unique_entrants, 0)                      as unique_entrants,
        coalesce(e.first_time_entrants, 0)                  as first_time_entrants,
        coalesce(e.paid_out_entries, 0)                     as paid_out_entries,

        -- pricing and sales
        c.raffle_id,
        c.ticket_price,
        c.currency,
        c.starts_at                                         as on_sale_start_at,
        c.ends_at                                           as on_sale_end_at,
        datediff(day, c.starts_at, c.last_sale_at) + 1      as on_sale_days,
        coalesce(pm.purchases, 0)                           as purchases,
        coalesce(pm.gross_revenue, 0)                       as gross_revenue,

        -- prize structure
        ps.prize_count,
        ps.prize_tier_count,
        round(ps.win_probability, 6)                        as win_probability,
        '1 in ' || to_varchar(round(1 / nullif(ps.win_probability, 0), 2)) as payout_odds,
        ps.tier_1_prizes,
        ps.tier_1_win_probability,
        ps.top_prize_value,
        ps.valued_prize_count,
        ps.unvalued_prize_count,
        round(ps.unvalued_win_probability, 6)               as unvalued_win_probability,

        -- return to player (known values only)
        round(ps.expected_prize_value_per_ticket, 4)        as expected_prize_value_per_ticket,
        round(ps.expected_prize_value_per_ticket / nullif(c.ticket_price, 0), 4)
                                                            as theoretical_rtp_known,
        coalesce(pp.prize_value_paid_known, 0)              as prize_value_paid_known,
        coalesce(pp.unvalued_prizes_won, 0)                 as unvalued_prizes_won,
        round(coalesce(pp.prize_value_paid_known, 0) / nullif(pm.gross_revenue, 0), 4)
                                                            as realised_rtp_known,
        round(e.paid_out_entries / nullif(e.total_entries, 0), 4) as realised_win_rate,

        -- return to player (unvalued tiers estimated, see rpt_seven_days__contest_prize_tier_summary)
        coalesce(te.estimated_tier_count, 0)                as estimated_tier_count,
        round(te.expected_prize_value_per_ticket_estimated, 4)
                                                            as expected_prize_value_per_ticket_estimated,
        round(te.expected_prize_value_per_ticket_estimated / nullif(c.ticket_price, 0), 4)
                                                            as theoretical_rtp_estimated,
        round(coalesce(te.estimated_tier_ev, 0)
            / nullif(te.expected_prize_value_per_ticket_estimated, 0), 4)
                                                            as estimated_ev_share,
        coalesce(te.prize_value_paid_estimated, 0)          as prize_value_paid_estimated,
        round(coalesce(te.prize_value_paid_estimated, 0) / nullif(pm.gross_revenue, 0), 4)
                                                            as realised_rtp_estimated,

        -- player acquisition (each player counted once: in the instance of their first play)
        coalesce(sm.users_new_to_game, 0)                   as users_new_to_game,
        coalesce(sm.users_new_to_site, 0)                   as users_new_to_site,

        -- spend distribution (per-player spend over the instance's whole run)
        sm.avg_spend_per_player,
        sm.median_spend_per_player,
        sm.p90_spend_per_player,
        sm.p99_spend_per_player,
        sm.max_spend_per_player,
        coalesce(sm.top_1pct_spenders, 0)                   as top_1pct_spenders,
        coalesce(sm.top_1pct_spenders_revenue, 0)           as top_1pct_spenders_revenue,
        round(sm.top_1pct_spenders_revenue / nullif(pm.gross_revenue, 0), 4)
                                                            as top_1pct_revenue_share,
        coalesce(sm.top_10pct_spenders, 0)                  as top_10pct_spenders,
        coalesce(sm.top_10pct_spenders_revenue, 0)          as top_10pct_spenders_revenue,
        round(sm.top_10pct_spenders_revenue / nullif(pm.gross_revenue, 0), 4)
                                                            as top_10pct_revenue_share,
        coalesce(sm.players_for_half_of_revenue, 0)         as players_for_half_of_revenue,
        round(sm.players_for_half_of_revenue / nullif(e.unique_entrants, 0), 4)
                                                            as pct_players_for_half_of_revenue,

        -- big spenders (fixed thresholds: vars seven_days_big_spender_threshold / _whale_threshold)
        coalesce(sm.big_spenders, 0)                        as big_spenders,
        coalesce(sm.big_spenders_revenue, 0)                as big_spenders_revenue,
        round(coalesce(sm.big_spenders_revenue, 0) / nullif(pm.gross_revenue, 0), 4)
                                                            as big_spenders_revenue_share,
        coalesce(sm.whales, 0)                              as whales,
        coalesce(sm.whales_revenue, 0)                      as whales_revenue,
        round(coalesce(sm.whales_revenue, 0) / nullif(pm.gross_revenue, 0), 4)
                                                            as whales_revenue_share,

        -- the site's top 1% lifetime spenders (per tenant) playing this instance
        coalesce(sm.site_top_1pct_players, 0)               as site_top_1pct_players,
        coalesce(sm.site_top_1pct_players_revenue, 0)       as site_top_1pct_players_revenue,
        round(coalesce(sm.site_top_1pct_players_revenue, 0) / nullif(pm.gross_revenue, 0), 4)
                                                            as site_top_1pct_revenue_share
    from contests as c
    left join entry_metrics as e
        on c.contest_id = e.contest_id
    left join purchase_metrics as pm
        on c.contest_id = pm.contest_id
    left join prize_structure as ps
        on c.contest_id = ps.contest_id
    left join prize_paid as pp
        on c.contest_id = pp.contest_id
    left join tier_estimates as te
        on c.contest_id = te.contest_id
    left join spend_metrics as sm
        on c.contest_id = sm.contest_id

)

select * from final
