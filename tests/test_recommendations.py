import pandas as pd

from ecommerce_analytics.recommendations import recommend_products


def purchase_row(customer_id, code, product_id, name):
    return {
        "customer_id": customer_id,
        "customer_code": code,
        "product_id": product_id,
        "product_name": name,
        "quantity": 1,
    }


def test_recommendations_skip_owned():
    purchases = pd.DataFrame(
        [
            purchase_row(1, "C101", 1, "Laptop"),
            purchase_row(1, "C101", 2, "Mouse"),
            purchase_row(1, "C101", 3, "Keyboard"),
            purchase_row(2, "C102", 1, "Laptop"),
            purchase_row(2, "C102", 2, "Mouse"),
            purchase_row(2, "C102", 4, "Webcam"),
            purchase_row(2, "C102", 5, "USB Hub"),
            purchase_row(3, "C103", 1, "Laptop"),
            purchase_row(3, "C103", 3, "Keyboard"),
            purchase_row(3, "C103", 4, "Webcam"),
        ]
    )

    result = recommend_products(purchases, top_n=3)
    c101 = result[result["customer_code"] == "C101"]

    assert c101.iloc[0]["product_name"] == "Webcam"
    assert {1, 2, 3}.isdisjoint(set(c101["product_id"]))
    assert c101["recommendation_rank"].tolist() == list(range(1, len(c101) + 1))
    assert c101["reason"].str.contains("similar products").all()


def test_empty_recommendations():
    result = recommend_products(pd.DataFrame(), top_n=5)
    assert result.empty
    assert "reason" in result.columns
