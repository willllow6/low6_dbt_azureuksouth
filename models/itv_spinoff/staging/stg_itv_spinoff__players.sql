with

source as (

    select *
    from {{ source('itv_spinoff_live','players') }}

),

renamed as (

    select

        ----------  ids
        id as player_id,
        userid as user_id,

        ---------- strings
        name

        ---------- numerics
    
        ---------- booleans

        ---------- dates

        ---------- timestamps

    from source

)

select * from renamed