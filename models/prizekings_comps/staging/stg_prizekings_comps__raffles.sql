with

source as (

    select *
    from {{ source('prizekings_comps','raffles') }}

),

renamed as (

    select

        ----------  ids
        id as competition_id,
        'DRAW_' || id as competition_sk,
        tenant_id,

        ---------- strings
        'draw' as competition_type,
        status as competition_status,

        ---------- numerics
        tickets_available as max_entries,
        tickets_sold as entries,
        cost_per_ticket as entry_price,
        ticket_increment as purchase_increment,
        limit_ticket_buy as user_max_entries,
    
        ---------- booleans
        has_instant_win_prizes,

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