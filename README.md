# Snowflake Lab

A hands-on Snowflake project covering core data engineering concepts, including loading, semi-structured data, streams/tasks, Time Travel, cloning, security, and performance tuning.

## What This Project Covers

- Snowflake databases, schemas, tables, and virtual warehouses
- Compute vs storage separation
- Role-based access control and RSA key-pair authentication
- Internal stages, file formats, `PUT`, and `COPY INTO`
- `VARIANT`, JSON, and `FLATTEN`
- Streams and tasks for incremental processing
- Dynamic tables
- Time Travel
- Zero-copy cloning
- Micro-partition pruning
- Clustering and performance analysis

## Project Structure

    Snowflake-Lab/
    ├── sql/
    │   ├── 01_setup.sql
    │   ├── 02_warehouses.sql
    │   ├── 03_loading_setup.sql
    │   ├── 03_loading_copy.sql
    │   ├── 04_semi_structured.sql
    │   ├── 05_streams_tasks.sql
    │   ├── 06_dynamic_tables.sql
    │   ├── 07_time_travel_clone.sql
    │   ├── 08_security.sql
    │   └── 09_performance.sql
    │
    └── src/
        ├── database.py
        ├── run_sql.py
        └── load_data.py

## Data Loading Example

The project demonstrates a basic Snowflake loading pipeline:

    Local CSV
    → Internal Stage
    → COPY INTO
    → Snowflake Table

Python is used to upload local data and execute the load.

## Semi-Structured Data

Snowflake `VARIANT` columns are used to store JSON data.

The project demonstrates:

    PARSE_JSON
    JSON path access
    LATERAL FLATTEN

## Incremental Processing

A Snowflake stream tracks table changes, while a task can process those changes automatically.

    Source Table
    → Stream
    → Task
    → Analytics Table

## Time Travel and Cloning

The project demonstrates querying historical table states using Time Travel and creating zero-copy clones for fast, storage-efficient copies.

## Performance Lab

A 5-million-row test table was used to demonstrate micro-partition pruning and clustering.

Before organizing the data:

    Partitions scanned: 2 of 2
    Bytes assigned:     22.8 MB

After organizing and clustering by `TRANSACTION_DATE`:

    Partitions scanned: 1 of 4
    Bytes assigned:     14.3 MB

For the same date filter, Snowflake was able to prune 75% of the available micro-partitions.

## Technologies

- Snowflake
- Python
- Snowflake Python Connector
- SQL
- RSA key-pair authentication
- Git

## Running the Project

Install dependencies:

    pip install -r requirements.txt

Run a SQL lab file:

    python src\run_sql.py sql\02_warehouses.sql

Run the loading demo:

    python src\load_data.py

Connection values are stored in `.env`. The RSA private key is stored outside the repository.

## Key Takeaway

This project demonstrates how Snowflake differs from traditional database platforms through separated compute and storage, scalable ingestion, semi-structured data support, Snowflake-native incremental processing, historical recovery, cloning, and micro-partition-based performance optimization.