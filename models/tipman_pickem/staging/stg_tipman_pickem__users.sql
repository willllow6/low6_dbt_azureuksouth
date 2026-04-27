with

source as (

    select *
    from {{ source('tipman_pickem', 'users') }}
    -- where service_user_id is null  -- exclude internal service accounts

),

renamed as (

    select

        ----------  ids
        id::varchar as user_id,
        sso_user_id::varchar as external_user_id,

        ---------- strings
        'tipman' as client_id,
        'tipman' as tenant_id,  -- resolved to actual tenant in dim_tipman_pickem__users via location → tenant_code join
        'pickem' as game_type,
        case when sso_user_id is not null then 'sso' else 'form' end as registration_type,
        username,
        email,
        country,
        state,
        location,  -- maps to leagues.code (tenant_code); retained for tenant resolution in dim

        ---------- booleans

        ---------- timestamps
        created_at as registered_at,
        created_at

    from source

)

select * from renamed
