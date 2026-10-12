with

sessions as (

    select *
    from {{ ref('stg_seven_days__sessions') }}

),

games as (

    select *
    from {{ ref('stg_seven_days__games') }}

),

final as (

    select
        s.session_id                                as purchase_id,
        s.user_id,
        s.contest_id,
        s.client_id,
        s.tenant_id,
        s.tenant_name,
        s.game_type,
        s.created_at                                as purchased_at,
        cast(
            convert_timezone('UTC', '{{ var("local_timezone") }}', s.created_at) as date
        )                                           as purchase_date_uk,
        s.completed_at,
        array_size(s.ticket_array)                  as tickets,
        g.ticket_price,
        array_size(s.ticket_array) * g.ticket_price as purchase_price,
        g.currency
    from sessions as s
    left join games as g
        on s.contest_id = g.contest_id

)

select * from final
