with

source as (

    select *
    from {{ source('seven_days', 'sessions') }}

),

renamed as (

    select
        -- ids
        session_id,
        user_id,
        game_id,
        case
            when site = 'https://7daysperformance.co.uk' then 1
            when site = 'https://ukcc.co.uk'             then 2
        end                                 as site_id,
        '7days_performance'                 as client_id,
        case
            when site = 'https://7daysperformance.co.uk' then 'seven_days_performance'
            when site = 'https://ukcc.co.uk'             then 'ukcc'
        end                                 as tenant_id,

        -- strings
        case
            when site = 'https://7daysperformance.co.uk' then '7 Days Performance'
            when site = 'https://ukcc.co.uk'             then 'UKCC'
        end                                 as tenant_name,
        'instant_win'                       as game_type,
        site                                as url,

        -- semi-structured
        tickets                             as ticket_array,

        -- timestamps
        min(source.created_at) over (partition by source.session_id)::timestamp_ntz
                                            as created_at,
        max(source.created_at) over (partition by source.session_id)::timestamp_ntz
                                            as updated_at,
        completed_at::timestamp_ntz         as completed_at,
        deleted_at::timestamp_ntz           as deleted_at
    from source
    -- The source re-saves a session as its tickets are played: same session_id and tickets,
    -- new row id and created_at (about 4% of sessions, up to 346 copies). Keep the latest save
    -- for the ticket state; created_at is the first save (the purchase), updated_at the last.
    qualify row_number() over (
        partition by source.session_id
        order by source.created_at desc, source.id desc
    ) = 1

),

keyed as (

    select
        session_id,
        user_id,
        {{ dbt_utils.generate_surrogate_key(['site_id', 'game_id']) }} as contest_id,
        game_id,
        site_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        url,
        ticket_array,
        created_at,
        updated_at,
        completed_at,
        deleted_at
    from renamed

)

select * from keyed
