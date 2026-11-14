"""Upgrade skema aditif & idempotent untuk database yang sudah berjalan.

create_all() hanya membuat tabel baru, tidak menambah kolom pada tabel lama.
Modul ini menambah kolom baru (nullable) tanpa menyentuh data lama.
"""
from sqlalchemy import text
from sqlalchemy.engine import Engine

from app.core.config import settings

# (tabel, kolom, tipe SQL) — semua nullable agar data lama tetap valid.
_COLUMN_UPGRADES = [
    ("products", "options", "TEXT"),
    ("transaction_items", "variant_label", "TEXT"),
]


def ensure_schema_upgrades(engine: Engine) -> None:
    if not settings.DATABASE_URL.startswith("sqlite"):
        return
    with engine.begin() as conn:
        for table, column, col_type in _COLUMN_UPGRADES:
            cols = {row[1] for row in conn.execute(text(f"PRAGMA table_info({table})"))}
            if column not in cols:
                conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {column} {col_type}"))
                print(f"Schema upgrade: kolom {table}.{column} ditambahkan")
