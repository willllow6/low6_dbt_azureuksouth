with

source as (

    select *
    from {{ source('prizekings_comps','translations') }}

),

renamed as (

    select

        ----------  ids
        id as translation_id,
        language_id,
        raffle_id,
        prize_id,
        case
            when prize_id is not null
                then 'DRAW_' || prize_id
            else null
        end as prize_sk,
        promotion_id,
        blog_id,
        category_id,
        competition_id as contest_id,
        case
            when competition_id is not null
                then 'STB_' || competition_id
            when raffle_id is not null
                then 'DRAW_' || raffle_id
            else null
        end as contest_sk,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        data_type,
        data as data_json,
        data:name::string as translation_name,
        data:description::string as translation_description,

        ---------- numerics

        ---------- booleans

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed