"""Suggests products based on what similar customers bought."""

from __future__ import annotations

import numpy as np
import pandas as pd


OUTPUT_COLUMNS = [
    "customer_id", "customer_code", "product_id", "product_name",
    "recommendation_rank", "score", "reason",
]


def recommend_products(purchases: pd.DataFrame, top_n: int = 5) -> pd.DataFrame:
    """Suggests new products bought by customers with similar purchase history.

    Quantity becomes a simple yes/no value because owning the product matters
    more here than buying one or two. Cosine similarity measures how much two
    customers overlap without favoring people who bought more products.
    """
    if top_n < 1:
        raise ValueError("top_n must be at least 1.")
    if purchases.empty:
        return pd.DataFrame(columns=OUTPUT_COLUMNS)

    required = {"customer_id", "customer_code", "product_id", "product_name", "quantity"}
    missing = required.difference(purchases.columns)
    if missing:
        raise ValueError(f"Purchase data is missing columns: {sorted(missing)}")

    matrix = purchases.pivot_table(
        index="customer_id", columns="product_id", values="quantity",
        aggfunc="sum", fill_value=0,
    )
    binary = (matrix > 0).astype(float)
    values = binary.to_numpy()
    norms = np.linalg.norm(values, axis=1)
    denominator = np.outer(norms, norms)
    similarities = np.divide(
        values @ values.T,
        denominator,
        out=np.zeros_like(denominator, dtype=float),
        where=denominator != 0,
    )
    np.fill_diagonal(similarities, 0.0)

    customer_codes = purchases.drop_duplicates("customer_id").set_index("customer_id")["customer_code"]
    product_names = purchases.drop_duplicates("product_id").set_index("product_id")["product_name"]
    results: list[dict] = []

    for row_index, customer_id in enumerate(binary.index):
        similarity_row = similarities[row_index]
        raw_scores = similarity_row @ values
        owned = values[row_index] > 0
        raw_scores[owned] = 0.0

        candidate_positions = np.flatnonzero(raw_scores > 0)
        ordered_positions = sorted(
            candidate_positions,
            key=lambda position: (-raw_scores[position], int(binary.columns[position])),
        )[:top_n]

        for rank, position in enumerate(ordered_positions, start=1):
            product_id = int(binary.columns[position])
            contributors = np.flatnonzero((values[:, position] > 0) & (similarity_row > 0))
            best_contributor = max(contributors, key=lambda i: similarity_row[i])
            similar_customer_id = int(binary.index[best_contributor])
            similar_code = str(customer_codes.loc[similar_customer_id])
            results.append(
                {
                    "customer_id": int(customer_id),
                    "customer_code": str(customer_codes.loc[customer_id]),
                    "product_id": product_id,
                    "product_name": str(product_names.loc[product_id]),
                    "recommendation_rank": rank,
                    "score": round(float(raw_scores[position]), 6),
                    "reason": (
                        f"Customer {similar_code}, who bought similar products, also bought "
                        f"{product_names.loc[product_id]}."
                    ),
                }
            )

    return pd.DataFrame(results, columns=OUTPUT_COLUMNS)
