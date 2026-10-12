with

prizes as (

    select *
    from {{ ref('int_seven_days__prize_arrays_flattened_to_prizes') }}

),

prize_values as (

    select *
    from {{ ref('seven_days_prize_values') }}

),

valued as (

    select
        p.*,
        v.prize_value               as seed_prize_value,
        coalesce(p.parsed_prize_value, v.prize_value) as base_prize_value
    from prizes as p
    left join prize_values as v
        on upper(trim(p.prize_name)) = upper(trim(v.prize_name))

),

final as (

    select
        prize_id,
        contest_id,
        raffle_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        prize_tier,
        prize_sort_order,
        prize_name,
        source_prize_type,
        case
            when parsed_prize_value is not null
                and upper(prize_name) like '%CREDIT%'                       then 'site_credit'
            when parsed_prize_value is not null
                and upper(prize_name) like '%CASH%'                         then 'cash'
            else 'item'
        end                                                     as prize_category,
        prize_odds,
        odds_denominator,
        prize_probability,
        base_prize_value + coalesce(extra_cash, 0)              as prize_value,
        case
            when parsed_prize_value is not null then 'name'
            when seed_prize_value is not null   then 'seed'
        end                                                     as prize_value_source,
        extra_cash,
        'GBP'                                                   as currency,
        prize_probability
            * (base_prize_value + coalesce(extra_cash, 0))      as expected_value_per_ticket,
        prize_description
    from valued

)

select * from final
