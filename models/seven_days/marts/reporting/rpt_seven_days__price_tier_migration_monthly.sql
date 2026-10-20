-- One row per site (tenant) per UK month per previous main price tier per main price tier
-- (production instances only). A player's main price tier in a month is the tier (Low < £1,
-- High >= £1) they spent most on. previous_main_price_tier is their tier in their previous
-- active month, or 'New' if this is their first month; movement is 'new', 'traded_up',
-- 'traded_down' or 'stayed'. months_since_previous shows reactivations (> 1).

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prod_entries as (

    select
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        date_trunc('month', e.entry_date_uk)                as activity_month,
        case when c.ticket_price < 1 then 'Low' else 'High' end    as price_tier,
        e.entry_fee
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod

),

tenants as (

    select distinct
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from prod_entries

),

user_month_tiers as (

    select
        tenant_id,
        user_id,
        activity_month,
        price_tier,
        sum(entry_fee)                                      as spend
    from prod_entries
    group by 1, 2, 3, 4

),

user_months as (

    select
        tenant_id,
        user_id,
        activity_month,
        sum(spend)                                          as spend,
        max_by(price_tier, spend)                           as main_price_tier
    from user_month_tiers
    group by 1, 2, 3

),

user_month_history as (

    select
        *,
        lag(main_price_tier) over (
            partition by tenant_id, user_id order by activity_month
        )                                                   as previous_main_price_tier,
        lag(activity_month) over (
            partition by tenant_id, user_id order by activity_month
        )                                                   as previous_month
    from user_months

),

final as (

    select
        h.activity_month,
        t.client_id,
        h.tenant_id,
        t.tenant_name,
        t.game_type,
        coalesce(h.previous_main_price_tier, 'New')         as previous_main_price_tier,
        h.main_price_tier,
        case
            when h.previous_main_price_tier is null                                 then 'new'
            when h.previous_main_price_tier = 'Low' and h.main_price_tier = 'High'  then 'traded_up'
            when h.previous_main_price_tier = 'High' and h.main_price_tier = 'Low'  then 'traded_down'
            else 'stayed'
        end                                                 as movement,
        count(*)                                            as players,
        count_if(datediff(month, h.previous_month, h.activity_month) > 1)
                                                            as reactivated_players,
        sum(h.spend)                                        as gross_revenue
    from user_month_history as h
    inner join tenants as t
        on h.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5, 6, 7, 8

)

select * from final
