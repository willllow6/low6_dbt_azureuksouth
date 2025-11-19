with

source as (

    select *
    from {{ source('core_user_service','users') }}

),

renamed as (

    select

        ----------  ids
        tenant_id,
        app_id,
        user_id,

        ---------- strings
        status,
        email,
        username,
        try_parse_json(roles) as roles,
        try_parse_json(consents) as consents_json,
        try_parse_json(meta) as meta_json,
        try_parse_json(profile) as profile_json,
        try_parse_json(preferences) as preferences_json,
        profile_json:firstName::string as first_name,
        profile_json:lastName::string as last_name,
        profile_json:county::string as county,
        profile_json:phoneNumber::number as phone_number,
        preferences_json:favouriteItvShow::string as favourite_itv_show,
        TRY_TO_DATE(PARSE_JSON(profile):dob::string) as dob,
        TRY_TO_DATE(PARSE_JSON(profile):dateOfBirth::string) as dateofbirth,
        coalesce(dob,dateofbirth) as date_of_birth,
        referral_code,
        case
            when floor(datediff('day', date_of_birth, current_date() )/365) is null then 'Unknown' 
            when floor(datediff('day', date_of_birth, current_date() )/365)< 18 then '13-17'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 21 then '18-20'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 26 then '21-25'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 31 then '26-30'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 36 then '31-35'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 41 then '36-40'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 46 then '41-45'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 51 then '46-50'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 56 then '51-55'
            when floor(datediff('day', date_of_birth, current_date() )/365)< 61 then '56-60'
            else '60+'
        end as age_band,
        case 
            when year(date_of_birth) is null then 'Unknown' 
            when year(date_of_birth) < 1946 then 'Silent Generation' 
            when year(date_of_birth) < 1966 then 'Baby Boomer' 
            when year(date_of_birth) < 1980 then 'Generation X' 
            when year(date_of_birth) < 1996 then 'Millenials' 
            else 'Generation Z' 
        end as generation,

        ---------- numerics
        floor(datediff('day', date_of_birth, current_date() )/365) as age,
    
        ---------- booleans
        email_verified as has_verified_email,
        coalesce(consents_json:marketing::boolean,false) as has_consented_marketing,
        coalesce(meta_json:profileEverCompleted::boolean,false) as has_completed_profile,
        coalesce(profile_json:isSkyVegasCustomer::boolean,false) as is_sky_vegas_customer,
        case when deleted_at is not null then true else false end as is_deleted,

        ---------- dates
        cast(created_at as date) as user_created_date,
        cast(email_verified_at as date) as email_verification_date,

        ---------- timestamps
        created_at,
        updated_at,
        logged_in_at,
        deleted_at,
        email_verified_at

    from source

)

select * from renamed