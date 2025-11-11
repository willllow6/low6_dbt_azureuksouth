with

source as (

    select *
    from {{ source('itv_spinoff','friends_league') }}

),

renamed as (

    select

        ----------  ids
        league_id,
        creator_user_id,

        ---------- strings
        league_name,
        league_code,

        ---------- numerics
    
        ---------- booleans

        ---------- dates
        cast(created_at as date) as league_created_date,

        ---------- timestamps
        created_at

    from source

)

select * from renamed