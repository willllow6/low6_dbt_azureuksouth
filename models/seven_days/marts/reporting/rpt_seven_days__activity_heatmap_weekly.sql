-- One row per site (tenant) per UK week (Monday start) per UK day of week per UK hour with
-- purchases (production instances only). For finding peak and quiet times.
--   day_of_week   1 = Monday ... 7 = Sunday

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
        p.tickets,
        p.purchase_price,
        convert_timezone('UTC', '{{ var("local_timezone") }}', p.purchased_at)
                                                            as purchased_at_uk
    from purchases as p
    inner join contests as c
        on p.contest_id = c.contest_id
    where c.is_prod

),

final as (

    select
        date_trunc('week', purchased_at_uk)::date           as activity_week,
        dayofweekiso(purchased_at_uk)                       as day_of_week,
        dayname(purchased_at_uk)                            as day_name,
        hour(purchased_at_uk)                               as hour_of_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        count(distinct user_id)                             as players,
        count(*)                                            as purchases,
        sum(tickets)                                        as entries,
        sum(purchase_price)                                 as gross_revenue
    from prod_purchases
    group by 1, 2, 3, 4, 5, 6, 7, 8

)

select * from final
