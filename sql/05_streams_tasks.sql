-- =========================================================
-- Streams and Tasks Demo
-- =========================================================


-- ---------------------------------------------------------
-- 1. Create source table
-- ---------------------------------------------------------

CREATE OR REPLACE TABLE SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES (
    CUSTOMER_ID NUMBER,
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR,
    EMAIL VARCHAR
);


-- ---------------------------------------------------------
-- 2. Create stream on source table
-- ---------------------------------------------------------

CREATE OR REPLACE STREAM SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES_STREAM
ON TABLE SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES;


-- ---------------------------------------------------------
-- 3. Insert records into source table
-- ---------------------------------------------------------

INSERT INTO SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES
VALUES
    (1, 'Alice', 'Smith', 'alice@example.com'),
    (2, 'Bob', 'Jones', 'bob@example.com');


-- ---------------------------------------------------------
-- 4. Inspect stream
-- These rows have not yet been consumed.
-- ---------------------------------------------------------

SELECT *
FROM SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES_STREAM;


-- ---------------------------------------------------------
-- 5. Create target table
-- ---------------------------------------------------------

CREATE OR REPLACE TABLE SNOWFLAKE_LAB.ANALYTICS.CUSTOMER_CHANGES_PROCESSED (
    CUSTOMER_ID NUMBER,
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR,
    EMAIL VARCHAR
);


-- ---------------------------------------------------------
-- 6. Create task to consume stream
-- Task checks once per minute, but only runs when the
-- stream contains data.
-- ---------------------------------------------------------

CREATE OR REPLACE TASK SNOWFLAKE_LAB.RAW.PROCESS_CUSTOMER_CHANGES
    WAREHOUSE = SNOWFLAKE_LAB_WH
    SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA(
    'SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES_STREAM'
)
AS
INSERT INTO SNOWFLAKE_LAB.ANALYTICS.CUSTOMER_CHANGES_PROCESSED
SELECT
    CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL
FROM SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES_STREAM
WHERE METADATA$ACTION = 'INSERT';


-- ---------------------------------------------------------
-- 7. Inspect task before enabling it
-- ---------------------------------------------------------

SHOW TASKS LIKE 'PROCESS_CUSTOMER_CHANGES'
IN SCHEMA SNOWFLAKE_LAB.RAW;


-- ---------------------------------------------------------
-- 8. Enable task
-- Newly created tasks are suspended by default.
-- ---------------------------------------------------------

ALTER TASK SNOWFLAKE_LAB.RAW.PROCESS_CUSTOMER_CHANGES RESUME;


-- ---------------------------------------------------------
-- After the task has run, these queries can be used
-- to verify the results.
-- ---------------------------------------------------------

-- The rows should eventually appear here:
--
-- SELECT *
-- FROM SNOWFLAKE_LAB.ANALYTICS.CUSTOMER_CHANGES_PROCESSED;


-- The stream should be empty after successful consumption:
--
-- SELECT *
-- FROM SNOWFLAKE_LAB.RAW.CUSTOMER_CHANGES_STREAM;


-- ---------------------------------------------------------
-- Disable task when finished with the demo
-- ---------------------------------------------------------

-- ALTER TASK SNOWFLAKE_LAB.RAW.PROCESS_CUSTOMER_CHANGES SUSPEND;