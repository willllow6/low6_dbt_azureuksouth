# prizekings_comps (internal dbt models)


> These are internal dbt models used to build the mart tables. For querying data, see the mart reference files.

**39 models** | Materialization: 

## agg_prizekings_comps__competition_entries_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__competition_entries_daily.sql` |

### Dependencies

**Refs:**
- `mart_prizekings_comps__competition_entries`


---

## agg_prizekings_comps__competition_performance


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__competition_performance.sql` |

### Dependencies

**Refs:**
- `int_prizekings_comps__competition_financials`
- `mart_prizekings_comps__competition_entries`


---

## agg_prizekings_comps__deposit_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__deposit_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__users`
- `fct_prizekings_comps__deposits`


---

## agg_prizekings_comps__entry_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__entry_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__competitions`
- `fct_prizekings_comps__competition_entries`


---

## agg_prizekings_comps__financial_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__financial_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__users`
- `stg_prizekings_comps__transactions`


---

## agg_prizekings_comps__growth_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__growth_metrics_daily.sql` |

### Dependencies

**Refs:**
- `agg_prizekings_comps__deposit_metrics_daily`
- `agg_prizekings_comps__entry_metrics_daily`
- `agg_prizekings_comps__financial_metrics_daily`
- `agg_prizekings_comps__registration_metrics_daily`
- `agg_prizekings_comps__user_activity_daily`
- `dim_prizekings_comps__tenants`


---

## agg_prizekings_comps__promotion_completions_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__promotion_completions_daily.sql` |

### Dependencies

**Refs:**
- `mart_prizekings_comps__promotion_completions`


---

## agg_prizekings_comps__registration_metrics_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__registration_metrics_daily.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__users`


---

## agg_prizekings_comps__registrations_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__registrations_daily.sql` |

### Dependencies

**Refs:**
- `mart_prizekings_comps__registrations`


---

## agg_prizekings_comps__user_activity_daily


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\agg_prizekings_comps__user_activity_daily.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__competitions`
- `fct_prizekings_comps__competition_entries`


---

## dim_prizekings_comps__competitions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\dim_prizekings_comps__competitions.sql` |

### Dependencies

**Refs:**
- `int_prizekings_comps__competitions_unioned`
- `stg_prizekings_comps__translations`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `competition_sk` |  | unique, not_null |
| `tenant_id` |  | not_null |
| `competition_type` |  | not_null, accepted_values |


---

## dim_prizekings_comps__prizes


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\dim_prizekings_comps__prizes.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__competition_prize`
- `stg_prizekings_comps__prizes`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `prize_sk` |  | unique, not_null |
| `competition_sk` |  | not_null |


---

## dim_prizekings_comps__promotions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\dim_prizekings_comps__promotions.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__promotion_tenants`
- `stg_prizekings_comps__promotions`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `promotion_id` |  | not_null |


---

## dim_prizekings_comps__tenants


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\dim_prizekings_comps__tenants.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__tenants`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `tenant_id` |  | unique, not_null |


---

## dim_prizekings_comps__users


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\dim_prizekings_comps__users.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__users`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `user_id` |  | unique, not_null |
| `tenant_id` |  | not_null |


---

## fct_prizekings_comps__competition_entries


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\fct_prizekings_comps__competition_entries.sql` |

### Dependencies

**Refs:**
- `int_prizekings_comps__competition_entries_unioned`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `entry_sk` |  | unique, not_null |
| `competition_sk` |  | not_null, relationships |
| `user_id` |  | not_null |


---

## fct_prizekings_comps__deposits


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\fct_prizekings_comps__deposits.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__transactions`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `transaction_id` |  | unique, not_null |
| `user_id` |  | not_null |


---

## fct_prizekings_comps__prize_awards


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\fct_prizekings_comps__prize_awards.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__competition_entry`
- `stg_prizekings_comps__user_raffle_tickets`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `entry_sk` |  | unique, not_null |
| `competition_sk` |  | not_null |
| `user_id` |  | not_null |


---

## fct_prizekings_comps__user_promotions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\fct_prizekings_comps__user_promotions.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__user_promotions`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `user_promotion_id` |  | unique, not_null |
| `user_id` |  | not_null |
| `promotion_id` |  | not_null |


---

## int_prizekings_comps__competition_entries_unioned


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\intermediates\int_prizekings_comps__competition_entries_unioned.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__competition_entry`
- `stg_prizekings_comps__user_raffle_tickets`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `entry_sk` |  | unique, not_null |
| `competition_sk` |  | not_null |
| `user_id` |  | not_null |


---

## int_prizekings_comps__competition_financials


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\intermediates\int_prizekings_comps__competition_financials.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__transactions`


---

## int_prizekings_comps__competitions_unioned


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\intermediates\int_prizekings_comps__competitions_unioned.sql` |

### Dependencies

**Refs:**
- `stg_prizekings_comps__competition`
- `stg_prizekings_comps__raffles`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `competition_sk` |  | unique, not_null |
| `tenant_id` |  | not_null |
| `competition_type` |  | not_null, accepted_values |


---

## mart_prizekings_comps__competition_entries


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\mart_prizekings_comps__competition_entries.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__competitions`
- `dim_prizekings_comps__prizes`
- `dim_prizekings_comps__tenants`
- `fct_prizekings_comps__competition_entries`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `entry_sk` |  | unique, not_null |
| `competition_sk` |  | not_null |
| `user_id` |  | not_null |


---

## mart_prizekings_comps__promotion_completions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\mart_prizekings_comps__promotion_completions.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__promotions`
- `dim_prizekings_comps__tenants`
- `fct_prizekings_comps__user_promotions`


---

## mart_prizekings_comps__registrations


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\marts\core\mart_prizekings_comps__registrations.sql` |

### Dependencies

**Refs:**
- `dim_prizekings_comps__tenants`
- `dim_prizekings_comps__users`


---

## stg_prizekings_comps__competition


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__competition.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.competition`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `competition_sk` |  | unique, not_null |
| `competition_id` |  | unique, not_null |
| `tenant_id` |  | not_null |
| `competition_type` |  | not_null, accepted_values |
| `competition_status` |  | not_null |


---

## stg_prizekings_comps__competition_entry


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__competition_entry.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.competition_entry`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `entry_sk` |  | unique, not_null |
| `entry_id` |  | unique, not_null |
| `competition_id` |  | not_null |
| `user_id` |  | not_null |


---

## stg_prizekings_comps__competition_prize


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__competition_prize.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.competition_prize`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `prize_sk` |  | unique, not_null |
| `competition_id` |  | not_null |


---

## stg_prizekings_comps__languages


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__languages.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.languages`


---

## stg_prizekings_comps__prizes


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__prizes.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.prizes`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `prize_sk` |  | unique, not_null |
| `competition_id` |  | not_null |


---

## stg_prizekings_comps__promotion_tenants


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__promotion_tenants.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.promotion_tenants`


---

## stg_prizekings_comps__promotions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__promotions.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.promotions`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `promotion_id` |  | unique, not_null |


---

## stg_prizekings_comps__raffles


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__raffles.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.raffles`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `competition_sk` |  | unique, not_null |
| `competition_id` |  | unique, not_null |
| `tenant_id` |  | not_null |
| `competition_type` |  | not_null, accepted_values |


---

## stg_prizekings_comps__tenants


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__tenants.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.tenants`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `tenant_id` |  | unique, not_null |


---

## stg_prizekings_comps__transactions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__transactions.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.transactions`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `transaction_id` |  | unique, not_null |
| `user_id` |  | not_null |
| `transaction_direction` |  | not_null, accepted_values |
| `balance_type` |  | accepted_values |


---

## stg_prizekings_comps__translations


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__translations.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.translations`


---

## stg_prizekings_comps__user_promotions


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__user_promotions.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.user_promotions`


---

## stg_prizekings_comps__user_raffle_tickets


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__user_raffle_tickets.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.user_raffle_tickets`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `entry_sk` |  | unique, not_null |
| `entry_id` |  | unique, not_null |
| `competition_id` |  | not_null |
| `user_id` |  | not_null |


---

## stg_prizekings_comps__users


| Attribute | Value |
|-----------|-------|
| Path | `prizekings_comps\staging\stg_prizekings_comps__users.sql` |

### Dependencies

**Sources:**
- `prizekings_comps.users`

### Columns

| Column | Description | Tests |
|--------|-------------|-------|
| `user_id` |  | unique, not_null |
| `tenant_id` |  | not_null |


---

