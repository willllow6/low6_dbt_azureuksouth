-- One row per site (tenant) per UK week per measure per bridge component:
-- player_growth_accounting_weekly unpivoted into waterfalls from last week to this week.
--   revenue:  opening (last week's gross) + new + reactivated + expansion
--             + contraction (<= 0) - churned = closing (this week's gross)
--   players:  opening (last week's active) + new + reactivated - churned
--             = closing (this week's active)
-- Opening is 0 if the site had no entries last week. amount is signed. waterfall_start /
-- waterfall_end are the bar's ends: Tableau Gantt bar with waterfall_start on Rows and
-- amount on Size, no table calcs needed. Both sum correctly across sites. sort_order is
-- shared across measures (players skip expansion / contraction).

with

growth as (

    select *
    from {{ ref('rpt_seven_days__player_growth_accounting_weekly') }}

),

weekly as (

    select
        activity_week,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        is_complete_week,
        lag(activity_week) over (partition by tenant_id order by activity_week)
            = dateadd(week, -1, activity_week)              as has_previous_week,
        lag(gross_revenue) over (partition by tenant_id order by activity_week)
                                                            as previous_gross_revenue,
        lag(active_players) over (partition by tenant_id order by activity_week)
                                                            as previous_active_players,
        gross_revenue,
        new_revenue,
        reactivated_revenue,
        expansion_revenue,
        contraction_revenue,
        churned_revenue,
        active_players,
        new_players,
        reactivated_players,
        churned_players
    from growth

),

-- unpivot needs one type across all components
signed as (

    select
        activity_week,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        is_complete_week,
        iff(has_previous_week, coalesce(previous_gross_revenue, 0), 0)::number(18, 2)
                                                            as revenue__opening,
        coalesce(new_revenue, 0)::number(18, 2)             as revenue__new,
        coalesce(reactivated_revenue, 0)::number(18, 2)     as revenue__reactivated,
        coalesce(expansion_revenue, 0)::number(18, 2)       as revenue__expansion,
        coalesce(contraction_revenue, 0)::number(18, 2)     as revenue__contraction,
        (-coalesce(churned_revenue, 0))::number(18, 2)      as revenue__churned,
        coalesce(gross_revenue, 0)::number(18, 2)           as revenue__closing,
        iff(has_previous_week, coalesce(previous_active_players, 0), 0)::number(18, 2)
                                                            as players__opening,
        coalesce(new_players, 0)::number(18, 2)             as players__new,
        coalesce(reactivated_players, 0)::number(18, 2)     as players__reactivated,
        (-coalesce(churned_players, 0))::number(18, 2)      as players__churned,
        coalesce(active_players, 0)::number(18, 2)          as players__closing
    from weekly

),

components as (

    select *
    from (values
        (1, 'opening',     'Last week',   'total'),
        (2, 'new',         'New',         'increase'),
        (3, 'reactivated', 'Reactivated', 'increase'),
        (4, 'expansion',   'Expansion',   'increase'),
        (5, 'contraction', 'Contraction', 'decrease'),
        (6, 'churned',     'Churned',     'decrease'),
        (7, 'closing',     'This week',   'total')
    ) as v (sort_order, component, component_label, component_type)

),

unpivoted as (

    select
        activity_week,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        is_complete_week,
        split_part(lower(measure_component), '__', 1)       as measure,
        split_part(lower(measure_component), '__', 2)       as component,
        amount
    from signed
        unpivot (amount for measure_component in (
            revenue__opening,
            revenue__new,
            revenue__reactivated,
            revenue__expansion,
            revenue__contraction,
            revenue__churned,
            revenue__closing,
            players__opening,
            players__new,
            players__reactivated,
            players__churned,
            players__closing
        ))

),

running as (

    select
        u.*,
        c.sort_order,
        c.component_label,
        c.component_type,
        -- opening plus every step up to and including this one
        sum(case when c.component != 'closing' then u.amount else 0 end) over (
            partition by u.tenant_id, u.activity_week, u.measure
            order by c.sort_order
            rows between unbounded preceding and current row
        )                                                   as running_total
    from unpivoted as u
    inner join components as c
        on u.component = c.component

),

final as (

    select
        activity_week,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        is_complete_week,
        measure,
        sort_order,
        component,
        component_label,
        component_type,
        amount,
        case
            when component_type = 'total' then 0
            else running_total - amount
        end                                                 as waterfall_start,
        case
            when component_type = 'total' then amount
            else running_total
        end                                                 as waterfall_end
    from running

)

select * from final
