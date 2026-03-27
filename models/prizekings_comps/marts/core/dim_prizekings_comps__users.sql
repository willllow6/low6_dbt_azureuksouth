with

users as (

    select *
    from {{ ref('stg_prizekings_comps__users') }}

)

select
    user_id,
    tenant_id,
    first_name,
    last_name,
    email,
    mobile,
    roles,
    balance,
    is_active,
    created_at,
    updated_at
from users
