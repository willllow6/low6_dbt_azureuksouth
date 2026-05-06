with

source as (

    select *
    from {{ source('prizekings_comps','competition_prize') }}

),

renamed as (

    select

        ----------  ids
        id as prize_id,
        'STB_' || id as prize_sk,
        competition_id as contest_id,
        'STB_' || competition_id as contest_sk,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        name as prize_name,
        description as prize_description,
        type as prize_type,

        ---------- numerics
        max_winners as quantity,
        tier,
        value,

        ---------- booleans

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed