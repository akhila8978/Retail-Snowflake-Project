-- Phase 3: Snowpipe (auto-ingest)
-- Note: full auto-ingest requires an external stage (S3 + SNS) or Azure/GCS equivalent.
-- If you don't have cloud storage handy, use the "manual refresh" version below to
-- still demonstrate the Snowpipe concept without needing S3 event notifications.

USE SCHEMA RAW;

CREATE OR REPLACE PIPE ORDERS_PIPE
  AUTO_INGEST = FALSE  -- set TRUE + configure cloud notifications for full auto-ingest
AS
  COPY INTO RAW.ORDERS
  FROM @RAW_STAGE
  FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT)
  PATTERN = '.*orders.*[.]csv';

-- Manually trigger a pipe refresh (simulates new file arrival)
ALTER PIPE ORDERS_PIPE REFRESH;

-- Check pipe status / load history
SELECT SYSTEM$PIPE_STATUS('ORDERS_PIPE');

SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'RAW.ORDERS',
  START_TIME => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
));
