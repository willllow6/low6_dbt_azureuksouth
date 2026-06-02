with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_player') }}

),

renamed as (

    select

        ---------- ids
        id as fantasy_player_id,
        person_id as player_id,
        tournament_calendar_id as tournament_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        position as fantasy_position,
        availability_display,

        ---------- numerics
        price,
        ownership_pct,
        price_change_up,
        price_change_down,

        ---------- booleans
        is_visible,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
