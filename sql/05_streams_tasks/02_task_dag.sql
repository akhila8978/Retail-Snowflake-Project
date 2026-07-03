-- Phase 5: Tasks (scheduled/triggered orchestration) chained into a DAG
USE SCHEMA STAGING;

-- Root task: runs every 5 minutes, only if the stream has data (SYSTEM$STREAM_HAS_DATA)
CREATE OR REPLACE TASK STAGING.MERGE_ORDERS_TASK
  WAREHOUSE = DE_WH_XS
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('RAW.ORDERS_STREAM')
AS
  MERGE INTO STAGING.ORDERS AS target
  USING RAW.ORDERS_STREAM AS source
    ON target.order_id = source.order_id
  WHEN MATCHED AND source.METADATA$ACTION = 'INSERT' AND source.METADATA$ISUPDATE THEN
    UPDATE SET
      status = source.status,
      total_amount = source.total_amount
  WHEN NOT MATCHED AND source.METADATA$ACTION = 'INSERT' THEN
    INSERT (order_id, customer_id, order_date, status, total_amount)
    VALUES (source.order_id, source.customer_id, source.order_date,
            source.status, source.total_amount);

-- Child task: refreshes the analytics summary after the merge completes (DAG chaining)
CREATE OR REPLACE TASK STAGING.REFRESH_SUMMARY_TASK
  WAREHOUSE = DE_WH_XS
  AFTER STAGING.MERGE_ORDERS_TASK
AS
  ALTER MATERIALIZED VIEW ANALYTICS.DAILY_ORDER_TOTALS SUSPEND;
  -- (placeholder statement for a follow-up refresh/notification action)

-- Tasks are created SUSPENDED by default -- must be explicitly resumed
ALTER TASK STAGING.REFRESH_SUMMARY_TASK RESUME;
ALTER TASK STAGING.MERGE_ORDERS_TASK RESUME;

-- Inspect the DAG and run history
SHOW TASKS IN SCHEMA STAGING;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY SCHEDULED_TIME DESC
LIMIT 20;
