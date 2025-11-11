with

source as (

    select *
    from {{ source('itv_spinoff','daily_streak') }}

),

renamed as (

    select

        ----------  ids
        user_id,

        ---------- strings

        ---------- numerics
        streak_day as streak_length_days,
        multiplier,
    
        ---------- booleans

        ---------- dates

        ---------- timestamps
        last_played_at

    from source

)

select * from renamed