with

quiz_attempts as (

    select *
    from {{ ref('stg_itv_spinoff__quiz_attempts') }}

),

quizes as (

    select *
    from {{ ref('stg_itv_spinoff__quizes') }}

),

users as (

    select *
    from {{ ref('itv_spinoff__users') }}

),

joined as (

    select
        quiz_attempts.quiz_id,
        quiz_attempts.user_id,

        users.username,

        quizes.quiz_start_date,
        quizes.quiz_type,
        quizes.quiz_status,

        quiz_attempts.multiplier,
        quiz_attempts.score,
        quiz_attempts.base_score,
        quiz_attempts.fast_bonus,
        quiz_attempts.streak_bonus,
        quiz_attempts.end_of_quiz_bonus,
        quiz_attempts.total_points,
        quiz_attempts.is_complete,
        quiz_attempts.attempt_date,
        quiz_attempts.attempted_at


    from quiz_attempts
    left join quizes
        on quiz_attempts.quiz_id = quizes.quiz_id
    left join users
        on quiz_attempts.user_id = users.user_id

)

select * from joined