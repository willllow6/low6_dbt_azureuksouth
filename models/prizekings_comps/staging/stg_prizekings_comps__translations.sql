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
        promotion_id,
        blog_id,
        category_id,
        competition_id,
        case 
            when competition_id is not null
                then  'STB_' || competition_id
            when raffle_id is not null
                then 'DRAW_' || raffle_id
            else null
        end as competition_sk,

        ---------- strings
        data_type,
        data as data_json,
        data:desc::string as translation_name,
        data:name::string as translation_description,
        -- content_type,

        ---------- numerics

        ---------- booleans
        -- is_active,

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed