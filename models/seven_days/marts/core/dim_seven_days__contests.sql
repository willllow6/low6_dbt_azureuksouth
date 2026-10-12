with

games as (

    select *
    from {{ ref('stg_seven_days__games') }}

),

sessions as (

    select *
    from {{ ref('stg_seven_days__sessions') }}

),

sale_window as (

    select
        contest_id,
        min(created_at)                 as first_sale_at,
        max(created_at)                 as last_sale_at,
        sum(array_size(ticket_array))   as entries
    from sessions
    group by 1

),

-- "today" is the UK calendar day; this model is a view, so it is evaluated at query time.
sale_status as (

    select
        contest_id,
        first_sale_at,
        last_sale_at,
        entries,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', last_sale_at) as date)
            = cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
                                        as has_entries_today
    from sale_window

),

final as (

    select
        g.contest_id,
        g.raffle_id,
        g.game_id,
        g.site_id,
        g.client_id,
        g.tenant_id,
        g.tenant_name,
        g.game_type,
        case
            when g.is_prod then g.game_name
            else 'Test'
        end                         as contest_name,
        case
            when not g.is_prod or coalesce(w.entries, 0) = 0    then 'test'
            when w.has_entries_today                            then 'live'
            else 'closed'
        end                         as contest_status,
        g.is_prod,
        g.ticket_price,
        g.ticket_price              as entry_fee,
        g.currency,
        w.first_sale_at             as starts_at,
        case
            when not w.has_entries_today then w.last_sale_at
        end                         as ends_at,
        w.last_sale_at,
        g.created_at,
        g.updated_at,
        g.deleted_at
    from games as g
    left join sale_status as w
        on g.contest_id = w.contest_id

)

select * from final
