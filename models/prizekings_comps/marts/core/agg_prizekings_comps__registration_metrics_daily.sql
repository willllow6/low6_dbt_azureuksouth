select
    cast(created_at as date) as registration_date,
    tenant_id,
    count(*) as registrations
from {{ ref('dim_prizekings_comps__users') }}
group by 1,2
