-- Check the current warehouse
SHOW WAREHOUSES LIKE 'SNOWFLAKE_LAB_WH';


-- Resize the warehouse
ALTER WAREHOUSE SNOWFLAKE_LAB_WH
SET WAREHOUSE_SIZE = 'SMALL';


-- Change auto-suspend
ALTER WAREHOUSE SNOWFLAKE_LAB_WH
SET AUTO_SUSPEND = 120;


-- Suspend the warehouse
ALTER WAREHOUSE SNOWFLAKE_LAB_WH SUSPEND;


-- Resume the warehouse
ALTER WAREHOUSE SNOWFLAKE_LAB_WH RESUME;


-- Return it to the inexpensive lab configuration
ALTER WAREHOUSE SNOWFLAKE_LAB_WH
SET
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;


-- Inspect warehouse state/settings again
SHOW WAREHOUSES LIKE 'SNOWFLAKE_LAB_WH';