select
    c.contest_id,
    c.customer_id,
    c.tournament_id,

    c.contest_name,
    c.contest_description,
    c.contest_status,
    c.contest_type,
    c.contest_opens_at,
    c.contest_opens_at_et,
    c.contest_closes_at,
    c.contest_closes_at_et,
    c.contest_starts_at,
    c.contest_starts_at_et,
    c.contest_ends_at,
    c.contest_ends_at_et,
    c.created_date_et,

    cus.customer_name,

    t.tournament_name,
    t.tournament_description,
    t.tournament_status,

    c.created_at,
    c.updated_at

from {{ ref('stg_pivot_bracket__contests') }} as c
left join {{ ref('stg_pivot_bracket__customers') }} as cus
    on c.customer_id = cus.customer_id 
left join {{ ref('stg_pivot_bracket__tournaments') }} as t
    on c.tournament_id = t.tournament_id