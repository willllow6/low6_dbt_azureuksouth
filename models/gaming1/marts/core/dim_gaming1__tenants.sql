with

tenants as (

    select *
    from {{ ref('stg_gaming1__tenants') }}

)

select
    tenant_id,
    client_id,
    tenant_code,
    tenant_name,
    created_at
from tenants
