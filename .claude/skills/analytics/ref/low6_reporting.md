# low6_reporting (internal dbt models)


> These are internal dbt models used to build the mart tables. For querying data, see the mart reference files.

**2 models** | Materialization: 

## low6__live_game_iap


| Attribute | Value |
|-----------|-------|
| Path | `low6_reporting\low6__live_game_iap.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__users`
- `stg_prizekings_comps__transactions`


---

## low6__live_game_kpis


| Attribute | Value |
|-----------|-------|
| Path | `low6_reporting\low6__live_game_kpis.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.quiz_attempt`
- `pivot_bracket.user_selection`
**Refs:**
- `mart_prizekings_comps__competition_entries`


---

