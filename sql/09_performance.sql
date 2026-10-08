-- =========================================================
-- Snowflake Performance / Micro-Partition Pruning Demo
-- =========================================================

-- Disable cached query results so repeated tests are easier
-- to compare during the lab.
ALTER SESSION SET USE_CACHED_RESULT = FALSE;


-- ---------------------------------------------------------
-- 1. Create a larger table with randomly distributed dates
-- ---------------------------------------------------------

CREATE OR REPLACE TABLE SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST AS
SELECT
    SEQ4() AS ID,

    DATEADD(
        DAY,
        UNIFORM(0, 730, RANDOM()),
        '2024-01-01'::DATE
    ) AS TRANSACTION_DATE,

    UNIFORM(1, 100000, RANDOM()) AS CUSTOMER_ID,

    UNIFORM(1, 500, RANDOM()) AS AMOUNT

FROM TABLE(
    GENERATOR(ROWCOUNT => 5000000)
);


-- ---------------------------------------------------------
-- 2. Baseline pruning test
-- ---------------------------------------------------------

EXPLAIN
SELECT *
FROM SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST
WHERE TRANSACTION_DATE = '2025-01-15';


-- Observed result from one test run:
--
-- partitionsTotal    = 2
-- partitionsAssigned = 2
-- bytesAssigned      = 22,797,312
--
-- Result:
-- Snowflake had to scan 2 of 2 available micro-partitions.
-- No partition pruning was possible for this filter.


-- ---------------------------------------------------------
-- 3. Inspect clustering characteristics
-- ---------------------------------------------------------

SELECT SYSTEM$CLUSTERING_INFORMATION(
    'SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST',
    '(TRANSACTION_DATE)'
);


-- Observed result:
--
-- total_partition_count = 2
-- average_overlaps      = 1.0
-- average_depth         = 2.0


-- ---------------------------------------------------------
-- 4. Create a version organized by transaction date
-- ---------------------------------------------------------

CREATE OR REPLACE TABLE SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST_CLUSTERED AS
SELECT *
FROM SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST
ORDER BY TRANSACTION_DATE;


-- Define transaction date as the clustering key.
ALTER TABLE SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST_CLUSTERED
CLUSTER BY (TRANSACTION_DATE);


-- ---------------------------------------------------------
-- 5. Run the same pruning test
-- ---------------------------------------------------------

EXPLAIN
SELECT *
FROM SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST_CLUSTERED
WHERE TRANSACTION_DATE = '2025-01-15';


-- Observed result from one test run:
--
-- partitionsTotal    = 4
-- partitionsAssigned = 1
-- bytesAssigned      = 14,280,192
--
-- Result:
-- Snowflake only needed to scan 1 of 4 available
-- micro-partitions.
--
-- 75% of the available partitions were pruned.


-- ---------------------------------------------------------
-- 6. Inspect clustering characteristics
-- ---------------------------------------------------------

SELECT SYSTEM$CLUSTERING_INFORMATION(
    'SNOWFLAKE_LAB.RAW.PERFORMANCE_TEST_CLUSTERED',
    '(TRANSACTION_DATE)'
);


-- ---------------------------------------------------------
-- 7. Comparison
-- ---------------------------------------------------------

-- BEFORE:
--
-- 2 total partitions
-- 2 partitions scanned
-- 100% of partitions scanned
-- 22.8 MB assigned
--
-- AFTER:
--
-- 4 total partitions
-- 1 partition scanned
-- 25% of partitions scanned
-- 14.3 MB assigned
--
-- The clustered/organized version allowed Snowflake to
-- eliminate 75% of the available micro-partitions for the
-- same date filter.
--
-- This demonstrates micro-partition pruning:
--
-- Better organization of filtered columns
--      ↓
-- Snowflake can use partition metadata
--      ↓
-- Irrelevant partitions are skipped
--      ↓
-- Less data is scanned


-- ---------------------------------------------------------
-- 8. Review recent query activity
-- ---------------------------------------------------------

SELECT
    QUERY_ID,
    QUERY_TEXT,
    TOTAL_ELAPSED_TIME,
    BYTES_SCANNED,
    ROWS_PRODUCED
FROM TABLE(
    SNOWFLAKE_LAB.INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION(
        RESULT_LIMIT => 50
    )
)
ORDER BY START_TIME DESC;