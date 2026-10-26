"""Genera embeddings mockeados para la tabla Microservicios y los guarda en SQL Server.

Requisitos:
- pyodbc
- Un driver ODBC para SQL Server instalado localmente
"""

from __future__ import annotations

import argparse
import json
import logging
import random
from typing import Iterable

import pyodbc


DEFAULT_SERVER = "localhost"
DEFAULT_DATABASE = "NexarDevPortal"
DEFAULT_USER = "sa"
DEFAULT_PASSWORD = "Telco0032"
VECTOR_DIMENSIONS = 1536


def build_connection_string(server: str, database: str, user: str, password: str) -> str:
    """Construye una cadena de conexión usando el driver ODBC más reciente disponible."""
    drivers = pyodbc.drivers()
    preferred_drivers = [
        "ODBC Driver 18 for SQL Server",
        "ODBC Driver 17 for SQL Server",
    ]

    selected_driver = next((driver for driver in preferred_drivers if driver in drivers), None)
    if selected_driver is None:
        raise RuntimeError(
            "No se encontró un driver ODBC válido para SQL Server. "
            "Instala ODBC Driver 17 o 18 para SQL Server."
        )

    return (
        f"DRIVER={{{selected_driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={user};"
        f"PWD={password};"
        "TrustServerCertificate=yes;"
    )


def generate_mock_embedding(dimensions: int, rng: random.Random) -> str:
    """Genera un embedding mockeado como texto JSON compatible con CAST(... AS VECTOR)."""
    embedding = [rng.uniform(-1.0, 1.0) for _ in range(dimensions)]
    return json.dumps(embedding, separators=(",", ":"))


def iter_microservicios(cursor: pyodbc.Cursor) -> Iterable[tuple[int, str | None]]:
    cursor.execute("SELECT ServicioID, Descripcion FROM dbo.Microservicios ORDER BY ServicioID;")
    yield from cursor.fetchall()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Rellena la columna DescripcionVector con embeddings mockeados de 1536 dimensiones."
    )
    parser.add_argument("--server", default=DEFAULT_SERVER)
    parser.add_argument("--database", default=DEFAULT_DATABASE)
    parser.add_argument("--user", default=DEFAULT_USER)
    parser.add_argument("--password", default=DEFAULT_PASSWORD)
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    connection_string = build_connection_string(args.server, args.database, args.user, args.password)
    logging.info("Conectando a %s / %s", args.server, args.database)

    updated_rows = 0
    rng = random.Random()

    with pyodbc.connect(connection_string) as connection:
        connection.autocommit = False
        with connection.cursor() as cursor:
            rows = list(iter_microservicios(cursor))
            logging.info("Se encontraron %s filas en dbo.Microservicios", len(rows))

            update_sql = (
                "UPDATE dbo.Microservicios "
                "SET DescripcionVector = CAST(CONVERT(NVARCHAR(MAX), ?) AS VECTOR(1536)) "
                "WHERE ServicioID = ?;"
            )

            for servicio_id, descripcion in rows:
                seed_source = f"{servicio_id}|{descripcion or ''}"
                rng.seed(seed_source)
                embedding_text = generate_mock_embedding(VECTOR_DIMENSIONS, rng)
                cursor.execute(update_sql, embedding_text, servicio_id)
                updated_rows += 1

            connection.commit()

    logging.info("Proceso completado. Filas actualizadas: %s", updated_rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())