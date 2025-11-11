with

source as (

    select *
    from {{ source('itv_spinoff','quiz_attempt') }}

),

renamed as (

    select

        ----------  ids
        quiz_id,
        user_id,

        ---------- strings

        ---------- numerics
        multiplier,
        base_score,
        score,
        fast_bonus,
        streak_bonus,
        end_of_quiz_bonus,
        total_points,
    
        ---------- booleans
        case when completed_at is not null then true else false end as is_complete,

        ---------- dates
        cast(started_at as date) as attempt_date,

        ---------- timestamps
        started_at as attempted_at,
        completed_at

    from source

)

select * from renamed