with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

final as (

    select
        user_id,
        tenant_id,
        entry_date_uk                   as activity_date_uk,
        client_id,
        tenant_name,
        game_type,
        count(*)                        as entries,
        count(distinct purchase_id)     as purchases
    from entries
    group by 1, 2, 3, 4, 5, 6

)

select
    user_id,
    activity_date_uk,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    entries,
    purchases
from final
