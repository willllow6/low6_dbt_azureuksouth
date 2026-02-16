with

source as (

    select *
    from {{ source('prizekings_comps','promotions') }}

),

renamed as (

    select

        ----------  ids
        id as promotion_id,

        ---------- strings
        promotion_type,
        reward_type as bonus_type,

        ---------- numerics
        promotion_value as qualification_value,
        reward_value,

        ---------- booleans
        is_active,

        ---------- dates

        ---------- timestamps
        start_date as starts_at,
        end_date as ends_at,
        created_at,
        updated_at

    from source

)

select * from renamed