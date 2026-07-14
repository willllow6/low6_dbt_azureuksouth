with

date_spine as (

    select dateadd(day, seq4(), '{{ var("oddschecker_spintowin_start_date") }}'::date) as date_day
    from table(generator(rowcount => 600))
    where dateadd(day, seq4(), '{{ var("oddschecker_spintowin_start_date") }}'::date) <= sysdate()

),

registrations as (

    select
        cast(registered_at as date) as date_day,
        count(*) as registrations
    from {{ ref('fct_oddschecker_spintowin__registrations') }}
    group by 1

),

spins as (

    select
        cast(spun_at as date) as date_day,
        count(*) as total_spins,
        count(distinct user_id) as active_users
    from {{ ref('fct_oddschecker_spintowin__spins') }}
    group by 1

),

prize_awards as (

    select
        cast(awarded_at as date) as date_day,
        count(*) as total_prize_awards,
        count_if(prize_type = 'voucher') as voucher_prizes,
        sum(case when prize_type = 'voucher' then prize_amount else 0 end) as total_voucher_value,
        count_if(prize_type = 'oc_plus') as oc_plus_prizes
    from {{ ref('fct_oddschecker_spintowin__prize_awards') }}
    group by 1

)

select
    d.date_day,
    'oddschecker' as client_id,
    'oddschecker' as tenant_id,
    'oddschecker' as tenant_name,
    'instant_win' as game_type,
    coalesce(r.registrations, 0) as registrations,
    coalesce(s.total_spins, 0) as total_spins,
    coalesce(s.active_users, 0) as active_users,
    coalesce(p.total_prize_awards, 0) as total_prize_awards,
    coalesce(p.voucher_prizes, 0) as voucher_prizes,
    coalesce(p.total_voucher_value, 0) as total_voucher_value,
    coalesce(p.oc_plus_prizes, 0) as oc_plus_prizes
from date_spine as d
left join registrations as r
    on d.date_day = r.date_day
left join spins as s
    on d.date_day = s.date_day
left join prize_awards as p
    on d.date_day = p.date_day
