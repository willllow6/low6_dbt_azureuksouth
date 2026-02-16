select
    tenant_id,
    default_language_id,
    tenant_name,
    tenant_code,
    is_active
from {{ ref('stg_prizekings_comps__tenants') }}
