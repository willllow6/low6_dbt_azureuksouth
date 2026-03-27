with

tenants as (

    select *
    from {{ ref('stg_prizekings_comps__tenants') }}

)

select
    tenant_id,
    default_language_id,
    tenant_name,
    tenant_code,
    is_active
from tenants
