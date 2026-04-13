with

entries as (

    select *
    from {{ ref('int_seven_days__entries') }}

),

games as (

    select *
    from {{ ref('stg_seven_days__games') }}

),

joined as (

    select
        e.entry_id,
        e.session_id,
        e.user_id,
        e.game_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.url,
        e.session_date,
        e.created_at,
        e.session_entry_number,
        e.user_entry_number,
        e.prize_tier,
        e.is_played,
        e.prize_id,
        e.prize_name,
        e.prize_type,
        e.prize_odds,
        e.prize_odds_denominator,
        e.prize_probability,
        case
            when g.is_prod then g.game_name
            else 'Test'
        end                         as game_name,
        case
            when g.is_prod then g.game_description
            else 'Test'
        end                         as game_description,
        g.ticket_price
    from entries as e
    left join games as g
        on  e.game_id = g.game_id
        and e.site_id = g.site_id

)

select * from joined
