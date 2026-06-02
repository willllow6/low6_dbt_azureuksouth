with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'squad_membership') }}

),

renamed as (

    select

        ---------- ids
        id as squad_membership_id,
        person_id as player_id,
        contestant_id as team_id,
        tournament_calendar_id as tournament_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        position as squad_position,

        ---------- numerics
        shirt_number,

        ---------- booleans
        active as is_active,

        ---------- dates
        start_date,
        end_date,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
