with

source as (

    select *
    from {{ source('itv_spinoff','friends_league_membership') }}

),

renamed as (

    select

        ----------  ids
        id as league_membership_id,
        league_id,
        user_id,

        ---------- strings

        ---------- numerics
    
        ---------- booleans

        ---------- dates
        cast(joined_at as date) as joined_date,

        ---------- timestamps
        joined_at

    from source

)

select * from renamed