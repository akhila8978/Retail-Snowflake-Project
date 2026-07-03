-- Phase 2: Semi-structured data (JSON -> VARIANT -> flatten)
USE SCHEMA RAW;

CREATE OR REPLACE FILE FORMAT JSON_FORMAT
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

CREATE OR REPLACE STAGE RAW_JSON_STAGE
  FILE_FORMAT = JSON_FORMAT;

-- Upload clickstream_events.json to @RAW_JSON_STAGE via SnowSQL PUT or SnowSight UI

CREATE OR REPLACE TABLE RAW.CLICKSTREAM_EVENTS (
  raw_event VARIANT
);

COPY INTO RAW.CLICKSTREAM_EVENTS
  FROM @RAW_JSON_STAGE/clickstream_events.json
  FILE_FORMAT = (FORMAT_NAME = JSON_FORMAT)
  ON_ERROR = 'CONTINUE';

-- Example flatten: assume each event looks like
-- { "event_id": "...", "customer_id": "...", "event_type": "page_view",
--   "event_ts": "...", "properties": { "page": "/home", "referrer": "google" } }

SELECT
  raw_event:event_id::STRING       AS event_id,
  raw_event:customer_id::STRING    AS customer_id,
  raw_event:event_type::STRING     AS event_type,
  raw_event:event_ts::TIMESTAMP    AS event_ts,
  raw_event:properties:page::STRING AS page,
  f.value::STRING                  AS tag
FROM RAW.CLICKSTREAM_EVENTS,
  LATERAL FLATTEN(input => raw_event:tags) f;
