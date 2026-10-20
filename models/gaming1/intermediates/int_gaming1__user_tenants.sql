-- Resolves each user's tenant. Users carry no tenant in the source, and users.location is null
-- for every row in production.
-- While gaming1 has a single tenant, every user is assigned it (including users who haven't
-- entered yet). If more tenants appear, resolution falls back to: users.location ->
-- tenants.tenant_code, then the tenant of the user's first entry in either game (from the
-- contest), then client_id.

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

-- one row only while the platform has exactly one tenant, else empty
single_tenant as (

    select
        tenant_id,
        tenant_name
    from tenants
    qualify count(*) over () = 1

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

-- first entry in any gaming1 game (picks or squads)
first_entries as (

    select
        user_id,
        tenant_id
    from {{ ref('int_gaming1__entries_unioned') }}
    qualify row_number() over (partition by user_id order by entered_at, entry_id) = 1

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
        coalesce(st.tenant_id, lm.tenant_id, fet.tenant_id, users.client_id) as tenant_id,
        coalesce(st.tenant_name, lm.tenant_name, fet.tenant_name, users.client_id) as tenant_name
    from users
    left join single_tenant as st
        on true
    left join location_matched as lm
        on users.user_id = lm.user_id
    left join first_entry_tenants as fet
        on users.user_id = fet.user_id

)

select * from resolved
