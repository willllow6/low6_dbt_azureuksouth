-- One row per prize per game instance: odds, value, contribution to RTP, and how often it
-- has actually been won vs the expected number of wins. prize_tier is carried for tier roll-ups.

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

contest_entries as (

    select
        contest_id,
        count(*)            as contest_entries
    from entries
    group by 1

),

wins_by_prize as (

    select
        prize_id,
        count(*)            as times_won
    from entries
    where prize_id is not null
    group by 1

),

final as (

    select
        p.prize_id,
        p.contest_id,
        p.raffle_id,
        p.client_id,
        p.tenant_id,
        p.tenant_name,
        p.game_type,
        c.contest_name,
        c.contest_status,
        c.starts_at,
        c.ends_at,
        c.ticket_price,
        p.prize_tier,
        p.prize_sort_order,
        p.prize_name,
        p.prize_category,
        p.source_prize_type,
        p.prize_odds,
        p.odds_denominator,
        p.prize_probability,
        sum(p.prize_probability) over (partition by p.contest_id, p.prize_tier)
                                                        as tier_win_probability,
        p.prize_value,
        p.prize_value_source,
        p.currency,
        p.expected_value_per_ticket,
        round(p.expected_value_per_ticket / nullif(c.ticket_price, 0), 6)
                                                        as rtp_contribution,
        coalesce(ce.contest_entries, 0)                 as contest_entries,
        round(coalesce(ce.contest_entries, 0) * p.prize_probability, 2)
                                                        as expected_wins,
        coalesce(w.times_won, 0)                        as times_won,
        coalesce(w.times_won, 0) / nullif(ce.contest_entries, 0)
                                                        as realised_win_rate,
        coalesce(w.times_won, 0) * p.prize_value        as value_paid
    from prizes as p
    left join contests as c
        on p.contest_id = c.contest_id
    left join contest_entries as ce
        on p.contest_id = ce.contest_id
    left join wins_by_prize as w
        on p.prize_id = w.prize_id

)

select * from final
