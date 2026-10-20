-- One row per player per site (tenant), from their production entries. There is no
-- registration data: registered_at is the first entry. Lifecycle status is relative to the
-- current UK day (view, evaluated at query time); "lapsed" means lapsed from our games only:
-- the player may still be on the site playing competitor games we can't see.

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
        e.user_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.purchase_id,
        e.entered_at,
        e.entry_date_uk,
        e.entry_fee,
        e.won_prize_amount,
        c.game_name,
        case when c.ticket_price < 1 then 'Low' else 'High' end    as price_tier
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod

),

user_games as (

    select
        tenant_id,
        user_id,
        game_name,
        sum(entry_fee)                                      as spend
    from prod_entries
    group by 1, 2, 3

),

user_price_tiers as (

    select
        tenant_id,
        user_id,
        price_tier,
        sum(entry_fee)                                      as spend
    from prod_entries
    group by 1, 2, 3

),

user_totals as (

    select
        tenant_id,
        user_id,
        any_value(client_id)                                as client_id,
        any_value(tenant_name)                              as tenant_name,
        any_value(game_type)                                as game_type,
        min(entered_at)                                     as first_entered_at,
        max(entered_at)                                     as last_entered_at,
        min(entry_date_uk)                                  as first_entry_date_uk,
        max(entry_date_uk)                                  as last_entry_date_uk,
        min_by(game_name, entered_at)                       as first_game_name,
        count(distinct entry_date_uk)                       as days_active,
        count(*)                                            as lifetime_entries,
        count(distinct purchase_id)                         as lifetime_purchases,
        sum(entry_fee)                                      as lifetime_spend,
        coalesce(sum(won_prize_amount), 0)                  as lifetime_credit_won,
        count(distinct game_name)                           as games_played
    from prod_entries
    group by 1, 2

),

final as (

    select
        t.user_id,
        t.client_id,
        t.tenant_id,
        t.tenant_name,
        t.game_type,
        t.first_entered_at                                  as registered_at,
        cast(null as varchar)                               as registration_type,
        t.first_entered_at,
        t.last_entered_at,
        t.first_entry_date_uk,
        t.last_entry_date_uk,
        t.first_game_name,
        g.game_name                                         as favourite_game_name,
        p.price_tier                                        as main_price_tier,
        t.games_played,
        t.days_active,
        t.lifetime_entries,
        t.lifetime_purchases,
        t.lifetime_spend,
        t.lifetime_credit_won,
        case
            when t.lifetime_spend >= {{ var('seven_days_whale_threshold') }}       then 'whale'
            when t.lifetime_spend >= {{ var('seven_days_big_spender_threshold') }} then 'big_spender'
            when t.lifetime_purchases >= 2                                          then 'regular'
            else 'one_off'
        end                                                 as spend_segment,
        datediff(
            day,
            t.last_entry_date_uk,
            cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
        )                                                   as days_since_last_entry,
        case
            when datediff(
                day,
                t.last_entry_date_uk,
                cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
            ) <= 7                                          then 'active'
            when datediff(
                day,
                t.last_entry_date_uk,
                cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
            ) <= 28                                         then 'lapsing'
            else 'lapsed'
        end                                                 as lifecycle_status
    from user_totals as t
    left join user_games as g
        on  t.tenant_id = g.tenant_id
        and t.user_id = g.user_id
    left join user_price_tiers as p
        on  t.tenant_id = p.tenant_id
        and t.user_id = p.user_id
    qualify row_number() over (
        partition by t.tenant_id, t.user_id
        order by g.spend desc, g.game_name, p.spend desc, p.price_tier
    ) = 1

)

select * from final
