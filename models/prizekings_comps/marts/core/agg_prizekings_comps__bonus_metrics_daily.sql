with

transactions as (

    select *
    from {{ ref('stg_prizekings_comps__transactions') }}
    where transaction_direction = 'incoming'
        and transaction_source in ('deposit_bonus', 'welcome_bonus', 'registration_bonus', 'deposit_match', 'referral_bonus')

),

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

user_promotions as (

    select *
    from {{ ref('fct_prizekings_comps__user_promotions') }}
    where is_used = true

),

promotions as (

    select *
    from {{ ref('dim_prizekings_comps__promotions') }}
    where promotion_type = 'ticket_bonus'

),

transaction_bonus_metrics as (

    select
        cast(transactions.created_at as date) as date_day,
        transactions.client_id,
        users.tenant_id,
        t.tenant_name,
        transactions.game_type,
        count(case when transactions.transaction_source = 'deposit_bonus' then 1 end) as deposit_bonuses,
        sum(case when transactions.transaction_source = 'deposit_bonus' then transactions.amount else 0 end) as deposit_bonus_value,
        count(case when transactions.transaction_source in ('welcome_bonus', 'registration_bonus') then 1 end) as welcome_bonuses,
        sum(case when transactions.transaction_source in ('welcome_bonus', 'registration_bonus') then transactions.amount else 0 end) as welcome_bonus_value,
        count(case when transactions.transaction_source = 'deposit_match' then 1 end) as deposit_matches,
        sum(case when transactions.transaction_source = 'deposit_match' then transactions.amount else 0 end) as deposit_match_value,
        count(case when transactions.transaction_source = 'referral_bonus' then 1 end) as referral_bonuses,
        sum(case when transactions.transaction_source = 'referral_bonus' then transactions.amount else 0 end) as referral_bonus_value
    from transactions
    left join users
        on transactions.user_id = users.user_id
    left join tenants as t
        on users.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

),

ticket_bonus_metrics as (

    select
        cast(user_promotions.completed_at as date) as date_day,
        promotions.client_id,
        tenants.tenant_id,
        tenants.tenant_name,
        promotions.game_type,
        count(*) as ticket_bonuses,
        sum(promotions.reward_value) as ticket_bonus_value
    from user_promotions
    inner join promotions
        on user_promotions.promotion_id = promotions.promotion_id
    inner join tenants
        on promotions.tenant_id = tenants.tenant_id
    group by 1, 2, 3, 4, 5

),

joined as (

    select
        coalesce(tr.date_day, tk.date_day) as date_day,
        coalesce(tr.client_id, tk.client_id) as client_id,
        coalesce(tr.tenant_id, tk.tenant_id) as tenant_id,
        coalesce(tr.tenant_name, tk.tenant_name) as tenant_name,
        coalesce(tr.game_type, tk.game_type) as game_type,
        coalesce(tr.deposit_bonuses, 0) as deposit_bonuses,
        coalesce(tr.deposit_bonus_value, 0) as deposit_bonus_value,
        coalesce(tr.welcome_bonuses, 0) as welcome_bonuses,
        coalesce(tr.welcome_bonus_value, 0) as welcome_bonus_value,
        coalesce(tr.deposit_matches, 0) as deposit_matches,
        coalesce(tr.deposit_match_value, 0) as deposit_match_value,
        coalesce(tr.referral_bonuses, 0) as referral_bonuses,
        coalesce(tr.referral_bonus_value, 0) as referral_bonus_value,
        coalesce(tk.ticket_bonuses, 0) as ticket_bonuses,
        coalesce(tk.ticket_bonus_value, 0) as ticket_bonus_value
    from transaction_bonus_metrics as tr
    full outer join ticket_bonus_metrics as tk
        on tr.date_day = tk.date_day
        and tr.tenant_id = tk.tenant_id

)

select * from joined
