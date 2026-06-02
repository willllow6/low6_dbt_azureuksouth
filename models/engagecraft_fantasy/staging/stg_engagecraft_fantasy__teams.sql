with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'contestants') }}

),

renamed as (

    select

        ---------- ids
        id as team_id,
        tournament_calendar_id as tournament_id,
        country_id,
        opta_contestant_id as opta_team_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        name as team_name,
        short_name as team_short_name,
        contestant_code as team_code,
        contestant_flag_key as team_flag_key,
        shirt_key,
        country,
        country_flag_key,
        group_label as tournament_group,

        ---------- booleans
        is_national_team,
        is_eliminated,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
