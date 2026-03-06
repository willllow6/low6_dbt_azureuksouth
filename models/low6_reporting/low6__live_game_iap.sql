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

)

select * from prizekings

