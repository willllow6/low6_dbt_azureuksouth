with

tenants as (

    select *
    from {{ ref('stg_tipman_pickem__tenants') }}

)

select
    tenant_id,
    client_id,
    tenant_code,
    tenant_name,
    tenant_type,
    created_at
from tenants
