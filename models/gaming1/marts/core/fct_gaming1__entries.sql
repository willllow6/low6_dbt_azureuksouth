with

entries as (

    select *
    from {{ ref('int_gaming1__entries_unioned') }}

)

select
    entry_id,
    user_id,
    contest_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    entered_at,
    cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date) as entry_date_uk,
    user_entry_number,
    user_platform_entry_number,
    entry_status,
    is_active,
    is_winner,
    prize_id,
    points,
    -- pickem
    tiebreaker_prediction,
    tiebreaker_outcome,
    -- squads
    final_rank,
    goal_count,
    shot_count,
    tackle_count,
    interception_count,
    locked_at,
    settled_at,
    updated_at
from entries
