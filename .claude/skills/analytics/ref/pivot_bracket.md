# pivot_bracket (internal dbt models)


> These are internal dbt models used to build the mart tables. For querying data, see the mart reference files.

**25 models** | Materialization: 

## agg_pivot_bracket__entries_hourly


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\agg_pivot_bracket__entries_hourly.sql` |

### Dependencies

**Refs:**
- `mart_pivot_bracket__entries`


---

## agg_pivot_bracket__growth_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\agg_pivot_bracket__growth_metrics_daily.sql` |

### Dependencies

**Refs:**
- `int_pivot_bracket__contest_metrics_daily`
- `int_pivot_bracket__customer_metrics_daily`
- `int_pivot_bracket__entry_metrics_daily`
- `int_pivot_bracket__registration_metrics_daily`


---

## agg_pivot_bracket__selections


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\agg_pivot_bracket__selections.sql` |

### Dependencies

**Refs:**
- `mart_pivot_bracket__selections`


---

## dim_pivot_bracket__contests


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\dim_pivot_bracket__contests.sql` |

### Dependencies

**Refs:**
- `stg_pivot_bracket__contests`
- `stg_pivot_bracket__customers`
- `stg_pivot_bracket__tournaments`


---

## dim_pivot_bracket__customers


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\dim_pivot_bracket__customers.sql` |

### Dependencies

**Refs:**
- `stg_pivot_bracket__customers`


---

## dim_pivot_bracket__matches


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\dim_pivot_bracket__matches.sql` |

### Dependencies

**Refs:**
- `stg_pivot_bracket__matches`
- `stg_pivot_bracket__regions`
- `stg_pivot_bracket__rounds`
- `stg_pivot_bracket__teams`
- `stg_pivot_bracket__tournaments`


---

## dim_pivot_bracket__users


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\dim_pivot_bracket__users.sql` |

### Dependencies

**Refs:**
- `stg_pivot_bracket__users`


---

## fct_pivot_bracket__entries


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\fct_pivot_bracket__entries.sql` |

### Dependencies

**Refs:**
- `stg_pivot_bracket__entries`


---

## fct_pivot_bracket__selections


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\fct_pivot_bracket__selections.sql` |

### Dependencies

**Refs:**
- `stg_pivot_bracket__entries`
- `stg_pivot_bracket__selections`
- `stg_pivot_bracket__teams`


---

## int_pivot_bracket__contest_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\intermediate\int_pivot_bracket__contest_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_pivot_bracket__contests`


---

## int_pivot_bracket__customer_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\intermediate\int_pivot_bracket__customer_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_pivot_bracket__customers`


---

## int_pivot_bracket__entry_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\intermediate\int_pivot_bracket__entry_metrics_daily.sql` |

### Dependencies

**Refs:**
- `fct_pivot_bracket__entries`


---

## int_pivot_bracket__registration_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\intermediate\int_pivot_bracket__registration_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_pivot_bracket__users`


---

## mart_pivot_bracket__entries


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\mart_pivot_bracket__entries.sql` |

### Dependencies

**Refs:**
- `dim_pivot_bracket__contests`
- `dim_pivot_bracket__users`
- `fct_pivot_bracket__entries`


---

## mart_pivot_bracket__selections


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\marts\mart_pivot_bracket__selections.sql` |

### Dependencies

**Refs:**
- `dim_pivot_bracket__contests`
- `dim_pivot_bracket__matches`
- `fct_pivot_bracket__selections`


---

## stg_pivot_bracket__contests


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__contests.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.brackets`


---

## stg_pivot_bracket__customers


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__customers.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.customers`


---

## stg_pivot_bracket__entries


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__entries.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.user_selection`


---

## stg_pivot_bracket__matches


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__matches.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.matchups`


---

## stg_pivot_bracket__regions


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__regions.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.regions`


---

## stg_pivot_bracket__rounds


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__rounds.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.rounds`


---

## stg_pivot_bracket__selections


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__selections.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.selection_matchups`


---

## stg_pivot_bracket__teams


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__teams.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.teams`


---

## stg_pivot_bracket__tournaments


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__tournaments.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.tournaments`


---

## stg_pivot_bracket__users


| Attribute | Value |
|-----------|-------|
| Path | `pivot_bracket\staging\stg_pivot_bracket__users.sql` |

### Dependencies

**Sources:**
- `pivot_bracket.users`


---

