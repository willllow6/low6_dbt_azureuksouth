-- Footballers that can appear on a user's cards. Not users: a user is a game player.
with

source as (

    select *
    from {{ source('gaming1', 'squads_players') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as player_id,
        contest_id::varchar as competition_id,
        external_id as player_external_id,
        team_external_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,
        first_name,
        last_name,
        nullif(trim(coalesce(first_name, '') || ' ' || coalesce(last_name, '')), '') as player_name,
        position as player_position,
        team_code,
        image_url,
        rarity,
        status as player_status,

        ---------- numerics
        gpg,

        ---------- timestamps
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
