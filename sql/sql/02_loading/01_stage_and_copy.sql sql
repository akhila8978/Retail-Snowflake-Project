-- Phase 2: Internal stage + CSV loading
USE ROLE DE_ENGINEER;
USE DATABASE RETAIL_DE_PROJECT;
USE SCHEMA RAW;
USE WAREHOUSE DE_WH_XS;

-- Create a file format for CSV
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('NULL', 'null', '');

-- Create an internal stage
CREATE OR REPLACE STAGE RAW_STAGE
  FILE_FORMAT = CSV_FORMAT;

-- From SnowSQL CLI (not the web worksheet), upload local files:
--   PUT file:///path/to/customers.csv @RAW_STAGE;
--   PUT file:///path/to/orders.csv @RAW_STAGE;
-- In SnowSight web UI, use the "Load Data" button on the RAW schema instead of PUT.

-- Target tables
CREATE OR REPLACE TABLE RAW.CUSTOMERS (
  customer_id     STRING,
  first_name      STRING,
  last_name       STRING,
  email           STRING,
  signup_date     DATE,
  country         STRING
);

CREATE OR REPLACE TABLE RAW.ORDERS (
  order_id        STRING,
  customer_id     STRING,
  order_date      DATE,
  status          STRING,
  total_amount    NUMBER(10,2)
);

-- Load from stage into tables
COPY INTO RAW.CUSTOMERS
  FROM @RAW_STAGE/customers.csv
  FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT)
  ON_ERROR = 'CONTINUE';

COPY INTO RAW.ORDERS
  FROM @RAW_STAGE/orders.csv
  FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT)
  ON_ERROR = 'CONTINUE';

-- Check for load errors
SELECT * FROM TABLE(VALIDATE(RAW.ORDERS, JOB_ID => '_last'));
