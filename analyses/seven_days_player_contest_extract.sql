-- One row per player per contest (game instance), for new-vs-returning and prize-impact analysis.
-- PLAYER_ID is a hash of tenant + user_id: 7 Days and UKCC have separate user_id sequences
-- (overlapping ids are different people) and no shared identifier, so players can't be
-- linked across tenants. "First ever" fields are therefore within the player's tenant.
-- Test instances (no ticket price) are excluded.
-- Run: dbt show --select seven_days_player_contest_extract --limit 100
-- or:  dbt compile --select seven_days_player_contest_extract (SQL in target/compiled/)

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

player_entries as (

    select
        sha2(e.tenant_id || ':' || e.user_id::varchar, 256)    as player_id,
        e.entry_id,
        e.purchase_id,
        e.contest_id,
        e.tenant_id,
        c.contest_name,
        e.entered_at,
        e.entry_fee,
        e.is_winner,
        p.prize_value                                           as prize_value_known,
        coalesce(p.prize_value, t.tier_avg_prize_value)         as prize_value_estimated
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

player_first_entry as (

    select
        player_id,
        entered_at                                              as player_first_entry_at,
        contest_id                                              as player_first_entry_contest_id,
        contest_name                                            as player_first_entry_game,
        tenant_id                                               as player_first_entry_tenant_id
    from player_entries
    qualify row_number() over (
        partition by player_id
        order by entered_at, entry_id
    ) = 1

),

player_contest as (

    select
        player_id,
        contest_id,
        count(*)                                                as entries,
        sum(entry_fee)                                          as spend,
        count(distinct purchase_id)                             as purchase_count,
        min(entered_at)                                         as first_entry_at,
        max(entered_at)                                         as last_entry_at,
        count_if(is_winner)                                     as prizes_won,
        sum(prize_value_known)                                  as prize_value_won_known,
        sum(prize_value_estimated)                              as prize_value_won_estimated
    from player_entries
    group by 1, 2

),

final as (

    select
        pc.player_id,
        pc.contest_id,
        pc.entries,
        pc.spend,
        f.player_first_entry_at,
        f.player_first_entry_contest_id,
        f.player_first_entry_game,
        f.player_first_entry_tenant_id,
        pc.first_entry_at,
        pc.last_entry_at,
        pc.purchase_count,
        pc.prizes_won,
        coalesce(pc.prize_value_won_known, 0)                   as prize_value_won_known,
        coalesce(pc.prize_value_won_estimated, 0)               as prize_value_won_estimated
    from player_contest as pc
    inner join player_first_entry as f
        on pc.player_id = f.player_id

)

select * from final
