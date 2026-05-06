with

source as (

    select *
    from {{ source('prizekings_comps','competition') }}

),

renamed as (

    select

        ----------  ids
        id as contest_id,
        'STB_' || id as contest_sk,
        tenant_id,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        'spot_the_ball' as contest_type,
        name as contest_name,
        description as contest_description,
        state as contest_status,

        ---------- numerics
        ticket_price as entry_fee,

        ---------- booleans
        case
            when deleted_at is null and state not in ('cancelled', 'closed')
                then true
            else false
        end as is_active,

        ---------- dates

        ---------- timestamps
        start_date as starts_at,
        end_date as ends_at,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed