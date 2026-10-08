from pathlib import Path

from database import get_connection


BASE_DIR = Path(__file__).parent.parent

SETUP_SQL_FILE = BASE_DIR / "sql" / "03_loading_setup.sql"
COPY_SQL_FILE = BASE_DIR / "sql" / "03_loading_copy.sql"
DATA_FILE = BASE_DIR / "data" / "customers.csv"


def read_sql(file_path):
    return file_path.read_text(encoding="utf-8")


setup_sql = read_sql(SETUP_SQL_FILE)
copy_sql = read_sql(COPY_SQL_FILE)


with get_connection() as connection:
    with connection.cursor() as cursor:

        # Create table, file format, and stage
        for statement in setup_sql.split(";"):
            statement = statement.strip()

            if statement:
                cursor.execute(statement)

        print("Loading setup complete.")

        # Upload local CSV to Snowflake internal stage
        put_sql = f"""
            PUT 'file://{DATA_FILE.as_posix()}'
            @SNOWFLAKE_LAB.RAW.CUSTOMER_STAGE
            AUTO_COMPRESS = TRUE
            OVERWRITE = TRUE
        """

        cursor.execute(put_sql)

        print("\nPUT results:")
        for row in cursor.fetchall():
            print(row)

        # Copy staged data into target table
        cursor.execute(copy_sql)

        print("\nCOPY INTO results:")
        for row in cursor.fetchall():
            print(row)

print("\nData load complete.")