-- One row per site (tenant) per UK month per game per price tier per basket size band
-- (tickets bought in one purchase: 1, 2-4, 5-9, 10-24, 25+), production instances only.
-- Shows how revenue splits by how many tickets players buy at once.

with

purchases as (

    select *
    from {{ ref('fct_seven_days__purchases') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prod_purchases as (

    select
        p.client_id,
        p.tenant_id,
        p.tenant_name,
        p.game_type,
        p.user_id,
        date_trunc('month', p.purchase_date_uk)             as activity_month,
        c.game_name,
        case when c.ticket_price < 1 then 'Low' else 'High' end    as price_tier,
        p.tickets,
        p.purchase_price,
        case
            when p.tickets = 1  then '01'
            when p.tickets < 5  then '02-04'
            when p.tickets < 10 then '05-09'
            when p.tickets < 25 then '10-24'
            else '25+'
        end                                                 as basket_size_band
    from purchases as p
    inner join contests as c
        on p.contest_id = c.contest_id
    where c.is_prod

),

final as (

    select
        activity_month,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        game_name,
        price_tier,
        basket_size_band,
        count(*)                                            as purchases,
        count(distinct user_id)                             as players,
        sum(tickets)                                        as entries,
        sum(purchase_price)                                 as gross_revenue,
        round(sum(purchase_price) / nullif(sum(sum(purchase_price)) over (
            partition by tenant_id, activity_month, game_name, price_tier
        ), 0), 4)                                           as share_of_revenue,
        round(count(*) / nullif(sum(count(*)) over (
            partition by tenant_id, activity_month, game_name, price_tier
        ), 0), 4)                                           as share_of_purchases
    from prod_purchases
    group by 1, 2, 3, 4, 5, 6, 7, 8

)

select * from final
