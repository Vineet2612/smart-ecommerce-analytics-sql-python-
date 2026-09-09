"""Groups customers using rfm(recency, frequency, and spending)."""

from __future__ import annotations

import numpy as np
import pandas as pd


def _score_quartiles(series: pd.Series, higher_is_better: bool = True) -> pd.Series:
    """Splits values into scores from 1 (low) to 4 (high)."""
    percentile = series.rank(method="average", pct=True)
    score = np.ceil(percentile * 4).clip(1, 4).astype(int)
    return score if higher_is_better else 5 - score


def segment_customers(
    customers: pd.DataFrame,
    orders: pd.DataFrame,
    as_of: pd.Timestamp | str | None = None,
    inactive_days: int = 90,
) -> pd.DataFrame:
    """Calculates each customer's RFM numbers and assigns a segment."""
    if customers.empty:
        raise ValueError("Customer data is empty; RFM segmentation cannot run.")

    analysis_date = pd.Timestamp(as_of or pd.Timestamp.now()).normalize()
    customer_base = customers[["customer_id", "customer_code", "joined_at"]].copy()
    customer_base["joined_at"] = pd.to_datetime(customer_base["joined_at"])

    if orders.empty:
        metrics = pd.DataFrame(columns=["customer_id", "last_order", "frequency", "monetary"])
    else:
        clean_orders = orders.copy()
        clean_orders["order_date"] = pd.to_datetime(clean_orders["order_date"])
        clean_orders["order_total"] = pd.to_numeric(clean_orders["order_total"])
        metrics = clean_orders.groupby("customer_id", as_index=False).agg(
            last_order=("order_date", "max"),
            frequency=("order_id", "nunique"),
            monetary=("order_total", "sum"),
        )

    rfm = customer_base.merge(metrics, on="customer_id", how="left")
    rfm["frequency"] = rfm["frequency"].fillna(0).astype(int)
    rfm["monetary"] = rfm["monetary"].fillna(0.0).astype(float).round(2)

    # No purchase date yet, so use the date the customer joined.
    reference_date = rfm["last_order"].fillna(rfm["joined_at"])
    rfm["recency_days"] = (analysis_date - reference_date.dt.normalize()).dt.days.clip(lower=0)

    rfm["r_score"] = _score_quartiles(rfm["recency_days"], higher_is_better=False)
    rfm["f_score"] = _score_quartiles(rfm["frequency"], higher_is_better=True)
    rfm["m_score"] = _score_quartiles(rfm["monetary"], higher_is_better=True)

    is_inactive = (rfm["frequency"] == 0) | (rfm["recency_days"] > inactive_days)
    is_vip = (
        (rfm["r_score"] >= 3)
        & (rfm["f_score"] >= 3)
        & (rfm["m_score"] >= 3)
    )
    is_regular = (rfm[["r_score", "f_score", "m_score"]].sum(axis=1) >= 7) & (
        rfm["frequency"] >= 2
    )
    rfm["segment"] = np.select(
        [is_inactive, is_vip, is_regular],
        ["Inactive", "VIP", "Regular"],
        default="Occasional",
    )

    return rfm[
        ["customer_id", "customer_code", "recency_days", "frequency", "monetary",
         "r_score", "f_score", "m_score", "segment"]
    ].sort_values(["segment", "monetary"], ascending=[True, False]).reset_index(drop=True)
