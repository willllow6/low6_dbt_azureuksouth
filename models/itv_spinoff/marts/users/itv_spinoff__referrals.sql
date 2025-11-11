with

core_user_service_referrals as (

    select *
    from {{ ref('core_user_service__referrals') }}
    where app_id = 'spin_off'

)

select * from core_user_service_referrals
