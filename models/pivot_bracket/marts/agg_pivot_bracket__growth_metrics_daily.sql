with

date_generator as (

    select dateadd(day, seq4(), '2026-02-26'::date) as date_day
    from table(generator(rowcount => 600))
    where dateadd(day, seq4(), '2026-02-26'::date) <= sysdate()

)

select
    d.date_day,
    coalesce(cus.new_customers,0) as new_customers,
    coalesce(con.contests_created,0) as contests_created,
    coalesce(u.registrations,0) as registrations,
    coalesce(e.entries,0) as entries
from date_generator as d
left join {{ ref('int_pivot_bracket__customer_metrics_daily') }} as cus 
    on d.date_day = cus.created_date_et 
left join {{ ref('int_pivot_bracket__contest_metrics_daily') }} as con 
    on d.date_day = con.created_date_et 
left join {{ ref('int_pivot_bracket__registration_metrics_daily') }} as u
    on d.date_day = u.created_date_et 
left join {{ ref('int_pivot_bracket__entry_metrics_daily') }} as e
    on d.date_day = e.entry_date_et 
