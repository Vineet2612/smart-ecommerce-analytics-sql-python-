"""Handles everything Python reads from or writes to MySQL."""

from __future__ import annotations

import pandas as pd
from sqlalchemy import Engine, create_engine, text

from .config import DbConfig


def get_engine(config: DbConfig | None = None) -> Engine:
    """Opens a reusable MySQL connection pool."""
    config = config or DbConfig.from_env()
    return create_engine(config.db_url(), pool_pre_ping=True)


def load_customers(engine: Engine) -> pd.DataFrame:
    """Gets active customers, including people who have not ordered yet."""
    query = """
        SELECT customer_id, customer_code, first_name, last_name, joined_at
        FROM customers
        WHERE is_active = TRUE
    """
    return pd.read_sql(query, engine, parse_dates=["joined_at"])


def load_orders(engine: Engine) -> pd.DataFrame:
    """Gets the paid, shipped, and delivered orders from the SQL view."""
    query = """
        SELECT order_id, customer_id, order_date, order_total
        FROM v_order_totals
    """
    return pd.read_sql(query, engine, parse_dates=["order_date"])


def load_purchases(engine: Engine) -> pd.DataFrame:
    """Gets the product quantities needed for recommendations."""
    query = """
        SELECT o.customer_id, c.customer_code, oi.product_id, p.product_name,
               SUM(oi.quantity) AS quantity
        FROM orders AS o
        JOIN customers AS c ON c.customer_id = o.customer_id
        JOIN order_items AS oi ON oi.order_id = o.order_id
        JOIN products AS p ON p.product_id = oi.product_id
        WHERE o.status IN ('paid', 'shipped', 'delivered')
        GROUP BY o.customer_id, c.customer_code, oi.product_id, p.product_name
    """
    return pd.read_sql(query, engine)


def save_results(
    engine: Engine, segments: pd.DataFrame, recommendations: pd.DataFrame
) -> None:
    """Replaces both result tables together so they always stay in sync."""
    segment_columns = [
        "customer_id", "recency_days", "frequency", "monetary",
        "r_score", "f_score", "m_score", "segment",
    ]
    recommendation_columns = [
        "customer_id", "product_id", "recommendation_rank", "score", "reason"
    ]

    with engine.begin() as connection:
        connection.execute(text("DELETE FROM recommendations"))
        connection.execute(text("DELETE FROM customer_segments"))
        segments[segment_columns].to_sql(
            "customer_segments", connection, if_exists="append", index=False
        )
        if not recommendations.empty:
            recommendations[recommendation_columns].to_sql(
                "recommendations", connection, if_exists="append", index=False
            )
