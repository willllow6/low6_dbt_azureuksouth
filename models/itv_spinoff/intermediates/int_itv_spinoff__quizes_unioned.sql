with

daily_quizes as (

    select *
    from {{ ref('stg_itv_spinoff__quizes') }}

),


live_quizes as (

    select *
    from {{ ref('stg_itv_spinoff__live_quizes') }}

),

unioned as (

    select
        quiz_id,
        series,
        batch,
        0 as version,
        quiz_type,
        quiz_status,
        quiz_start_date,
        quiz_starts_at
    from daily_quizes

    union all

    select
        live_quiz_id as quiz_id,
        series,
        batch,
        version,
        'live' as quiz_type,
        'PUBLISHED' as quiz_status,
        quiz_start_date,
        quiz_starts_at
    from live_quizes


)

select * from unioned