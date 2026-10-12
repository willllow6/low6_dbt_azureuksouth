with

source as (

    select *
    from {{ source('seven_days', 'games') }}

),

renamed as (

    select
        -- ids
        {{ dbt_utils.generate_surrogate_key(['site_id', 'game_id']) }} as contest_id,
        game_id,
        raffle_id::varchar      as raffle_id,
        site_id,
        '7days_performance'     as client_id,
        case
            when site_id = 1    then 'seven_days_performance'
            when site_id = 2    then 'ukcc'
        end                     as tenant_id,

        -- strings
        case
            when site_id = 1    then '7 Days Performance'
            when site_id = 2    then 'UKCC'
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
        'GBP'                   as currency,

        -- numerics
        ticket_price,

        -- booleans
        ticket_price is not null as is_prod,

        -- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at,
        deleted_at::timestamp_ntz as deleted_at
    from source

)

select * from renamed
