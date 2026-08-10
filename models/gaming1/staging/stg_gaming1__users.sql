with

source as (

    select *
    from {{ source('gaming1', 'users') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as user_id,
        sso_user_id::varchar as external_user_id,

        ---------- strings
        'gaming1' as client_id,
        'pickem' as game_type,
        case when sso_user_id is not null then 'sso' else 'form' end as registration_type,
        username,
        email,
        country,
        state,
        location,  -- resolved to tenant_code in dim_gaming1__users
        referral_code,

        ---------- timestamps
        created_at as registered_at,
        created_at

    from source

)

select * from renamed
