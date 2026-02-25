with

daily_attempts as (

    select *
    from {{ ref('stg_itv_spinoff__quiz_attempts') }}

),

live_attempts as (

    select *
    from {{ ref('int_itv_spinoff__live_quiz_attempts') }}

),

unioned as (

    select
        user_id,
        quiz_id,
        multiplier,
        base_score,
        score,
        fast_bonus,
        streak_bonus,
        end_of_quiz_bonus,
        total_points,
        is_complete,
        attempt_date,
        attempt_hour,
        attempted_at
    from daily_attempts

    union all

    select
        user_id,
        quiz_id,
        null as multiplier,
        null as base_score,
        null as score,
        null as fast_bonus,
        null as streak_bonus,
        null as end_of_quiz_bonus,
        total_points,
        true as is_complete,
        attempt_date,
        attempt_hour,
        attempted_at
    from live_attempts

)

select * from unioned



