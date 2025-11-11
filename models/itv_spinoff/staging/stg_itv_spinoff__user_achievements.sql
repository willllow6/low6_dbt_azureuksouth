with

source as (

    select *
    from {{ source('itv_spinoff','user_achievement') }}

),

renamed as (

    select

        ----------  ids
        user_id,
        achievement_id,

        ---------- strings

        ---------- numerics
    
        ---------- booleans

        ---------- dates
        cast(achieved_at as date) as achievement_date,

        ---------- timestamps
        achieved_at

    from source

)

select * from renamed