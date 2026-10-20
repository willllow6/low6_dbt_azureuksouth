with

selections as (

    select *
    from {{ ref('int_gaming1__selections_unioned') }}

)

select
    selection_id,
    entry_id,
    user_id,
    contest_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    selected_at,
    cast(convert_timezone('UTC', '{{ var("local_timezone") }}', selected_at) as date) as selected_date_uk,
    -- pickem
    question_id,
    option_id,
    selection_value,
    is_correct,
    points,
    tiebreaker_prediction,
    -- squads
    contest_day_id,
    day_index,
    player_id,
    revealed_rarity,
    goal_count,
    shot_count,
    tackle_count,
    interception_count,
    revealed_at,
    updated_at
from selections
