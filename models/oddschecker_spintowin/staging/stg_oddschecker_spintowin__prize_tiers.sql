with

source as (

    select *
    from {{ source('oddschecker_spintowin', 'prize_tiers') }}

),

renamed as (

    select

        ---------- ids
        id as prize_tier_id,

        ---------- strings
        'oddschecker' as client_id,
        'instant_win' as game_type,
        name as prize_tier_name,
        type as prize_tier_type,
        level,
        inventory_period_type,

        ---------- numerics
        amount,
        monthly_limit,
        display_order,

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed
