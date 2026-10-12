-- One row per player per UK day per game per ticket price band, for low-to-high price migration analysis.
-- USER_ID is a hash of tenant + user_id: user_id is consistent across games and price points within
-- a site, but 7 Days and UKCC have separate sequences (1,307 ids exist on both and are different
-- people). The hash is stable across all rows, so it can be counted and joined.
-- History is complete: the source starts at the first sale on 2025-10-13.
-- TICKET_PRICE_BAND: the source has no tier, and a game often sells several prices at once, so
-- High = ticket price >= £1.00. Change high_band_threshold to re-band.
-- NEW_TO_LOW6 / NEW_TO_GAME: the row holds the player's first-ever entry in the tenant / in that
-- game. No registration date exists in the source (no users table).
-- GAME: Coin Drop Football is reported as Coin Drop.
-- Test instances (no ticket price) are excluded.
-- Run: dbt compile --select seven_days_player_price_band_daily_extract (SQL in target/compiled/)

{% set high_band_threshold = 1.00 %}

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

player_entries as (

    select
        sha2(e.tenant_id || ':' || e.user_id::varchar, 256)    as user_id,
        e.entry_id,
        e.tenant_name                                           as tenant,
        case
            when c.contest_name = 'Coin Drop Football' then 'Coin Drop'
            else c.contest_name
        end                                                     as game,
        case
            when c.ticket_price >= {{ high_band_threshold }} then 'High'
            else 'Low'
        end                                                     as ticket_price_band,
        e.entry_date_uk                                         as entry_date,
        e.entered_at,
        e.entry_fee
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod

),

flagged as (

    select
        *,
        row_number() over (
            partition by user_id
            order by entered_at, entry_id
        ) = 1                                                   as is_first_entry_low6,
        row_number() over (
            partition by user_id, game
            order by entered_at, entry_id
        ) = 1                                                   as is_first_entry_game
    from player_entries

),

final as (

    select
        user_id,
        tenant,
        game,
        ticket_price_band,
        entry_date                                              as date,
        count(*)                                                as purchases,
        sum(entry_fee)                                          as revenue,
        boolor_agg(is_first_entry_low6)                         as new_to_low6,
        boolor_agg(is_first_entry_game)                         as new_to_game
    from flagged
    group by 1, 2, 3, 4, 5

)

select * from final
order by user_id, date, game, ticket_price_band
