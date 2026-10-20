-- One row per site (tenant) per UK day per game per price tier per purchase outcome
-- (production instances only). What players do after a purchase, by its outcome:
--   purchase_outcome       'credit_win' (any ticket won site credit), 'other_win' (cash or
--                          item prize, no credit), 'no_win'
--   rebuy_*                the player's next purchase of any of our games on the site came
--                          within 1 hour / 24 hours; *_same_game when it was the same game
--   eligible_*_purchases   purchases at least 1 / 24 hours old, the denominators for the
--                          rebuy rates (recent purchases can't have rebought yet)
--   next_purchase_value_1h value of those next purchases made within 1 hour
-- Credit is paid into the site wallet and can be spent on competitor games we can't see:
-- compare next_purchase_value_1h with credit_won for how much comes back to our games.

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

purchase_outcomes as (

    select
        e.purchase_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        c.game_name,
        case when c.ticket_price < 1 then 'Low' else 'High' end    as price_tier,
        min(e.entered_at)                                   as purchased_at,
        min(e.entry_date_uk)                                as purchase_date_uk,
        sum(e.entry_fee)                                    as purchase_value,
        count_if(e.won_prize_type = 'credit')               as credit_wins,
        count_if(e.is_winner and e.won_prize_type != 'credit') as other_wins,
        coalesce(sum(e.won_prize_amount), 0)                as credit_won
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod
    group by 1, 2, 3, 4, 5, 6, 7, 8

),

next_purchases as (

    select
        *,
        case
            when credit_wins > 0    then 'credit_win'
            when other_wins > 0     then 'other_win'
            else 'no_win'
        end                                                 as purchase_outcome,
        lead(purchased_at) over (
            partition by tenant_id, user_id order by purchased_at, purchase_id
        )                                                   as next_purchased_at,
        lead(game_name) over (
            partition by tenant_id, user_id order by purchased_at, purchase_id
        )                                                   as next_game_name,
        lead(purchase_value) over (
            partition by tenant_id, user_id order by purchased_at, purchase_id
        )                                                   as next_purchase_value
    from purchase_outcomes

),

flagged as (

    select
        *,
        datediff(minute, purchased_at, next_purchased_at)  as minutes_to_next_purchase,
        purchased_at <= dateadd(hour, -1, (select max(purchased_at) from purchase_outcomes))
                                                            as is_eligible_1h,
        purchased_at <= dateadd(hour, -24, (select max(purchased_at) from purchase_outcomes))
                                                            as is_eligible_24h
    from next_purchases

),

final as (

    select
        purchase_date_uk,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        game_name,
        price_tier,
        purchase_outcome,
        count(*)                                                        as purchases,
        count(distinct user_id)                                         as players,
        sum(purchase_value)                                             as gross_revenue,
        sum(credit_won)                                                 as credit_won,
        count_if(is_eligible_1h)                                        as eligible_1h_purchases,
        count_if(is_eligible_1h and minutes_to_next_purchase < 60)      as rebuy_1h,
        count_if(is_eligible_1h and minutes_to_next_purchase < 60
            and next_game_name = game_name)                             as rebuy_1h_same_game,
        count_if(is_eligible_24h)                                       as eligible_24h_purchases,
        count_if(is_eligible_24h and minutes_to_next_purchase < 1440)   as rebuy_24h,
        round(count_if(is_eligible_1h and minutes_to_next_purchase < 60)
            / nullif(count_if(is_eligible_1h), 0), 4)                   as rebuy_1h_rate,
        round(count_if(is_eligible_24h and minutes_to_next_purchase < 1440)
            / nullif(count_if(is_eligible_24h), 0), 4)                  as rebuy_24h_rate,
        coalesce(sum(case
            when minutes_to_next_purchase < 60 then next_purchase_value
        end), 0)                                                        as next_purchase_value_1h,
        median(minutes_to_next_purchase)                                as median_minutes_to_next_purchase
    from flagged
    group by 1, 2, 3, 4, 5, 6, 7, 8

)

select * from final
