-- Phase 6: Time Travel
USE SCHEMA RAW;

-- Query data as of a past point in time
SELECT * FROM RAW.ORDERS AT (OFFSET => -60*5); -- 5 minutes ago

-- Query data before a specific statement (useful for undoing an accidental change)
-- SELECT * FROM RAW.ORDERS BEFORE (STATEMENT => '<query_id>');

-- Restore an accidentally dropped table (works within retention window)
-- DROP TABLE RAW.ORDERS;
-- UNDROP TABLE RAW.ORDERS;

-- Check retention setting for a table
SHOW TABLES LIKE 'ORDERS' IN SCHEMA RAW;
