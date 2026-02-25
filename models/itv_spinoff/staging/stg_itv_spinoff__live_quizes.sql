with

source as (

    select *
    from {{ source('itv_spinoff_live','livequizzes') }}

),

renamed as (

    select

        ----------  ids
        id as live_quiz_id,
        parentquizid as parent_quiz_id,

        ---------- strings
        batch,
        series,
        version,

        ---------- numerics
    
        ---------- booleans
        isactive as is_active,
        isfinished as is_finished,

        ---------- dates
        cast(date as date) as quiz_start_date,

        ---------- timestamps
        date as quiz_starts_at

    from source

)

select * from renamed