with

users as (

    select *
    from {{ ref('itv_spinoff__users') }}

),

user_stats as (

    select
        user_created_date,
        favourite_itv_show,
        age_band,
        generation,
        has_verified_email,
        has_consented_marketing,
        email_verification_date,
        count(*) as signups,
        sum(case when has_verified_email then 1 else 0 end) as registrations,
        sum(case when has_completed_profile then 1 else 0 end) as profile_completions,
        sum(case when has_consented_marketing then 1 else 0 end) as marketing_consents,
        sum(case when quiz_attempts > 0 then 1 else 0 end) as quiz_attempts,
        sum(case when quiz_completions > 0 then 1 else 0 end) as players,
        sum(case when league_memberships > 0 then 1 else 0 end) as league_joiners,
        sum(case when achievements > 0 then 1 else 0 end) as achievement_earners,
        sum(case when referrals > 0 then 1 else 0 end) as referrers,
        sum(case when quiz_completions > 1 then 1 else 0 end) as returning_players,
        sum(case when is_deleted then 1 else 0 end) as account_deletions
    from users
    group by 1,2,3,4,5,6,7

)

select * from user_stats