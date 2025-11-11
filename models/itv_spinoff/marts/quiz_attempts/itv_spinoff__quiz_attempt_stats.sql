with

quiz_attempts as (

    select *
    from {{ ref('itv_spinoff__quiz_attempts') }}

),

quiz_attempt_stats as (

    select
        attempt_date,
        quiz_start_date,
        quiz_type,
        quiz_status,
        is_complete,
        count(*) as quiz_attempts,
        sum(case when is_complete then 1 else 0 end) as quiz_completions
    from quiz_attempts
    group by 1,2,3,4,5

)

select * from quiz_attempt_stats