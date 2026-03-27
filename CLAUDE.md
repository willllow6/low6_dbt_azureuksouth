# low6_dbt_azureuksouth

Snowflake region: Azure UK South. Shared conventions are in `~/.claude/CLAUDE.md`.

## Stack
- dbt Core
- Snowflake
- Conda env: dbt311
- dbt executable: /c/Users/WillBreeden/anaconda3/envs/dbt311/Scripts/dbt

## Project Structure
- models/{domain}/staging/ — raw source cleaning, prefixed stg_
- models/{domain}/intermediates/ — business logic, prefixed int_
- models/{domain}/marts/ — final consumption layer

## Domains
- core_user_service
- itv_spinoff
- low6_reporting
- pivot_bracket
- prizekings_comps

## Project Variables
- `local_timezone: 'Europe/London'`
- `prizekings_start_date` — start date filter for prizekings_comps models
