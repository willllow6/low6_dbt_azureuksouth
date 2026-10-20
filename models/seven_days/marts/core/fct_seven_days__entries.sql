-- Table: 27.7M ticket rows flattened from session JSON; every downstream seven_days model and
-- the legacy mart read this, so the flatten/window/joins run once per build instead of per query.
{{ config(materialized='table') }}

with

entries as (

    select *
    from {{ ref('int_seven_days__sessions_flattened_to_entries') }}

),

games as (

    select *
    from {{ ref('stg_seven_days__games') }}

),

prizes as (

    select *
    from {{ ref('int_seven_days__prize_arrays_flattened_to_prizes') }}

),

-- The ticket carries the won prize's name/tier/odds but not its prize_id; match on those
-- within the instance. One prize per match key so the join can't fan out entries.
prize_keys as (

    select
        contest_id,
        prize_name,
        prize_tier,
        prize_odds,
        min(prize_id) as prize_id
    from prizes
    group by 1, 2, 3, 4

),

final as (

    select
        e.entry_id,
        e.session_id                                as purchase_id,
        e.user_id,
        e.contest_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.created_at                                as entered_at,
        cast(
            convert_timezone('UTC', '{{ var("local_timezone") }}', e.created_at) as date
        )                                           as entry_date_uk,
        e.user_entry_number,
        e.session_entry_number,
        e.is_played,
        e.prize_name is not null                    as is_winner,
        k.prize_id,
        e.prize_tier                                as won_prize_tier,
        e.prize_id                                  as won_prize_ticket_id,
        e.prize_name                                as won_prize_name,
        e.prize_type                                as won_prize_type,
        e.prize_amount                              as won_prize_amount,
        e.prize_odds                                as won_prize_odds,
        e.prize_odds_denominator                    as won_prize_odds_denominator,
        e.prize_probability                         as won_prize_probability,
        g.ticket_price                              as entry_fee,
        g.currency
    from entries as e
    left join games as g
        on e.contest_id = g.contest_id
    left join prize_keys as k
        on  e.contest_id = k.contest_id
        and trim(e.prize_name) = k.prize_name
        and e.prize_tier = k.prize_tier
        and e.prize_odds = k.prize_odds

)

select * from final
