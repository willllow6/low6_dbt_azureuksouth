with

source as (

    select *
    from {{ source('prizekings_comps', 'campaign') }}

),

renamed as (

    select

        ---------- ids
        id          as campaign_id,
        tenant_id,

        ---------- strings
        name        as campaign_name,
        code        as campaign_code,
        status,

        ---------- booleans
        (status = 'active' and deleted_at is null) as is_active,

        ---------- timestamps
        starts_at,
        expires_at,
        created_at,
        deleted_at

    from source

)

select * from renamed
