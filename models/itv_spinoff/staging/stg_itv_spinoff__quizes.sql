with

source as (

    select *
    from {{ source('itv_spinoff','quiz') }}

),

renamed as (

    select

        ----------  ids
        quiz_id,

        ---------- strings
        series,
        batch,
        quiz_type,
        status as quiz_status,

        ---------- numerics
    
        ---------- booleans

        ---------- dates
        cast(starts_at as date) as quiz_start_date,

        ---------- timestamps
        starts_at as quiz_starts_at,
        ends_at as quiz_ends_at,
        last_modified_at,
        updated_at

    from source

)

select * from renamed