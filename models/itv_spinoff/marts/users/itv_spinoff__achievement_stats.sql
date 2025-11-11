with

achievements as (

    select *
    from {{ ref('itv_spinoff__achievements') }}

),

achievement_stats as (

    select
        achievement_name,
        achievement_description,
        achievement_category_name,
        achievement_date,
        count(*) as users
    from achievements
    group by 1,2,3,4

)

select * from achievement_stats