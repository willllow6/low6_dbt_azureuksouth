with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'tournament_calendar') }}

),

renamed as (

    select

        ---------- ids
        id as tournament_id,
        opta_tournament_calendar_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        competition_name as tournament_name,
        season_label,
        format as tournament_format,
        status as tournament_status,
        budget_currency,

        ---------- numerics
        squad_size,
        starting_xi_size,
        max_transfers,
        transfer_limit_per_gameweek,
        extra_transfer_penalty_points,
        max_per_club,
        max_per_country,

        ---------- booleans
        case
            when status not in ('completed', 'cancelled')
                then true
            else false
        end as is_active,

        ---------- timestamps
        start_date::timestamp_ntz as starts_at,
        end_date::timestamp_ntz as ends_at,
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
