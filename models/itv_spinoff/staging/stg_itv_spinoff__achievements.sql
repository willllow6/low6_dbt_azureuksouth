with

source as (

    select *
    from {{ source('itv_spinoff','achievement') }}

),

renamed as (

    select

        ----------  ids
        achievement_id,
        category_id as achievement_category_id,

        ---------- strings
        name as achievement_name,
        description as achievement_description,
        type as achievement_type,

        ---------- numerics
    
        ---------- booleans

        ---------- dates

        ---------- timestamps

    from source

)

select * from renamed