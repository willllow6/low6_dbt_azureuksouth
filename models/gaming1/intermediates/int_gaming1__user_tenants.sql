-- Resolves each user's best-known tenant. tipman_pickem resolves tenant purely via
-- users.location -> tenants.tenant_code, but gaming1's users.location is null for every row in
-- production, so that join never matches. Falls back to the tenant of the user's first entry
-- (int_gaming1__selection_entries.tenant_id, sourced from the contest, which is always populated),
-- and finally to client_id for users who registered but haven't entered yet. Centralizing this here
-- (rather than in every downstream agg model) lets dim_gaming1__users and everything built on it
-- mirror tipman_pickem's models verbatim.

with

users as (

    select
        user_id,
        client_id,
        location
    from {{ ref('stg_gaming1__users') }}

),

tenants as (

    select
        tenant_id,
        tenant_code,
        tenant_name
    from {{ ref('stg_gaming1__tenants') }}

),

location_matched as (

    select
        users.user_id,
        tenants.tenant_id,
        tenants.tenant_name
    from users
    inner join tenants
        on users.location = tenants.tenant_code

),

first_entries as (

    select
        user_id,
        tenant_id
    from {{ ref('int_gaming1__selection_entries') }}
    where entry_number = 1

),

first_entry_tenants as (

    select
        first_entries.user_id,
        tenants.tenant_id,
        tenants.tenant_name
    from first_entries
    left join tenants
        on first_entries.tenant_id = tenants.tenant_id

),

resolved as (

    select
        users.user_id,
        coalesce(lm.tenant_id, fet.tenant_id, users.client_id) as tenant_id,
        coalesce(lm.tenant_name, fet.tenant_name, users.client_id) as tenant_name
    from users
    left join location_matched as lm
        on users.user_id = lm.user_id
    left join first_entry_tenants as fet
        on users.user_id = fet.user_id

)

select * from resolved
