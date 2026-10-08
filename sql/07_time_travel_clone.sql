-- =========================================================
-- Time Travel and Zero-Copy Cloning Demo
-- =========================================================


-- ---------------------------------------------------------
-- 1. Create demo table
-- ---------------------------------------------------------

CREATE OR REPLACE TABLE SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO (
    ID NUMBER,
    NAME VARCHAR
);


-- ---------------------------------------------------------
-- 2. Insert initial data
-- ---------------------------------------------------------

INSERT INTO SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO
VALUES
    (1, 'Alice'),
    (2, 'Bob');


-- Current table state
SELECT *
FROM SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO;


-- ---------------------------------------------------------
-- 3. Modify current data
-- ---------------------------------------------------------

UPDATE SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO
SET NAME = 'Robert'
WHERE ID = 2;


-- Current state now shows Robert
SELECT *
FROM SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO;


-- ---------------------------------------------------------
-- 4. Time Travel using an offset
-- ---------------------------------------------------------

-- Returns the table as it existed 60 seconds ago.
-- This requires the table to have existed at that point.

SELECT *
FROM SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO
AT (OFFSET => -60);


-- ---------------------------------------------------------
-- 5. Time Travel using a timestamp
-- ---------------------------------------------------------

-- Replace the timestamp below with a valid point in the
-- table's Time Travel retention window.

SELECT *
FROM SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO
AT (
    TIMESTAMP => '2026-10-07 14:44:00 -05:00'::TIMESTAMP_TZ
);


-- ---------------------------------------------------------
-- 6. Query recent statement history
-- ---------------------------------------------------------

-- Useful for finding the QUERY_ID of an UPDATE, DELETE,
-- or other statement to use with BEFORE (STATEMENT => ...).

SELECT
    QUERY_ID,
    QUERY_TEXT,
    START_TIME,
    EXECUTION_STATUS
FROM TABLE(
    SNOWFLAKE_LAB.INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION(
        RESULT_LIMIT => 100
    )
)
ORDER BY START_TIME DESC;


-- ---------------------------------------------------------
-- 7. Time Travel using a statement ID
-- ---------------------------------------------------------

-- Replace the query ID below with a valid statement ID
-- returned from QUERY_HISTORY_BY_SESSION.

SELECT *
FROM SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO
BEFORE (
    STATEMENT => '<QUERY_ID>'
);


-- ---------------------------------------------------------
-- 8. Create a zero-copy clone
-- ---------------------------------------------------------

CREATE OR REPLACE TABLE SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO_CLONE
CLONE SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO;


-- Verify cloned data
SELECT *
FROM SNOWFLAKE_LAB.RAW.TIME_TRAVEL_DEMO_CLONE;