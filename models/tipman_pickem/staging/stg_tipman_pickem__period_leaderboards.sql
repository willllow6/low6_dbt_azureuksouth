with

source as (

    select *
    from {{ source('tipman_pickem', 'aggregate_leaderboards') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as period_leaderboard_id,
        user_id::varchar as user_id,

        ---------- strings
        'tipman' as client_id,
        'pickem' as game_type,
        league_code as tenant_code,  -- joined to tenant_id in mart layer
        period_type,
        period_start,
        period_end,
        pickems_data as contest_data,

        ---------- numerics
        total_points,
        rank as leaderboard_position,

        ---------- booleans

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed
