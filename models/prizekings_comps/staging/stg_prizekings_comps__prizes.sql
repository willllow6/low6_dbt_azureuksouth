with

source as (

    select *
    from {{ source('prizekings_comps','prizes') }}

),

renamed as (

    select

        ----------  ids
        id as prize_id,
        'DRAW_' || id as prize_sk,
        raffle_id as competition_id,
        'DRAW_' || competition_id as competition_sk,

        ---------- strings
        prize_type,

        ---------- numerics
        quantity,
        -- tier,
        prize_value as value,
        assigned_count,

        ---------- booleans

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed