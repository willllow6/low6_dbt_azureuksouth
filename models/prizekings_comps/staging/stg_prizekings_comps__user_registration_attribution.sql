with

source as (

    select *
    from {{ source('prizekings_comps', 'user_registration_attribution') }}

),

renamed as (

    select

        ---------- ids
        id              as attribution_id,
        user_id,
        affiliate_id,
        campaign_id,
        creative_id,
        click_id,

        ---------- strings
        attribution_source,

        ---------- timestamps
        attributed_at::timestamp_ntz as attributed_at,
        created_at::timestamp_ntz as created_at

    from source

)

select * from renamed
