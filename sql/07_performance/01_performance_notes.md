# Phase 7 — Performance & Cost Notes

## Query Profile
- In SnowSight, open **Query History**, click a query, then **Query Profile**.
- Look for: nodes with high % of total time, "bytes spilled to local/remote storage"
  (means the warehouse was too small for the data volume), and partition pruning stats.

## Micro-partitions
- Snowflake automatically splits table data into immutable ~16MB micro-partitions.
- Each partition stores min/max values per column, so the optimizer can **prune**
  partitions that can't match a filter — this is why filtering on the right column
  matters a lot.

## Clustering keys
- For very large tables where the natural load order doesn't align with common
  filter columns, define a clustering key to reduce partition scanning:

```sql
ALTER TABLE RAW.ORDERS CLUSTER BY (order_date);
```

- Only worth it on large tables (multi-GB+) with a clear, high-selectivity filter
  pattern. On a small demo table like this project's, skip it — but be ready to
  explain when you *would* use it.

## Warehouse sizing experiment
Run the same aggregation query on `DE_WH_XS` and `DE_WH_M`, compare in Query History:

```sql
USE WAREHOUSE DE_WH_XS;
SELECT customer_id, COUNT(*), SUM(total_amount)
FROM RAW.ORDERS GROUP BY customer_id;

USE WAREHOUSE DE_WH_M;
SELECT customer_id, COUNT(*), SUM(total_amount)
FROM RAW.ORDERS GROUP BY customer_id;
```

Record execution time and credits consumed for each — this is a common
interview question: "How do you decide warehouse size?"
