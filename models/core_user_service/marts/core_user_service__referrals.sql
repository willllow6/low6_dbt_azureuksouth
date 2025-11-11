with

core_user_service_referrals as (

    select *
    from {{ ref('stg_core_user_service__referrals') }}

),

core_user_service_users as (

    select *
    from {{ ref('stg_core_user_service__users') }}

),

joined as (

    select
        referrals.tenant_id,
        referrals.app_id,
        referrals.referrer_user_id,
        referrals.referred_user_id,

        referrer_users.status as referrer_user_status,
        referrer_users.email as referrer_user_email,
        referrer_users.username as referrer_user_username,
        referrer_users.created_at as referrer_user_created_at,

        referred_users.status as referred_user_status,
        referred_users.email as referred_user_email,
        referred_users.username as referred_user_username,
        referred_users.created_at as referred_user_created_at,

        referrals.referral_date,
        referrals.referred_at,
        referrals.credited_at

    from core_user_service_referrals as referrals
    left join core_user_service_users as referrer_users
        on referrals.referrer_user_id = referrer_users.user_id
    left join core_user_service_users as referred_users
        on referrals.referred_user_id = referred_users.user_id

),

user_referral_rank as (

    select
        *,
        row_number() over (partition by referrer_user_id, app_id order by referred_at) as user_referral_number
    from joined

)

select * from user_referral_rank