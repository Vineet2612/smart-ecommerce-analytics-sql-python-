"""Connects the database, analytics, and CSV export."""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

from .database import (
    get_engine,
    load_orders,
    load_customers,
    load_purchases,
    save_results,
)
from .recommendations import recommend_products
from .rfm import segment_customers


def run_analytics(
    as_of: str | None = None,
    top_n: int = 5,
    write_to_database: bool = True,
    report_directory: str | Path = "reports",
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Loads the data, runs both models, and exports the results."""
    engine = get_engine()
    print("1/5 Connected to MySQL.")

    customers = load_customers(engine)
    orders = load_orders(engine)
    purchases = load_purchases(engine)
    print(f"2/5 Loaded {len(customers)} customers and {len(orders)} completed orders.")

    segments = segment_customers(customers, orders, as_of=as_of)
    recommendations = recommend_products(purchases, top_n=top_n)
    print(f"3/5 Created {len(segments)} segments and {len(recommendations)} recommendations.")

    if write_to_database:
        save_results(engine, segments, recommendations)
        print("4/5 Saved both result sets to MySQL in one transaction.")
    else:
        print("4/5 Database writing skipped (--no-write).")

    output_dir = Path(report_directory)
    output_dir.mkdir(parents=True, exist_ok=True)
    segments.to_csv(output_dir / "customer_segments.csv", index=False)
    recommendations.to_csv(output_dir / "recommendations.csv", index=False)
    print(f"5/5 Wrote CSV reports to {output_dir.resolve()}.")
    return segments, recommendations


def make_parser() -> argparse.ArgumentParser:
    """Sets up the command-line options."""
    parser = argparse.ArgumentParser(description="Run e-commerce RFM and recommendations.")
    parser.add_argument(
        "--as-of",
        help="Analysis date in YYYY-MM-DD format (default: today).",
    )
    parser.add_argument(
        "--top-n", type=int, default=5,
        help="Maximum recommendations per purchasing customer (default: 5).",
    )
    parser.add_argument(
        "--no-write", action="store_true",
        help="Create CSVs without replacing result rows in MySQL.",
    )
    return parser


def main() -> None:
    """Runs the command and shows a useful message if it fails."""
    args = make_parser().parse_args()
    try:
        run_analytics(args.as_of, args.top_n, not args.no_write)
    except Exception as exc:
        raise SystemExit(f"Pipeline failed: {exc}") from exc


if __name__ == "__main__":
    main()
