with

date_generator as (

    select dateadd(day, seq4(), '2025-11-18'::date) as date_day
    from table(generator(rowcount => 1000))  -- pick a safe upper bound
    -- WHERE date_day < CURRENT_DATE

),

dates as (

    select
        date_day,
        datediff('week',date_day,current_date()) as weeks_ago,
        datediff('month',date_day,current_date()) as months_ago
    from date_generator

),

users as (

    select *
    from {{ ref('itv_spinoff__users') }}

),

attempts as (

    select *
    from {{ ref('itv_spinoff__quiz_attempts') }}

),

referrals as (

    select *
    from {{ ref('itv_spinoff__referrals') }}

),

daily_users as (

    select
        user_created_date,
        count(*) as signups,
        sum(case when has_verified_email then 1 else 0 end) as registrations,
        sum(case when is_sky_vegas_customer then 1 else 0 end) as sky_vegas_customer_confirmations
    from users
    group by 1

),

daily_attempts as (

    select
        attempt_date,
        count(*) as quiz_attempts,
        sum(case when is_complete then 1 else 0 end) as quiz_completions,
        sum(case when user_attempt_number = 1 then 1 else 0 end) as first_quiz_attempts
    from attempts
    group by 1

),

daily_referrals as (

    select
        referral_date,
        count(*) as referrals
    from referrals
    group by 1

),

user_active_days as (

    select 
        user_id,
        attempt_date as date_day,
        True as is_active
    from attempts
    group by 1,2

),

user_first_active_day as (

    select
        user_id,
        min(date_day) as first_active_day
    from user_active_days
    group by 1

),

--Join all days after first active date to each user

spined as (

    select
        user_first_active_day.user_id,
        dates.date_day,
        dates.weeks_ago,
        dates.months_ago
    from user_first_active_day
    left join dates
        on dates.date_day >= user_first_active_day.first_active_day

),

--Join all users with days after first active date to all of the active days and create boolean fields for active or not over different periods

filled as (

    select
        spined.date_day,
        spined.user_id,
        --Join boolean field from active days to day and flag the non matches as false
        coalesce(ad.is_active, false) as is_active_today,

        --These window functions start with current row and go back stated number and give a true/false for active on any day in window by user
        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between 1 preceding and 1 preceding
        ) as is_active_yesterday,

        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between 7 preceding and 2 preceding
        ) as is_active_2_to_7_days_ago,

        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between 30 preceding and 8 preceding
        ) as is_active_8_to_30_days_ago,

        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between unbounded preceding and 31 preceding
        ) as is_active_31_plus_days_ago,

        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between 6 preceding and current row
        ) as is_active_l7_days,

        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between 29 preceding and current row
        ) as is_active_l30_days,
  
        max(is_active_today) over (
            partition by spined.user_id
            order by spined.date_day
            rows between 89 preceding and current row
        ) as is_active_l90_days,
  
        --These window functions use the xxx_ago fields to flag users active in calendar week/month/year assigning a true/false for active in the same number of xxx_ago as date_day
        max(is_active_today) over (
          partition by spined.user_id, spined.weeks_ago
          order by  spined.date_day
          rows between unbounded preceding and current row
      ) as is_active_this_week,

        max(is_active_today) over (
          partition by spined.user_id, spined.months_ago
          order by  spined.date_day
          rows between unbounded preceding and current row
      ) as is_active_this_month
  
    from spined
    left join user_active_days as ad
        on spined.date_day = ad.date_day
        and spined.user_id = ad.user_id
  
),

active_users as (

    select
        date_day,
        sum(is_active_yesterday::integer) as played_yesterday,
        sum(is_active_2_to_7_days_ago::integer) as played_2_to_7_days_ago,
        sum(is_active_8_to_30_days_ago::integer) as played_8_to_30_days_ago,
        sum(is_active_31_plus_days_ago::integer) as played_31_plus_days_ago,
        sum(is_active_today::integer) as daily_active_users,
        sum(is_active_l7_days::integer) as weekly_active_users,
        sum(is_active_l30_days::integer) as monthly_active_users,
        sum(is_active_this_week::integer) as this_week_active_users,
        sum(is_active_this_month::integer) as this_month_active_users
    from filled
    group by 1
    order by 1

),

joined as (

    select
        dates.date_day,
        coalesce(daily_users.signups,0) as signups,
        coalesce(daily_users.registrations,0) as registrations,
        coalesce(daily_users.sky_vegas_customer_confirmations,0) as sky_vegas_customer_confirmations,
        coalesce(daily_attempts.quiz_attempts,0) as quiz_attempts,
        coalesce(daily_attempts.quiz_completions,0) as quiz_completions,
        coalesce(daily_attempts.first_quiz_attempts,0) as first_quiz_attempts,
        coalesce(active_users.played_yesterday,0) as played_yesterday,
        coalesce(active_users.played_2_to_7_days_ago,0) as played_2_to_7_days_ago,
        coalesce(active_users.played_8_to_30_days_ago,0) as played_8_to_30_days_ago,
        coalesce(active_users.played_31_plus_days_ago,0) as played_31_plus_days_ago,
        coalesce(active_users.daily_active_users,0) as daily_active_users,
        coalesce(active_users.weekly_active_users,0) as weekly_active_users,
        coalesce(active_users.monthly_active_users,0) as monthly_active_users,
        coalesce(active_users.this_week_active_users,0) as this_week_active_users,
        coalesce(active_users.this_month_active_users,0) as this_month_active_users,
        coalesce(daily_referrals.referrals,0) as referrals
    from dates
    left join daily_users 
        on dates.date_day = daily_users.user_created_date
    left join daily_attempts
        on dates.date_day = daily_attempts.attempt_date
    left join active_users
        on dates.date_day = active_users.date_day
    left join daily_referrals 
        on dates.date_day = daily_referrals.referral_date

)

select * from joined