"""Runs the short, read-only portfolio demo."""

from ecommerce_analytics.pipeline import run_analytics


def main() -> None:
    """Builds the reports and prints the results worth showing."""
    print("SMART E-COMMERCE ANALYTICS DEMO")
    print("\nBUSINESS QUESTIONS")
    questions = [
        "Who are our most valuable, regular, occasional, and inactive customers?",
        "How recently and frequently does each customer buy, and how much do they spend?",
        "Which customers and products deserve business attention?",
        "What products should a customer buy next?",
        "Why was each product recommended?",
    ]
    for number, question in enumerate(questions, start=1):
        print(f"{number}. {question}")

    print("\nRunning the MySQL and Python analytics pipeline...")
    segments, recommendations = run_analytics(
        as_of="2026-09-06",
        top_n=5,
        write_to_database=False,
    )

    print("\nCUSTOMER SEGMENTS")
    segment_summary = (
        segments.groupby("segment", as_index=False)
        .agg(customers=("customer_id", "count"), total_value=("monetary", "sum"))
        .sort_values("total_value", ascending=False)
    )
    print(segment_summary.to_string(index=False))

    print("\nTOP CUSTOMERS")
    top_customers = segments.nlargest(5, "monetary")[
        ["customer_code", "frequency", "monetary", "segment"]
    ]
    print(top_customers.to_string(index=False))

    print("\nRECOMMENDATIONS FOR C101")
    c101 = recommendations.loc[
        recommendations["customer_code"].eq("C101"),
        ["recommendation_rank", "product_name", "score", "reason"],
    ]
    print(c101.to_string(index=False))

    print("\nDemo complete. CSV reports are available in the reports folder.")
    print("See docs/DEMO_GUIDE.md for all business questions and result explanations.")


if __name__ == "__main__":
    main()
