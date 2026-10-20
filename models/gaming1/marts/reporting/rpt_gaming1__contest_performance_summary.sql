-- One row per contest (contest × tenant), both games. paid_out_entries = entries with a prize_id
-- (squads only for now; pickem payouts aren't in the source).
with

contests as (

    select *
    from {{ ref('dim_gaming1__contests') }}

),

entries as (

    select *
    from {{ ref('fct_gaming1__entries') }}

),

entry_metrics as (

    select
        contest_id,
        count(*)                                                    as total_entries,
        count(distinct user_id)                                     as unique_entrants,
        count(distinct case when user_entry_number = 1 then user_id end) as first_time_entrants,
        count(distinct case when user_platform_entry_number = 1 then user_id end) as first_time_platform_entrants,
        count_if(prize_id is not null)                              as paid_out_entries
    from entries
    group by 1

)

select
    c.contest_id,
    c.client_id,
    c.tenant_id,
    c.tenant_name,
    c.game_type,
    c.contest_name,
    c.contest_status,
    c.starts_at,
    c.ends_at,
    coalesce(e.total_entries, 0)        as total_entries,
    coalesce(e.unique_entrants, 0)      as unique_entrants,
    coalesce(e.first_time_entrants, 0)  as first_time_entrants,
    coalesce(e.paid_out_entries, 0)     as paid_out_entries,
    -- extension: first entry in any gaming1 game (first_time_entrants is first in this game_type)
    coalesce(e.first_time_platform_entrants, 0) as first_time_platform_entrants
from contests as c
left join entry_metrics as e
    on c.contest_id = e.contest_id
