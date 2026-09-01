{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_fct_prizekings_comps__entries', 'prizekings_share') }}"
) }}

with

entries as (

    select *
    from {{ ref('fct_prizekings_comps__entries') }}

)

select
    entry_sk,
    contest_sk,
    user_id,
    tenant_id,
    prize_sk,
    is_winner,
    created_at
from entries


