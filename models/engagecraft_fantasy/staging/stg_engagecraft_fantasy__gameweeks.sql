with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'gameweek') }}

),

renamed as (

    select

        ---------- ids
        id as gameweek_id,
        tournament_calendar_id as tournament_id,
        finalised_by_admin_user_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        name as gameweek_name,
        status as gameweek_status,
        knockout_round,

        ---------- numerics
        number as gameweek_number,
        budget_initial,

        ---------- booleans
        is_double_gameweek,
        case
            when deleted_at is null
                and status not in ('completed', 'cancelled')
                then true
            else false
        end as is_active,

        ---------- timestamps
        starts_at::timestamp_ntz as starts_at,
        ends_at::timestamp_ntz as ends_at,
        deadline_at::timestamp_ntz as deadline_at,
        finalised_at::timestamp_ntz as finalised_at,
        deleted_at::timestamp_ntz as deleted_at,
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
