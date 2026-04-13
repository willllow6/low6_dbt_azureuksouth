with

source as (

    select *
    from {{ source('seven_days', 'sessions') }}

),

cleaned as (

    select
        session_id,
        user_id,
        game_id,
        site                                as url,
        '7days_performance'                 as client_id,
        case
            when site = 'https://7daysperformance.co.uk' then 'seven_days_performance'
            when site = 'https://ukcc.co.uk'             then 'ukcc'
            else null
        end                                 as tenant_id,
        case
            when site = 'https://7daysperformance.co.uk' then '7 Days Performance'
            when site = 'https://ukcc.co.uk'             then 'UKCC'
            else null
        end                                 as tenant_name,
        'instant_win'                       as game_type,
        case
            when site = 'https://7daysperformance.co.uk' then 1
            when site = 'https://ukcc.co.uk'             then 2
            else null
        end                                 as site_id,
        replace(substr(tickets, 2, len(tickets) - 2), '\\', '') as tmp,
        created_at::timestamp_ntz           as created_at,
        completed_at::timestamp_ntz         as completed_at,
        deleted_at::timestamp_ntz           as deleted_at,
        cast(created_at::timestamp_ntz as date) as created_date
    from source
    qualify row_number() over (
        partition by session_id
        order by created_at desc
    ) = 1

),

fixed as (

    select
        session_id,
        user_id,
        game_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        site_id,
        url,
        parse_json(
            concat(
                '[',
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                tmp,
                                '}"\\s*,\\s*"{', '},{'
                            ),
                            '(^"|"$)', ''
                        ),
                        '"}$', '}'
                    ),
                    '("name":"[^"]+)"\\s+([^"]+")', '\\1\\\\\" \\2'
                ),
                ']'
            )
        )                                   as ticket_array,
        created_date,
        created_at,
        completed_at,
        deleted_at
    from cleaned

)

select * from fixed
