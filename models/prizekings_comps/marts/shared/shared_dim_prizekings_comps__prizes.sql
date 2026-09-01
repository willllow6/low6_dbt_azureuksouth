{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_dim_prizekings_comps__prizes', 'prizekings_share') }}"
) }}


with

prizes as (

    select *
    from {{ ref('dim_prizekings_comps__prizes') }}

)

select
    prize_sk,
    contest_sk,
    prize_type,
    quantity,
    prize_name,
    value
from prizes