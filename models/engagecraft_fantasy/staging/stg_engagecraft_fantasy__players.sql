with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'persons') }}

),

renamed as (

    select

        ---------- ids
        id as player_id,
        contestant_id as team_id,
        country_id,
        opta_person_id as opta_player_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        position as playing_position,
        nationality,
        nationality_flag_key,

        ---------- dates
        date_of_birth,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
