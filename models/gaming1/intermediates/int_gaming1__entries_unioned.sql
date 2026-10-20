-- Union of pickem entries (aggregated from selections in int_gaming1__selection_entries) and squads
-- entries (native in squads_user_rounds). Tenant comes from the contest. user_entry_number is
-- scoped per game_type (pickem numbering is unaffected by squads); user_platform_entry_number
-- counts the user's entries across every gaming1 game. Game-specific columns are null for the
-- other game.
with

pickem_entries as (

    select *
    from {{ ref('int_gaming1__selection_entries') }}

),

squads_entries as (

    select *
    from {{ ref('stg_gaming1__squads_entries') }}

),

contests as (

    select *
    from {{ ref('int_gaming1__contests_unioned') }}

),

pickem as (

    select
        e.entry_id,
        e.user_id,
        e.contest_id,
        e.client_id,
        e.game_type,
        e.entered_at,
        null::varchar                                       as entry_status,
        not coalesce(c.is_scored, false)                    as is_active,
        e.is_winner,
        null::varchar                                       as prize_id,
        e.total_points                                      as points,
        -- pickem
        e.tiebreaker_prediction,
        e.tiebreaker_outcome,
        -- squads
        null::number                                        as final_rank,
        null::number                                        as goal_count,
        null::number                                        as shot_count,
        null::number                                        as tackle_count,
        null::number                                        as interception_count,
        null::timestamp_ntz                                 as locked_at,
        case when c.is_scored then c.updated_at end         as settled_at,
        greatest(e.updated_at, coalesce(c.updated_at, e.updated_at)) as updated_at
    from pickem_entries as e
    left join contests as c
        on e.contest_id = c.contest_id

),

squads as (

    select
        e.entry_id,
        e.user_id,
        e.contest_id,
        e.client_id,
        e.game_type,
        e.entered_at,
        e.entry_status,
        e.settled_at is null                                as is_active,
        -- null until scored; no prizes table yet, so a winner is any entry with a prize_id
        case when e.settled_at is not null then e.prize_id is not null end as is_winner,
        e.prize_id,
        e.score                                             as points,
        -- pickem
        null::number                                        as tiebreaker_prediction,
        null::number                                        as tiebreaker_outcome,
        -- squads
        e.final_rank,
        e.goal_count,
        e.shot_count,
        e.tackle_count,
        e.interception_count,
        e.locked_at,
        e.settled_at,
        e.updated_at
    from squads_entries as e

),

unioned as (

    select * from pickem
    union all
    select * from squads

)

select
    u.entry_id,
    u.user_id,
    u.contest_id,
    u.client_id,
    c.tenant_id,
    c.tenant_name,
    u.game_type,
    u.entered_at,
    row_number() over (
        partition by u.user_id, u.game_type
        order by u.entered_at, u.entry_id
    )                                                       as user_entry_number,
    row_number() over (
        partition by u.user_id
        order by u.entered_at, u.entry_id
    )                                                       as user_platform_entry_number,
    u.entry_status,
    u.is_active,
    u.is_winner,
    u.prize_id,
    u.points,
    u.tiebreaker_prediction,
    u.tiebreaker_outcome,
    u.final_rank,
    u.goal_count,
    u.shot_count,
    u.tackle_count,
    u.interception_count,
    u.locked_at,
    u.settled_at,
    u.updated_at
from unioned as u
left join contests as c
    on u.contest_id = c.contest_id
