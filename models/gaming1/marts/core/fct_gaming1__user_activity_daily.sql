-- Active = entered a contest or made a pick (either game), or revealed a day's cards (squads),
-- on that UK day.
with

entries as (

    select *
    from {{ ref('int_gaming1__entries_unioned') }}

),

selections as (

    select *
    from {{ ref('int_gaming1__selections_unioned') }}

),

squads_slots as (

    select *
    from {{ ref('stg_gaming1__squads_entry_slots') }}

),

events as (

    select entry_id, entered_at as event_at, 'entry' as event_type
    from entries

    union all

    select entry_id, selected_at, 'selection'
    from selections
    where selected_at is not null

    union all

    select entry_id, revealed_at, 'reveal'
    from squads_slots
    where revealed_at is not null

),

final as (

    select
        e.user_id,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', ev.event_at) as date) as activity_date_uk,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        count_if(ev.event_type = 'entry')                   as entries,
        count_if(ev.event_type = 'selection')               as selections,
        count_if(ev.event_type = 'reveal')                  as reveals
    from events as ev
    inner join entries as e
        on ev.entry_id = e.entry_id
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
    selections,
    reveals
from final
