--- Databases & layered schemas (RAW -> STAGING -> ANALYTICS):

CREATE DATABASE IF NOT EXISTS RETAIL_DE_PROJECT;

USE DATABASE RETAIL_DE_PROJECT;

CREATE SCHEMA IF NOT EXISTS RAW;        -- landing zone, untouched source data
CREATE SCHEMA IF NOT EXISTS STAGING;    -- cleaned, deduped, typed
CREATE SCHEMA IF NOT EXISTS ANALYTICS;  -- final modeled tables/views for consumption
