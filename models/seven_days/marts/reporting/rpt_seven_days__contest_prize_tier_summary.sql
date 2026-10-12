-- One row per game instance per prize tier: tier odds, average prize value (known or
-- estimated), expected value per ticket, RTP contribution and expected vs actual wins.
-- Prizes in a tier share the same odds, so tier_win_probability × tier_avg_prize_value is the
-- tier's EV. Tiers with no valued prize are estimated from the nearest valued tiers:
-- sqrt(tier-above min × tier-below max), or the tier-below max for top tiers.

with

prizes as (

    select *
    from {{ ref('dim_seven_days__prizes') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

tier_stats as (

    select
        contest_id,
        prize_tier,
        count(*)                                            as prize_count,
        count_if(odds_denominator = 2147483647)             as unwinnable_prize_count,
        count(case when odds_denominator < 2147483647 then prize_value end)
                                                            as valued_prize_count,
        count_if(odds_denominator < 2147483647)             as winnable_prize_count,
        listagg(prize_name, ' | ')
            within group (order by prize_sort_order)        as prize_names,
        coalesce(sum(case when odds_denominator < 2147483647 then prize_probability end), 0)
                                                            as tier_win_probability,
        sum(case when odds_denominator < 2147483647 then expected_value_per_ticket end)
                                                            as known_ev_per_ticket,
        avg(case when odds_denominator < 2147483647 then prize_value end)
                                                            as known_avg_prize_value,
        min(case when odds_denominator < 2147483647 then prize_value end)
                                                            as known_min_prize_value,
        max(case when odds_denominator < 2147483647 then prize_value end)
                                                            as known_max_prize_value
    from prizes
    group by 1, 2

),

tier_bounds as (

    select
        *,
        lag(known_min_prize_value) ignore nulls over (
            partition by contest_id order by prize_tier
        )                                                   as above_min,
        lead(known_max_prize_value) ignore nulls over (
            partition by contest_id order by prize_tier
        )                                                   as below_max
    from tier_stats

),

tier_values as (

    select
        *,
        coalesce(known_avg_prize_value, sqrt(above_min * below_max), below_max)
                                                            as tier_avg_prize_value,
        case
            when winnable_prize_count = 0                               then null
            when valued_prize_count = winnable_prize_count              then 'known'
            when valued_prize_count > 0                                 then 'partly_known'
            when above_min is not null and below_max is not null        then 'interpolated'
            when below_max is not null                                  then 'floor_from_tier_below'
        end                                                 as tier_value_basis
    from tier_bounds

),

contest_entries as (

    select
        contest_id,
        count(*)                                            as contest_entries
    from entries
    group by 1

),

tier_wins as (

    select
        e.contest_id,
        e.won_prize_tier                                    as prize_tier,
        count(*)                                            as times_won,
        sum(p.prize_value)                                  as known_value_paid
    from entries as e
    left join prizes as p
        on e.prize_id = p.prize_id
    where e.is_winner
    group by 1, 2

),

final as (

    select
        t.contest_id,
        c.client_id,
        c.tenant_id,
        c.tenant_name,
        c.game_type,
        c.contest_name,
        c.contest_status,
        c.ticket_price,
        c.currency,
        t.prize_tier,
        t.prize_count,
        t.valued_prize_count,
        t.unwinnable_prize_count,
        t.prize_names,
        t.tier_win_probability,
        '1 in ' || to_varchar(round(1 / nullif(t.tier_win_probability, 0)))
                                                            as tier_odds,
        t.known_avg_prize_value,
        t.below_max                                         as estimate_floor,
        t.above_min                                         as estimate_ceiling,
        t.tier_avg_prize_value,
        t.tier_value_basis,
        t.tier_win_probability * t.tier_avg_prize_value     as expected_value_per_ticket,
        t.tier_win_probability * t.tier_avg_prize_value
            / nullif(c.ticket_price, 0)                     as rtp_contribution,
        t.known_ev_per_ticket,
        t.known_ev_per_ticket / nullif(c.ticket_price, 0)   as known_rtp_contribution,
        coalesce(ce.contest_entries, 0)                     as contest_entries,
        coalesce(ce.contest_entries, 0) * t.tier_win_probability
                                                            as expected_wins,
        coalesce(w.times_won, 0)                            as times_won,
        coalesce(w.known_value_paid, 0)                     as known_value_paid,
        coalesce(w.times_won, 0) * t.tier_avg_prize_value   as value_paid_estimated
    from tier_values as t
    inner join contests as c
        on t.contest_id = c.contest_id
    left join contest_entries as ce
        on t.contest_id = ce.contest_id
    left join tier_wins as w
        on  t.contest_id = w.contest_id
        and t.prize_tier = w.prize_tier

)

select * from final
