with

core_user_service as (

    select *
    from {{ ref('stg_core_user_service__users') }}
    where app_id = 'spin_off'
    and user_created_date > '2025-11-17'

),

quiz_attempts as (

    select *
    from {{ ref('stg_itv_spinoff__quiz_attempts') }}

),

referrals as (

    select *
    from {{ ref('stg_core_user_service__referrals') }}
    where app_id = 'spin_off'

),

league_memberships as (

    select *
    from {{ ref('stg_itv_spinoff__friends_league_memberships') }}

),

achievements as (

    select *
    from {{ ref('stg_itv_spinoff__user_achievements') }}

),

user_attempts as (

    select
        user_id,
        count(*) as quiz_attempts,
        sum(case when is_complete then 1 else 0 end) as quiz_completions,
    from quiz_attempts
    group by 1

),

user_referrals as (

    select
        referrer_user_id,
        count(*) as referrals
    from referrals
    group by 1

),

user_memberships as (

    select
        user_id,
        count(*) as league_memberships 
    from league_memberships
    group by 1

),

user_achievements as (

    select
        user_id,
        count(*) as achievements
    from achievements
    group by 1

),

joined as (

    select
        core_user_service.user_id,
        core_user_service.status as user_service_status,
        core_user_service.email,
        core_user_service.username,
        core_user_service.favourite_itv_show,
        core_user_service.age_band,
        core_user_service.generation,
        core_user_service.age,
        coalesce(user_attempts.quiz_attempts,0) as quiz_attempts,
        coalesce(user_attempts.quiz_completions,0) as quiz_completions,
        coalesce(user_referrals.referrals,0) as referrals,
        coalesce(user_memberships.league_memberships,0) as league_memberships,
        coalesce(user_achievements.achievements,0) as achievements,
        core_user_service.has_verified_email,
        core_user_service.has_consented_marketing,
        core_user_service.has_completed_profile,
        core_user_service.is_deleted,
        core_user_service.date_of_birth,
        core_user_service.user_created_date,
        core_user_service.email_verification_date,
        core_user_service.created_at,
        core_user_service.updated_at,
        core_user_service.deleted_at,
        core_user_service.email_verified_at
    from core_user_service
    left join user_attempts
        on core_user_service.user_id = user_attempts.user_id
    left join user_referrals
        on core_user_service.user_id = user_referrals.referrer_user_id
    left join user_memberships
        on core_user_service.user_id = user_memberships.user_id
    left join user_achievements
        on core_user_service.user_id = user_achievements.user_id
)

select * from joined

