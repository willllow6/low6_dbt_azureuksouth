with

active_streaks as (

    select *
    from {{ ref('itv_spinoff__active_streaks') }}

),

active_streak_stats as (

    select
        streak_length_days,
        count(*) as users
    from active_streaks
    group by 1

)

select * from active_streak_stats