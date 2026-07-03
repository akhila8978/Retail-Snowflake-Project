-- Phase 6: Zero-Copy Cloning
-- Instantly spin up a full "dev" copy of the database with zero extra storage cost
-- until data diverges (copy-on-write).

CREATE DATABASE RETAIL_DE_PROJECT_DEV CLONE RETAIL_DE_PROJECT;

-- Verify: clone has all the same objects immediately
SHOW SCHEMAS IN DATABASE RETAIL_DE_PROJECT_DEV;

-- You can also clone a single table or schema
-- CREATE TABLE STAGING.ORDERS_DEV CLONE STAGING.ORDERS;

-- Interview talking point: storage cost only grows once you START MODIFYING
-- data in the clone -- Snowflake only stores the delta (copy-on-write micro-partitions).
