with

source as (

    select *
    from {{ source('itv_spinoff','achievement_category') }}

),

renamed as (

    select

        ----------  ids
        achievement_category_id,

        ---------- strings
        achievement_category_name

        ---------- numerics
    
        ---------- booleans

        ---------- dates

        ---------- timestamps

    from source

)

select * from renamed