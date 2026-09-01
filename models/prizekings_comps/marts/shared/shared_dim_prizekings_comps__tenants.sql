{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_dim_prizekings_comps__tenants', 'prizekings_share') }}"
) }}


with

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

)

select
    tenant_id,
    tenant_name
from tenants