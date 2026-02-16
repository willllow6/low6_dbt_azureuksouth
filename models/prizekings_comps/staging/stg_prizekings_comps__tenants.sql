with

source as (

    select *
    from {{ source('prizekings_comps','tenants') }}

),

renamed as (

    select

        ----------  ids
        id as tenant_id,
        default_language_id,

        ---------- strings
        name as tenant_name,
        code as tenant_code,

        ---------- numerics

        ---------- booleans
        is_active,

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed