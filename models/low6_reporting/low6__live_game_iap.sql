with

prizekings as (

    select
        case
            when u.tenant_id = 'ae630d6e-17ef-4040-9a59-25ef7ffbb291'
                then 'pkuk'
            when u.tenant_id = '48ee3497-da5f-4f52-9dea-8b6b063cf3b8'
                then 'pksa'
            else ''
        end as app_id,
        sum(case when transaction_direction = 'outgoing' and balance_type = 'deposit' then amount else 0 end) as gross_revenue,
        sum(case when transaction_direction = 'outgoing' and balance_type = 'deposit' and cast(t.created_at as date) = current_date() - 1 then amount else 0 end) as yesterday_gross_revenue,
        sum(case when transaction_direction = 'outgoing' and balance_type = 'deposit' and cast(t.created_at as date) >= current_date() - 8 and cast(t.created_at as date) < current_date() then amount else 0 end) as last_7_days_gross_revenue,
        sum(case when transaction_direction = 'outgoing' and balance_type = 'deposit' and cast(t.created_at as date) >= current_date() - 29 and cast(t.created_at as date) < current_date() then amount else 0 end) as last_28_days_gross_revenue
    from {{ ref('stg_prizekings_comps__transactions') }} as t
    left join {{ ref('dim_prizekings_comps__users') }} as u
        on t.user_id = u.user_id
    group by 1

),

sevendays_pq as (

    select
        '7dpq' as app_id,
        sum(ticket_price) as gross_revenue,
        sum(case when session_date = current_date() - 1 then ticket_price else null end) as yesterday_gross_revenue,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then ticket_price else null end) as last_7_days_gross_revenue,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then ticket_price else null end) as last_28_days_gross_revenue
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Pirate Quest'

),

sevendays_cd as (

    select
        '7dcd' as app_id,
        sum(ticket_price) as gross_revenue,
        sum(case when session_date = current_date() - 1 then ticket_price else null end) as yesterday_gross_revenue,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then ticket_price else null end) as last_7_days_gross_revenue,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then ticket_price else null end) as last_28_days_gross_revenue
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Coin Drop'
    
),

sevendays_dz as (

    select
        '7ddz' as app_id,
        sum(ticket_price) as gross_revenue,
        sum(case when session_date = current_date() - 1 then ticket_price else null end) as yesterday_gross_revenue,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then ticket_price else null end) as last_7_days_gross_revenue,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then ticket_price else null end) as last_28_days_gross_revenue
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Drop Zone'
    
),

sevendays_ad as (

    select
        '7dad' as app_id,
        sum(ticket_price) as gross_revenue,
        sum(case when session_date = current_date() - 1 then ticket_price else null end) as yesterday_gross_revenue,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then ticket_price else null end) as last_7_days_gross_revenue,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then ticket_price else null end) as last_28_days_gross_revenue
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Alien Dash'
    
),

unioned as (

    select * from prizekings

    union all

    select *
    from sevendays_pq

    union all

    select *
    from sevendays_cd

    union all

    select *
    from sevendays_dz

    union all

    select *
    from sevendays_ad

)

select * from unioned

