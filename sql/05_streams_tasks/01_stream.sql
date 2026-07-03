-- Phase 5: Streams (change data capture)
USE SCHEMA RAW;

CREATE OR REPLACE STREAM ORDERS_STREAM ON TABLE RAW.ORDERS;

-- Test it: insert/update a row in RAW.ORDERS, then check the stream
-- INSERT INTO RAW.ORDERS VALUES ('O9999','C001', CURRENT_DATE(), 'PLACED', 42.50);

SELECT * FROM ORDERS_STREAM;
-- METADATA$ACTION shows INSERT/DELETE, METADATA$ISUPDATE flags updates (delete+insert pair)
