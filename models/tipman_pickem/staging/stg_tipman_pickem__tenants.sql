with

source as (

    select *
    from {{ source('tipman_pickem', 'leagues') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as tenant_id,

        ---------- strings
        'tipman' as client_id,
        code as tenant_code,
        name_en as tenant_name,
        league_type as tenant_type,

        ---------- booleans

        ---------- timestamps
        created_at

    from source

)

select * from renamed
