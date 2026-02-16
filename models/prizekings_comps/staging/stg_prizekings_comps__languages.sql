with

source as (

    select *
    from {{ source('prizekings_comps','languages') }}

),

renamed as (

    select

        ----------  ids
        id as language_id,

        ---------- strings
        name as language_name,
        code as language_code,

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