with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'dreamteam_game_registration') }}

),

renamed as (

    select

        ---------- ids
        upper(trim(cpn)) as cpn,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        game_year as dreamteam_game_year,
        game_type as dreamteam_game_type,
        tournament as dreamteam_tournament,
        _source_file as source_file,

        ---------- dates
        to_date(first_activity_date, 'DD-MM-YYYY') as first_activity_date,

        ---------- timestamps
        _loaded_at as loaded_at

    from source

)

select * from renamed
