with

entries as (
  
    select * from {{ ref('itv_spinoff__quiz_attempts') }}

),

user_entry_weeks as (

    select
        user_id as user_id,
        date_trunc('week', attempt_date) as entry_week
    from entries
    group by 1,2
    
),


ranked_user_entry_weeks as (

    select
        *,
        row_number() over (partition by user_id order by entry_week) as user_entry_week_number
    from user_entry_weeks
    
),


first_user_entry_weeks as (

    select
        *
    from ranked_user_entry_weeks
    where user_entry_week_number = 1
    
),


add_first_user_entry_weeks as (

    select
        a.*,
        b.entry_week as first_entry_week
    from ranked_user_entry_weeks as a
        left join first_user_entry_weeks as b
            on a.user_id = b.user_id
    
),

entry_week_active_users as (

    select
        first_entry_week,
        entry_week,
        datediff('week',first_entry_week,entry_week) as weeks_from_first_entry,
        count(user_id) as active_users
    from add_first_user_entry_weeks
    group by 1,2

),

first_week_active_users as (

    select
        first_entry_week,
        count(user_id) as active_users
    from add_first_user_entry_weeks
    where entry_week = first_entry_week
    group by first_entry_week
    
),

add_first_entry_week_active_users as (

    select
        a.first_entry_week,
        a.entry_week,
        a.weeks_from_first_entry,
        b.active_users as first_entry_week_active_users,
        a.active_users
    from entry_week_active_users as a
        left join first_week_active_users as b
            on a.first_entry_week = b.first_entry_week
            
)

select * from add_first_entry_week_active_users
