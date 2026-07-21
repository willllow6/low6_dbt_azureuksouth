with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_team_transfer') }}

),

renamed as (

    select

        ---------- ids
        id as transfer_id,
        fantasy_team_id,
        gameweek_id,
        transfer_in_id as player_in_id,
        transfer_out_id as player_out_id,
        superseded_by_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        status as transfer_status,
        updated_formation,

        ---------- numerics
        gameweek as gameweek_number,

        ---------- semi-structured
        metadata,

        ---------- timestamps
        scheduled_at::timestamp_ntz as scheduled_at,
        applied_at::timestamp_ntz as applied_at,
        conflict_resolved_at::timestamp_ntz as conflict_resolved_at,
        undone_at::timestamp_ntz as undone_at,
        created_at::timestamp_ntz as created_at

    from source

)

select * from renamed
