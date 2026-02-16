with

source as (

    select *
    from {{ source('prizekings_comps','users') }}

),

renamed as (

    select

        ----------  ids
        id as user_id,
        tenant_id,


        ---------- strings
        first_name,
        last_name,
        email,
        mobile,
        roles,

        ---------- numerics
        balance,

        ---------- booleans
        is_active,

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed