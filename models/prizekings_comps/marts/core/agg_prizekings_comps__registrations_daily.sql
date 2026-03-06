select
    cast(created_at as date) as registration_date,
    tenant_name,
    roles,
    is_active,
    count(*) as registrations
from {{ ref('mart_prizekings_comps__registrations') }}
group by 1,2,3,4
