with

source as (

    select *
    from {{ source('pivot_bracket', 'matchups') }}

),

renamed as (

    select

        ----------  ids
        id as match_id,
        tournament_id,
        region_id,
        round_id,
        home_team_id,
        away_team_id,
        winner_id as winner_team_id,

        ---------- strings
        slot as match_slot,

        ---------- numerics
        home_team_score,
        away_team_score,

        ---------- booleans

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source


)

select * from renamed