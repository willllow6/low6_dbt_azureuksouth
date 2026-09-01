{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_dim_prizekings_comps__contests', 'prizekings_share') }}"
) }}


with

contests as (

    select *
    from {{ ref('dim_prizekings_comps__contests') }}

)

select
    contest_sk,
    tenant_id,
    contest_name,
    contest_type,
    contest_status,
    entry_fee,
    starts_at,
    ends_at
from contests