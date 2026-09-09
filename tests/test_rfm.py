import pandas as pd

from ecommerce_analytics.rfm import segment_customers


def test_rfm_handles_nonbuyers():
    customers = pd.DataFrame(
        {
            "customer_id": [1, 2, 3, 4],
            "customer_code": ["C101", "C102", "C103", "C104"],
            "joined_at": pd.to_datetime(
                ["2025-01-01", "2025-01-01", "2025-01-01", "2025-12-01"]
            ),
        }
    )
    orders = pd.DataFrame(
        {
            "order_id": [1, 2, 3, 4, 5, 6],
            "customer_id": [1, 1, 1, 2, 2, 3],
            "order_date": pd.to_datetime(
                ["2026-01-25", "2026-01-27", "2026-01-30", "2026-01-10", "2026-01-20", "2025-08-01"]
            ),
            "order_total": [5000, 7000, 9000, 1000, 1500, 500],
        }
    )

    result = segment_customers(customers, orders, as_of="2026-02-01", inactive_days=90)
    by_code = result.set_index("customer_code")

    assert len(result) == 4
    assert by_code.loc["C101", "recency_days"] == 2
    assert by_code.loc["C101", "frequency"] == 3
    assert by_code.loc["C101", "monetary"] == 21000
    assert by_code.loc["C103", "segment"] == "Inactive"
    assert by_code.loc["C104", "segment"] == "Inactive"


def test_rfm_needs_customers():
    empty_customers = pd.DataFrame(columns=["customer_id", "customer_code", "joined_at"])
    empty_orders = pd.DataFrame(columns=["order_id", "customer_id", "order_date", "order_total"])

    try:
        segment_customers(empty_customers, empty_orders)
    except ValueError as exc:
        assert "Customer data is empty" in str(exc)
    else:
        raise AssertionError("Expected ValueError for empty customers")
