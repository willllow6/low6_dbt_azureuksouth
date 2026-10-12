-- Legacy compatibility view: the original wide entry table, rebuilt from the core models with
-- the prod column list and order unchanged. Read by low6_reporting; delete once those models
-- move to fct_seven_days__entries + dim_seven_days__contests.

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

joined as (

    select
        e.entry_id,
        e.purchase_id                               as session_id,
        e.user_id,
        c.game_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        case e.tenant_id
            when 'seven_days_performance' then 'https://7daysperformance.co.uk'
            when 'ukcc'                   then 'https://ukcc.co.uk'
        end                                         as url,
        cast(e.entered_at as date)                  as session_date,
        e.entered_at                                as created_at,
        e.session_entry_number,
        e.user_entry_number,
        e.won_prize_tier                            as prize_tier,
        e.is_played,
        e.won_prize_ticket_id                       as prize_id,
        e.won_prize_name                            as prize_name,
        e.won_prize_type                            as prize_type,
        e.won_prize_odds                            as prize_odds,
        e.won_prize_odds_denominator                as prize_odds_denominator,
        e.won_prize_probability                     as prize_probability,
        c.contest_name                              as game_name,
        case
            when c.is_prod then concat('£', to_varchar(c.ticket_price, 'FM999990.00'), ' Entry')
            else 'Test'
        end                                         as game_description,
        c.ticket_price
    from entries as e
    left join contests as c
        on e.contest_id = c.contest_id

)

select * from joined
