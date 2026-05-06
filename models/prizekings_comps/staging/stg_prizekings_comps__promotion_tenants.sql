with

source as (

    select *
    from {{ source('prizekings_comps','promotion_tenants') }}

),

renamed as (

    select

        ----------  ids
        id as promotion_tenant_id,
        promotion_id,
        tenant_id,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,

        ---------- numerics

        ---------- booleans

        ---------- dates

        ---------- timestamps
        created_at

    from source

)

select * from renamed