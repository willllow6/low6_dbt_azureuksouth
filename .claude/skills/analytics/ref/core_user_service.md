# core_user_service (internal dbt models)


> These are internal dbt models used to build the mart tables. For querying data, see the mart reference files.

**3 models** | Materialization: 

## core_user_service__referrals


| Attribute | Value |
|-----------|-------|
| Path | `core_user_service\marts\core_user_service__referrals.sql` |

### Dependencies

**Refs:**
- `stg_core_user_service__referrals`
- `stg_core_user_service__users`


---

## stg_core_user_service__referrals


| Attribute | Value |
|-----------|-------|
| Path | `core_user_service\staging\stg_core_user_service__referrals.sql` |

### Dependencies

**Sources:**
- `core_user_service.referrals`


---

## stg_core_user_service__users


| Attribute | Value |
|-----------|-------|
| Path | `core_user_service\staging\stg_core_user_service__users.sql` |

### Dependencies

**Sources:**
- `core_user_service.users`


---

