with

referrals as (

    select *
    from {{ ref('itv_spinoff__referrals') }}

),

referral_stats as (

    select
        referral_date,
        count(*) as referrals,
        count(case when user_referral_number = 1 then 1 else 0 end) as first_referrals
    from referrals
    group by 1

)

select * from referral_stats