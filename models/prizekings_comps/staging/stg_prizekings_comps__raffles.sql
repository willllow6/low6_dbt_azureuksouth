with

source as (

    select *
    from {{ source('prizekings_comps','raffles') }}

),

renamed as (

    select

        ----------  ids
        id as contest_id,
        'DRAW_' || id as contest_sk,
        tenant_id,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        'draw' as contest_type,
        status as contest_status,

        ---------- numerics
        tickets_available as max_entries,
        tickets_sold as entries,
        cost_per_ticket as entry_fee,
        ticket_increment as purchase_increment,
        limit_ticket_buy as user_max_entries,

        ---------- booleans
        has_instant_win_prizes,
        case
            when status not in ('cancelled', 'closed', 'inactive')
                then true
            else false
        end as is_active,

        ---------- dates

        ---------- timestamps
        start_date as starts_at,
        end_date as ends_at,
        visible_from as opens_at,
        created_at,
        updated_at

    from source

)

select * from renamed