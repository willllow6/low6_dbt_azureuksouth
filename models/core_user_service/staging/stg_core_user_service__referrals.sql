with

source as (

    select *
    from {{ source('core_user_service','referrals') }}

),

renamed as (

    select

        ----------  ids
        tenant_id,
        app_id,
        referrer_user_id,
        referred_user_id,

        ---------- strings

        ---------- numerics
    
        ---------- booleans

        ---------- dates
        cast(created_at as date) as referral_date,

        ---------- timestamps
        created_at as referred_at,
        credited_at

    from source

)

select * from renamed