-- Source table squads_contests is the football competition (e.g. Belgian Pro League), not the
-- canonical contest -- that is a round (stg_gaming1__squads_contests).
with

source as (

    select *
    from {{ source('gaming1', 'squads_contests') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as competition_id,
        tenant_id::varchar as tenant_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,
        name as competition_name,
        slug as competition_slug,
        status as competition_status,
        daily_reveal_timezone,

        ---------- numerics
        cards_per_reveal,
        goal_points,
        shot_points,
        tackle_points,
        interception_points,

        ---------- times
        daily_reveal_time_of_day,

        ---------- timestamps
        convert_timezone('UTC', starts_at)::timestamp_ntz as starts_at,
        convert_timezone('UTC', ends_at)::timestamp_ntz as ends_at,
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
