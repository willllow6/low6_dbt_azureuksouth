with

source as (

    select *
    from {{ source('gaming1', 'tenants') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as tenant_id,

        ---------- strings
        'gaming1' as client_id,
        code as tenant_code,
        name_en as tenant_name,

        ---------- timestamps
        created_at

    from source

)

select * from renamed
