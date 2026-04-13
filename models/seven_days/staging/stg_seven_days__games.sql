with

source as (

    select *
    from {{ source('seven_days', 'games') }}

),

renamed as (

    select
        game_id,
        site_id,
        '7days_performance'     as client_id,
        case
            when site_id = 1    then 'seven_days_performance'
            when site_id = 2    then 'ukcc'
            else null
        end                     as tenant_id,
        case
            when site_id = 1    then '7 Days Performance'
            when site_id = 2    then 'UKCC'
            else null
        end                     as tenant_name,
        'instant_win'           as game_type,
        trim(
            regexp_replace(
                name,
                '\\s*-\\s*|\\s*christmas\\s*',
                ' ',
                1,
                0,
                'i'
            )
        )                       as game_name,
        concat(
            '£',
            to_varchar(ticket_price, 'FM999990.00'),
            ' Entry'
        )                       as game_description,
        ticket_price,
        case
            when ticket_price is null then false
            else true
        end                     as is_prod,
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at,
        deleted_at::timestamp_ntz as deleted_at
    from source

)

select * from renamed
