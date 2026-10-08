-- =========================================================
-- Snowflake Lab Setup
-- Run this initially with an administrative role.
-- =========================================================


-- ---------------------------------------------------------
-- 1. Create role
-- ---------------------------------------------------------

CREATE ROLE IF NOT EXISTS SNOWFLAKE_LAB_ROLE;


-- ---------------------------------------------------------
-- 2. Create warehouse
-- ---------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS SNOWFLAKE_LAB_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;


-- ---------------------------------------------------------
-- 3. Create database and schemas
-- ---------------------------------------------------------

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_LAB;

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_LAB.RAW;

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_LAB.ANALYTICS;


-- ---------------------------------------------------------
-- 4. Grant warehouse access
-- ---------------------------------------------------------

GRANT USAGE
ON WAREHOUSE SNOWFLAKE_LAB_WH
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT MODIFY
ON WAREHOUSE SNOWFLAKE_LAB_WH
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT OPERATE
ON WAREHOUSE SNOWFLAKE_LAB_WH
TO ROLE SNOWFLAKE_LAB_ROLE;

-- ---------------------------------------------------------
-- 5. Grant database access
-- ---------------------------------------------------------

GRANT USAGE
ON DATABASE SNOWFLAKE_LAB
TO ROLE SNOWFLAKE_LAB_ROLE;


-- ---------------------------------------------------------
-- 6. Grant schema access
-- ---------------------------------------------------------

GRANT USAGE
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT USAGE
ON SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;


-- ---------------------------------------------------------
-- 7. Allow object creation in RAW
-- ---------------------------------------------------------

GRANT CREATE TABLE
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE VIEW
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE STAGE
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE FILE FORMAT
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE STREAM
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE TASK
ON SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;


-- ---------------------------------------------------------
-- 8. Allow object creation in ANALYTICS
-- ---------------------------------------------------------

GRANT CREATE TABLE
ON SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE VIEW
ON SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE DYNAMIC TABLE
ON SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT CREATE TASK
ON SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;


-- ---------------------------------------------------------
-- 9. Create service user
-- ---------------------------------------------------------

CREATE USER IF NOT EXISTS SNOWFLAKE_LAB_SVC
    DEFAULT_ROLE = SNOWFLAKE_LAB_ROLE
    DEFAULT_WAREHOUSE = SNOWFLAKE_LAB_WH
    DEFAULT_NAMESPACE = SNOWFLAKE_LAB.RAW
    MUST_CHANGE_PASSWORD = FALSE;


-- ---------------------------------------------------------
-- 10. Assign role to service user
-- ---------------------------------------------------------

GRANT ROLE SNOWFLAKE_LAB_ROLE
TO USER SNOWFLAKE_LAB_SVC;


-- ---------------------------------------------------------
-- 11. RSA public key
-- ---------------------------------------------------------

-- Do NOT commit the real public key into GitHub.
--
-- Run this separately after generating your key pair:
--
-- ALTER USER SNOWFLAKE_LAB_SVC
-- SET RSA_PUBLIC_KEY = '<YOUR_PUBLIC_KEY_HERE>';


-- ---------------------------------------------------------
-- 12. Future grants
-- ---------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES
IN SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT SELECT
ON FUTURE TABLES
IN SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT SELECT
ON FUTURE VIEWS
IN SCHEMA SNOWFLAKE_LAB.RAW
TO ROLE SNOWFLAKE_LAB_ROLE;

GRANT SELECT
ON FUTURE VIEWS
IN SCHEMA SNOWFLAKE_LAB.ANALYTICS
TO ROLE SNOWFLAKE_LAB_ROLE;


-- ---------------------------------------------------------
-- 13. Verify setup
-- ---------------------------------------------------------

SHOW ROLES LIKE 'SNOWFLAKE_LAB_ROLE';

SHOW WAREHOUSES LIKE 'SNOWFLAKE_LAB_WH';

SHOW DATABASES LIKE 'SNOWFLAKE_LAB';

SHOW USERS LIKE 'SNOWFLAKE_LAB_SVC';