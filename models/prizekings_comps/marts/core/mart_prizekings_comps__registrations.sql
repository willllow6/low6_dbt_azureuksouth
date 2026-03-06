select
    u.user_id,
    u.tenant_id,
    u.first_name,
    u.last_name,
    u.email,
    u.mobile,
    u.roles,
    u.balance,
    u.is_active,
    t.tenant_name,
    u.created_at,
    u.updated_at
from {{ ref('dim_prizekings_comps__users') }} as u 
left join  {{ ref('dim_prizekings_comps__tenants') }} as t 
    on u.tenant_id = t.tenant_id