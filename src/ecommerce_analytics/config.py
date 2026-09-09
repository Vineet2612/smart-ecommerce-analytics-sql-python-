"""Loads the database settings from `.env`."""

from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv
from sqlalchemy import URL


@dataclass(frozen=True)
class DbConfig:
    """Keeps the MySQL connection details in one place."""

    host: str
    port: int
    database: str
    user: str
    password: str

    @classmethod
    def from_env(cls) -> "DbConfig":
        """Reads `.env` and checks that the required username is there."""
        load_dotenv()
        values = {
            "host": os.getenv("DB_HOST", "localhost"),
            "port": int(os.getenv("DB_PORT", "3306")),
            "database": os.getenv("DB_NAME", "smart_ecommerce"),
            "user": os.getenv("DB_USER", ""),
            "password": os.getenv("DB_PASSWORD", ""),
        }
        if not values["user"]:
            raise ValueError("DB_USER is missing. Copy .env.example to .env and fill it in.")
        return cls(**values)

    def db_url(self) -> URL:
        """Builds a safe SQLAlchemy URL, even with special characters."""
        return URL.create(
            drivername="mysql+pymysql",
            username=self.user,
            password=self.password,
            host=self.host,
            port=self.port,
            database=self.database,
            query={"charset": "utf8mb4"},
        )
