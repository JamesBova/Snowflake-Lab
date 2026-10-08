from pathlib import Path
import sys

from database import get_connection


def run_sql_file(file_path):
    sql = Path(file_path).read_text(encoding="utf-8")

    statements = [
        statement.strip()
        for statement in sql.split(";")
        if statement.strip()
    ]

    with get_connection() as connection:
        with connection.cursor() as cursor:

            for statement in statements:
                print(f"\nRunning:")
                print(statement)

                cursor.execute(statement)

                if cursor.description:
                    columns = [column[0] for column in cursor.description]
                    rows = cursor.fetchall()

                    print(columns)

                    for row in rows:
                        print(row)

    print(f"\nExecuted: {file_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python src/run_sql.py <sql_file>")
        sys.exit(1)

    run_sql_file(sys.argv[1])