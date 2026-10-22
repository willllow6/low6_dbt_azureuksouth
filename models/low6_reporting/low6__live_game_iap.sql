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

-- One app_id per seven_days product; only the named contests are counted (test games and
-- variants such as 'Coin Drop Football' are excluded). session_date is the UTC entry date.
sevendays_entries as (

    select
        case c.contest_name
            when 'Pirate Quest' then '7dpq'
            when 'Coin Drop'    then '7dcd'
            when 'Drop Zone'    then '7ddz'
            when 'Alien Dash'   then '7dad'
            when 'Pinball'      then '7dpb'
        end as app_id,
        e.entry_fee as ticket_price,
        cast(e.entered_at as date) as session_date
    from {{ ref('fct_seven_days__entries') }} as e
    inner join {{ ref('dim_seven_days__contests') }} as c
        on e.contest_id = c.contest_id

),

sevendays as (

    select
        app_id,
        sum(ticket_price) as gross_revenue,
        sum(case when session_date = current_date() - 1 then ticket_price else null end) as yesterday_gross_revenue,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then ticket_price else null end) as last_7_days_gross_revenue,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then ticket_price else null end) as last_28_days_gross_revenue
    from sevendays_entries
    where app_id is not null
    group by 1

),

unioned as (

    select * from prizekings

    union all

    select *
    from sevendays

)

select * from unioned

