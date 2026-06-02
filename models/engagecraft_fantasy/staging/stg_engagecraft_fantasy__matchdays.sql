with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'matchday') }}

),

renamed as (

    select

        ---------- ids
        id as matchday_id,
        tournament_calendar_id as tournament_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,
        name as matchday_name,
        status as matchday_status,

        ---------- numerics
        matchday_number,
        expected_match_count,
        budget_initial,

        ---------- booleans
        case
            when deleted_at is null
                and status not in ('completed', 'cancelled')
                then true
            else false
        end as is_active,

        ---------- timestamps
        starts_at::timestamp_ntz as starts_at,
        ends_at::timestamp_ntz as ends_at,
        locks_at::timestamp_ntz as locks_at,
        deleted_at::timestamp_ntz as deleted_at,
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
