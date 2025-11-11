with

active_streaks as (

    select *
    from {{ ref('stg_itv_spinoff__daily_streaks') }}

),

users as (

    select *
    from {{ ref('itv_spinoff__users') }}

),

joined as (

    select
         active_streaks.user_id,

         users.username,

         active_streaks.streak_length_days,
         active_streaks.multiplier,
         active_streaks.last_played_at
    
    from active_streaks
    left join users 
        on active_streaks.user_id = users.user_id

)

select * from joined