# Retail Order Pipeline — Snowflake Data Engineering Project

An end-to-end Snowflake pipeline built to practice core Data Engineer skills:
warehouse/RBAC setup, staged data loading, semi-structured (JSON) data,
Snowpipe, MERGE-based upserts, Streams/Tasks for CDC + orchestration, Time
Travel, and Zero-Copy Cloning.

## Architecture

```
RAW (landing) --> STAGING (cleaned/deduped/typed) --> ANALYTICS (modeled, consumption-ready)
```

- **RAW** — untouched source data (CSV + JSON loaded via internal stage / Snowpipe)
- **STAGING** — MERGE-upserted, deduplicated tables driven by Streams + Tasks
- **ANALYTICS** — views and materialized views for reporting

## Tech covered

| Area | Concepts |
|---|---|
| Compute | Warehouses, auto-suspend/resume, sizing tradeoffs |
| Security | Custom roles, least-privilege grants (RBAC) |
| Cost control | Resource monitors |
| Loading | Internal stages, `PUT`/`COPY INTO`, file formats, `VARIANT`, `LATERAL FLATTEN` |
| Ingestion | Snowpipe (pipe + auto-ingest pattern) |
| Transformation | `MERGE` upserts, `QUALIFY` dedup, views vs. materialized views |
| CDC & orchestration | `STREAM`, `TASK`, task DAG chaining |
| Recovery | Time Travel (`AT`/`BEFORE`, `UNDROP`) |
| Environments | Zero-Copy Cloning |
| Performance | Query Profile, micro-partitions, clustering keys, warehouse-size comparison |

## Repo structure

```
sql/
  01_setup/              -- warehouses, databases/schemas, roles, resource monitor
  02_loading/             -- stages, COPY INTO, JSON/VARIANT handling
  03_snowpipe/            -- continuous ingestion pipe
  04_transform/           -- MERGE upserts, views/materialized views
  05_streams_tasks/       -- change data capture + scheduled task DAG
  06_time_travel_cloning/ -- Time Travel queries, zero-copy clone
  07_performance/         -- Query Profile / clustering / sizing notes
data/
  customers.csv
  orders.csv
  clickstream_events.json
```

## How to run

1. Create a Snowflake trial/work account.
2. Run scripts in `sql/01_setup/` in order (01 → 04) from a SnowSight worksheet.
3. Upload the files in `data/` to the stages created in `sql/02_loading/`
   (via SnowSQL `PUT` or the SnowSight "Load Data" UI), then run the `COPY INTO`
   statements.
4. Run `sql/03_snowpipe/`, `sql/04_transform/`, `sql/05_streams_tasks/`,
   `sql/06_time_travel_cloning/` in order.
5. Review `sql/07_performance/01_performance_notes.md` and try the warehouse
   sizing experiment described there.

## Notes / design decisions

- Layered RAW → STAGING → ANALYTICS schemas mirror the medallion
  (bronze/silver/gold) pattern used in most production DE pipelines.
- `MERGE` + `QUALIFY` used instead of `DELETE`+`INSERT` to keep upserts atomic
  and avoid duplicate rows from repeated loads.
- Materialized views used only for the aggregation that's queried frequently
  (`DAILY_ORDER_TOTALS`); the customer summary stays a regular view since it's
  cheap to compute and the underlying data changes often.
- Resource monitor caps spend during development so an accidental large query
  doesn't burn the trial credits.

## What I'd do next (stretch goals)

- Secure Data Share to expose `ANALYTICS` tables to a second Snowflake account
- External tables querying data directly from S3 without loading
- dbt on top of the STAGING/ANALYTICS layers instead of raw SQL scripts
