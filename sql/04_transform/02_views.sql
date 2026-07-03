-- Phase 4: Views vs. Materialized Views
USE SCHEMA ANALYTICS;

-- Regular view: cheap to create, recomputes on every query -- good for lightly-used,
-- frequently-changing logic
CREATE OR REPLACE VIEW ANALYTICS.CUSTOMER_ORDER_SUMMARY AS
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.country,
  COUNT(o.order_id)          AS total_orders,
  SUM(o.total_amount)        AS lifetime_value
FROM STAGING.CUSTOMERS c
LEFT JOIN RAW.ORDERS o
  ON c.customer_id = o.customer_id
GROUP BY 1,2,3,4;

-- Materialized view: Snowflake maintains the result automatically and incrementally.
-- Use for expensive aggregations queried often, on data that changes moderately.
CREATE OR REPLACE MATERIALIZED VIEW ANALYTICS.DAILY_ORDER_TOTALS AS
SELECT
  order_date,
  COUNT(*)            AS order_count,
  SUM(total_amount)   AS daily_revenue
FROM RAW.ORDERS
GROUP BY order_date;

-- Decision rule of thumb (put this in your README / notes, useful in interviews):
--   Regular view   -> low query frequency, or underlying data changes constantly
--   Materialized view -> high query frequency, expensive aggregation, data changes moderately
