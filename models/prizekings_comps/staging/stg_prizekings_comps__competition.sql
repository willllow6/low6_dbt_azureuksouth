with

source as (

    select *
    from {{ source('prizekings_comps','competition') }}

),

renamed as (

    select

        ----------  ids
        id as competition_id,
        'STB_' || id as competition_sk, 
        tenant_id,

        ---------- strings
        'spot_the_ball' as competition_type,
        name as competition_name,
        description as competition_description,
        ticket_price as entry_price,
        state as competition_status,

        ---------- numerics
    
        ---------- booleans

        ---------- dates

        ---------- timestamps
        start_date as starts_at,
        end_date as ends_at,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed