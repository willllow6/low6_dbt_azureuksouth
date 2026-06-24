with

source as (

    select *
    from {{ source('prizekings_comps', 'affiliate') }}

),

renamed as (

    select

        ---------- ids
        id          as affiliate_id,
        user_id,

        ---------- strings
        label       as affiliate_name,
        code        as affiliate_code,
        status,

        ---------- numerics
        share,

        ---------- booleans
        (status = 'active' and deleted_at is null) as is_active,

        ---------- timestamps
        starts_at::timestamp_ntz as starts_at,
        expires_at::timestamp_ntz as expires_at,
        created_at::timestamp_ntz as created_at,
        deleted_at::timestamp_ntz as deleted_at

    from source

)

select * from renamed
