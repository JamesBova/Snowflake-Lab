CREATE OR REPLACE TABLE SNOWFLAKE_LAB.RAW.EVENTS (
    EVENT_ID NUMBER,
    PAYLOAD VARIANT
);

INSERT INTO SNOWFLAKE_LAB.RAW.EVENTS (EVENT_ID, PAYLOAD)
SELECT
    column1,
    PARSE_JSON(column2)
FROM VALUES
(
    1,
    '{
        "customer_id": 101,
        "event_type": "purchase",
        "amount": 125.50,
        "items": ["book", "charger"]
    }'
),
(
    2,
    '{
        "customer_id": 102,
        "event_type": "login",
        "device": "mobile",
        "items": []
    }'
);

SELECT
    EVENT_ID,
    PAYLOAD:customer_id::NUMBER AS CUSTOMER_ID,
    PAYLOAD:event_type::VARCHAR AS EVENT_TYPE,
    PAYLOAD:amount::NUMBER(10,2) AS AMOUNT
FROM SNOWFLAKE_LAB.RAW.EVENTS;

SELECT
    EVENT_ID,
    item.value::VARCHAR AS ITEM
FROM SNOWFLAKE_LAB.RAW.EVENTS,
LATERAL FLATTEN(INPUT => PAYLOAD:items) item;