with

contests as (

    select *
    from {{ ref('int_gaming1__contests_unioned') }}

)

select
    contest_id,
    contest_name,
    contest_status,
    is_active,
    starts_at,
    ends_at,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    opens_at,
    cast(convert_timezone('UTC', '{{ var("local_timezone") }}', starts_at) as date) as start_date_uk,
    -- pickem
    is_scored,
    prize_text,
    sport,
    -- squads
    competition_id,
    competition_name,
    round_sequence,
    contest_days,
    reveal_count,
    cards_per_reveal,
    min_gpg,
    max_gpg,
    goal_points,
    shot_points,
    tackle_points,
    interception_points,
    match_window_ends_at,
    created_at,
    updated_at
from contests
