with

user_achievements as (

    select *
    from {{ ref('stg_itv_spinoff__user_achievements') }}

),

achievements as (

    select *
    from {{ ref('stg_itv_spinoff__achievements') }}

),

achievement_categories as (

    select *
    from {{ ref('stg_itv_spinoff__achievement_categories') }}

),

users as (

    select *
    from {{ ref('itv_spinoff__users') }}

),

joined as (

    select
        user_achievements.user_id,
        user_achievements.achievement_id,
        achievements.achievement_category_id,

        users.username,

        achievements.achievement_name,
        achievements.achievement_description,
        achievement_categories.achievement_category_name,

        user_achievements.achievement_date,
        user_achievements.achieved_at

    from user_achievements
    left join achievements 
        on user_achievements.achievement_id = achievements.achievement_id
    left join achievement_categories
        on achievements.achievement_category_id = achievement_categories.achievement_category_id
    left join users 
        on user_achievements.user_id = users.user_id

)

select * from joined