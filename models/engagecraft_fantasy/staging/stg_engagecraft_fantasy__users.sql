with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'user') }}

),

renamed as (

    select

        ---------- ids
        id as user_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        engagecraft_id,
        ref_id,
        username,
        ref_fav_club_id as favourite_club_id,
        ref_country_code as country_code,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at,
        last_login_at::timestamp_ntz as last_login_at

    from source

)

select * from renamed
