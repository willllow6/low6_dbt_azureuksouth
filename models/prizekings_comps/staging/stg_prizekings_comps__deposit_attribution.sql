with

source as (

    select *
    from {{ source('prizekings_comps', 'deposit_attribution') }}

),

renamed as (

    select

        ---------- ids
        id                      as attribution_id,
        transaction_id,
        user_id,
        affiliate_id,
        campaign_id,
        creative_id,
        click_id,
        previous_affiliate_id,
        overridden_by,

        ---------- strings
        attribution_source,
        commission_status,
        override_reason,

        ---------- booleans
        is_within_window,

        ---------- timestamps
        attributed_at,
        overridden_at,
        created_at,
        updated_at

    from source

)

select * from renamed
