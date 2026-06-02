with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'booster') }}

),

renamed as (

    select

        ---------- ids
        id as booster_id,

        ---------- strings
        'engagecraft' as client_id,
        code as booster_code,
        name as booster_name,
        description,

        ---------- numerics
        max_uses_per_user,

        ---------- booleans
        is_enabled,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
