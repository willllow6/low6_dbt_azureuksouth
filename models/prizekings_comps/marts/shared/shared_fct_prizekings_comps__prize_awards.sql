{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_fct_prizekings_comps__prize_awards', 'prizekings_share') }}"
) }}

with

prize_awards as (

    select *
    from {{ ref('fct_prizekings_comps__prize_awards') }}

)

select
    entry_sk,
    contest_sk,
    user_id,
    prize_sk,
    prize_value,
    awarded_at
from prize_awards


