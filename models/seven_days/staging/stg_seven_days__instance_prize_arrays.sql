-- One row per raffle prize list (latest load). The prize array is flattened in
-- int_seven_days__prize_arrays_flattened_to_prizes.

with

source as (

    select *
    from {{ source('seven_days_prizes', 'instance_prize_arrays') }}

),

latest as (

    select *
    from source
    qualify row_number() over (
        partition by site_id, raffle_id
        order by loaded_at desc
    ) = 1

),

renamed as (

    select
        -- ids
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
        payload_hash,

        -- semi-structured
        payload,

        -- timestamps
        loaded_at::timestamp_ntz as loaded_at
    from latest

)

select * from renamed
