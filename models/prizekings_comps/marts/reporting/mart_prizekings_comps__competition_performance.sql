with

entries as (

    select *
    from {{ ref('fct_prizekings_comps__competition_entries') }}

),

competitions as (

    select *
    from {{ ref('dim_prizekings_comps__competitions') }}

),

prize_awards as (

    select *
    from {{ ref('fct_prizekings_comps__prize_awards') }}

),

prizes as (

    select *
    from {{ ref('dim_prizekings_comps__prizes') }}

),

financials as (

    select *
    from {{ ref('int_prizekings_comps__competition_financials') }}

),

competition_metrics as (

    select
        -- cast(entries.created_at as date) as entry_date,
        competitions.competition_sk,
        competitions.tenant_name,
        competitions.competition_name,
        competitions.competition_type,
        competitions.competition_status,
        competitions.entry_price,
        competitions.starts_at,
        competitions.ends_at,
        count(*) as entries,
        sum(case when user_entry_number = 1 then 1 else 0 end) as first_user_entries,
        sum(case when entries.is_winner then 1 else 0 end ) as total_winning_entries,
        sum(case when prizes.prize_type = 'main' then 1 else 0 end) as total_main_winning_entries,
        sum(case when prizes.prize_type = 'second' then 1 else 0 end) as total_second_winning_entries,
        sum(case when prizes.prize_type = 'instant' then 1 else 0 end) as total_instant_winning_entries,
        coalesce(sum(prizes.value),0) as total_prize_value,
        coalesce(sum(case when prizes.prize_type = 'main' then prizes.value else 0 end),0) as total_main_prize_value,
        coalesce(sum(case when prizes.prize_type = 'second' then prizes.value else 0 end),0) as total_second_prize_value,
        coalesce(sum(case when prizes.prize_type = 'instant' then prizes.value else 0 end),0) as total_instant_prize_value
    from entries
    inner join competitions
        on entries.competition_sk = competitions.competition_sk
    left join prize_awards
        on entries.entry_sk = prize_awards.entry_sk
    left join prizes 
        on prize_awards.prize_sk = prizes.prize_sk
    group by 1,2,3,4,5,6,7,8

),

add_financials as (

    select
        c.*,
        coalesce(gross_entry_revenue,0) as gross_entry_revenue,
        coalesce(cash_entry_revenue,0) as cash_entry_revenue,
        coalesce(credit_entry_spend,0) as credit_entry_spend,
        coalesce(total_prize_value_awarded,0) as total_prize_value_awarded,
        coalesce(cash_prize_value_awarded,0) as cash_prize_value_awarded,
        coalesce(credit_prize_value_awarded,0) as credit_prize_value_awarded,
        coalesce(gross_profit,0) as gross_profit
    from competition_metrics as c
    left join financials as f 
        on c.competition_sk = f.competition_sk
)

select * from add_financials