-- Union of pickem contests (pickems) and squads contests (rounds), with each contest's tenant
-- resolved. The single place a contest's tenant is resolved for every gaming1 core model.
-- Game-specific columns are null for the other game.
with

pickem_contests as (

    select *
    from {{ ref('stg_gaming1__contests') }}

),

squads_contests as (

    select *
    from {{ ref('stg_gaming1__squads_contests') }}

),

squads_competitions as (

    select *
    from {{ ref('stg_gaming1__squads_competitions') }}

),

squads_contest_days as (

    select *
    from {{ ref('stg_gaming1__squads_contest_days') }}

),

tenants as (

    select *
    from {{ ref('stg_gaming1__tenants') }}

),

squads_day_stats as (

    select
        contest_id,
        count(*)                    as contest_days,
        min(reveal_starts_at)       as first_reveal_starts_at,
        max(reveal_ends_at)         as last_reveal_ends_at
    from squads_contest_days
    group by 1

),

pickem as (

    select
        c.contest_id,
        c.client_id,
        c.tenant_id,
        c.game_type,
        c.contest_name,
        c.contest_status,
        c.is_active,
        c.opens_at,
        c.starts_at,
        null::timestamp_ntz         as ends_at,
        -- pickem
        c.is_scored,
        c.prize_text,
        c.sport,
        -- squads
        null::varchar               as competition_id,
        null::varchar               as competition_name,
        null::number                as round_sequence,
        null::number                as contest_days,
        null::number                as reveal_count,
        null::number                as cards_per_reveal,
        null::number                as min_gpg,
        null::number                as max_gpg,
        null::number                as goal_points,
        null::number                as shot_points,
        null::number                as tackle_points,
        null::number                as interception_points,
        null::timestamp_ntz         as match_window_ends_at,
        c.created_at,
        c.updated_at
    from pickem_contests as c

),

squads as (

    select
        c.contest_id,
        c.client_id,
        comp.tenant_id,
        c.game_type,
        c.contest_name,
        c.contest_status,
        -- statuses seen so far: upcoming, revealing. Extend if new in-play statuses appear.
        c.contest_status in ('upcoming', 'revealing')               as is_active,
        d.first_reveal_starts_at                                    as opens_at,
        d.first_reveal_starts_at                                    as starts_at,
        coalesce(c.match_window_ends_at, d.last_reveal_ends_at)     as ends_at,
        -- pickem
        null::boolean               as is_scored,
        null::varchar               as prize_text,
        null::varchar               as sport,
        -- squads
        c.competition_id,
        comp.competition_name,
        c.round_sequence,
        coalesce(d.contest_days, 0) as contest_days,
        c.reveal_count,
        comp.cards_per_reveal,
        c.min_gpg,
        c.max_gpg,
        comp.goal_points,
        comp.shot_points,
        comp.tackle_points,
        comp.interception_points,
        c.match_window_ends_at,
        c.created_at,
        greatest(c.updated_at, coalesce(comp.updated_at, c.updated_at)) as updated_at
    from squads_contests as c
    left join squads_competitions as comp
        on c.competition_id = comp.competition_id
    left join squads_day_stats as d
        on c.contest_id = d.contest_id

),

unioned as (

    select * from pickem
    union all
    select * from squads

)

select
    u.contest_id,
    u.client_id,
    u.tenant_id,
    t.tenant_name,
    u.game_type,
    u.contest_name,
    u.contest_status,
    u.is_active,
    u.opens_at,
    u.starts_at,
    u.ends_at,
    u.is_scored,
    u.prize_text,
    u.sport,
    u.competition_id,
    u.competition_name,
    u.round_sequence,
    u.contest_days,
    u.reveal_count,
    u.cards_per_reveal,
    u.min_gpg,
    u.max_gpg,
    u.goal_points,
    u.shot_points,
    u.tackle_points,
    u.interception_points,
    u.match_window_ends_at,
    u.created_at,
    u.updated_at
from unioned as u
left join tenants as t
    on u.tenant_id = t.tenant_id
