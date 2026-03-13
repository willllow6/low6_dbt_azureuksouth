with

source as (

    select *
    from {{ source('pivot_bracket', 'selection_matchups') }}

),

renamed as (

    select

        ----------  ids
        id as selection_id,
        user_selection_id as entry_id,
        matchup_id as match_id,
        winner_team_id as selected_team_id,

        ---------- strings

        ---------- numerics

        ---------- booleans
        is_correct,

        ---------- dates
        cast(created_at as date) as created_date,

        ---------- timestamps
        created_at,
        updated_at

    from source


)

select * from renamed