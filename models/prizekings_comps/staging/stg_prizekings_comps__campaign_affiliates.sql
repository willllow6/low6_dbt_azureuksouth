with

source as (

    select *
    from {{ source('prizekings_comps', 'campaign_affiliate') }}

),

renamed as (

    select

        ---------- ids
        campaign_id,
        affiliate_id

    from source

)

select * from renamed
