with

source as (

    select *
    from {{ source('prizekings_comps','user_promotions') }}

),

renamed as (

    select

        ----------  ids
        id as user_promotion_id,
        user_id,
        promotion_id,

        ---------- strings
        code as promotion_code,
        status as promotion_status,

        ---------- numerics
        max_uses,

        ---------- booleans
        case
            when used = 1
                then true
            else false
        end as is_used,

        ---------- dates

        ---------- timestamps
        completed_at,
        created_at

    from source

)

select * from renamed