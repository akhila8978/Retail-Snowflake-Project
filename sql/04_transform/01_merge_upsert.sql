-- Phase 4: MERGE (upsert pattern) + QUALIFY dedup
USE SCHEMA STAGING;

CREATE OR REPLACE TABLE STAGING.CUSTOMERS (
  customer_id     STRING PRIMARY KEY,
  first_name      STRING,
  last_name       STRING,
  email           STRING,
  signup_date     DATE,
  country         STRING,
  updated_at      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Dedup raw customers first (in case of duplicate loads) using QUALIFY
CREATE OR REPLACE TEMPORARY TABLE TMP_CUSTOMERS_DEDUP AS
SELECT *
FROM RAW.CUSTOMERS
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY customer_id
  ORDER BY signup_date DESC
) = 1;

MERGE INTO STAGING.CUSTOMERS AS target
USING TMP_CUSTOMERS_DEDUP AS source
  ON target.customer_id = source.customer_id
WHEN MATCHED THEN UPDATE SET
  first_name  = source.first_name,
  last_name   = source.last_name,
  email       = source.email,
  country     = source.country,
  updated_at  = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
  customer_id, first_name, last_name, email, signup_date, country
) VALUES (
  source.customer_id, source.first_name, source.last_name,
  source.email, source.signup_date, source.country
);
