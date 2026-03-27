---
name: data-low6-dbt-azureuksouth
description: >-
  Query the low6_dbt_azureuksouth analytics data (0 report tables, 0 source tables).
  Use when querying analytics data, building reports or dashboards, understanding available metrics,
  or contributing to the dbt project. Data from .
---

# low6_dbt_azureuksouth Data Project

## Overview

| Attribute | Value |
|-----------|-------|
| Database | BigQuery project `N/A` |
| Report tables | 0 (in `marts` schema) |
| Source systems | 0 () |
| Total models | 101 across 5 layers |

## Available Data


## Quick Reference

| Table | Grain | What it answers |
|-------|-------|-----------------|

## Architecture

```mermaid
graph LR

  layer_core_user_service["core_user_service - 3 models"]
  layer_itv_spinoff["itv_spinoff - 32 models"]
  layer_low6_reporting["low6_reporting - 2 models"]
  layer_pivot_bracket["pivot_bracket - 25 models"]
  layer_prizekings_comps["prizekings_comps - 39 models"]


  layer_core_user_service --> layer_itv_spinoff
  layer_prizekings_comps --> layer_low6_reporting
```

## Navigation

### For querying data and building reports


### For contributing to the dbt project

- **core_user_service layer**: read [ref/core_user_service.md](ref/core_user_service.md)
- **itv_spinoff layer**: read [ref/itv_spinoff.md](ref/itv_spinoff.md)
- **low6_reporting layer**: read [ref/low6_reporting.md](ref/low6_reporting.md)
- **pivot_bracket layer**: read [ref/pivot_bracket.md](ref/pivot_bracket.md)
- **prizekings_comps layer**: read [ref/prizekings_comps.md](ref/prizekings_comps.md)
- **Source systems**: read [ref/sources.md](ref/sources.md)
- **SQL macros**: read [ref/macros.md](ref/macros.md)
- **Dependency graph**: read [ref/lineage.md](ref/lineage.md)

### Project variables

| Variable | Value |
|----------|-------|
| `prizekings_start_date` | `2026-02-11` |
| `local_timezone` | `Europe/London` |
