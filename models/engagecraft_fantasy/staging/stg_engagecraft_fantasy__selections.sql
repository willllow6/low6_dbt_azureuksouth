with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_team_player') }}

),

renamed as (

    select

        ---------- ids
        id as selection_id,
        fantasy_team_id,
        fantasy_player_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,

        ---------- numerics
        position_slot,

        ---------- booleans
        is_starter,
        is_captain,
        is_vice_captain,

        ---------- timestamps
        created_at::timestamp_ntz as created_at

    from source

)

select * from renamed
