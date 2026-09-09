# Commands for Every Business Question

The password is read from `.env`; these commands do not prompt for it.

## See the numbered question list

```powershell
.\questions.bat list
```

## Answer every question

```powershell
.\questions.bat all
```

## Answer one question

Use the question number shown by the list command. For example:

```powershell
.\questions.bat 1
.\questions.bat 4
.\questions.bat 14
```

| Number | Question |
|---:|---|
| 1 | What and how often does each customer buy? |
| 2 | Who are the top 10 customers by spending? |
| 3 | Who is a prospect, one-time buyer, or repeat customer? |
| 4 | Which customers are inactive? |
| 5 | Which customers are at risk? |
| 6 | What is the average observed customer lifetime value? |
| 7 | What is each customer's favorite category? |
| 8 | Who are the high-value customers? |
| 9 | Which products sell the most and generate the most profit? |
| 10 | Which categories generate the most revenue and profit? |
| 11 | Which products are purchased together? |
| 12 | Which products are losing sales? |
| 13 | Which products have high views but poor conversion? |
| 14 | What should `C101` buy next, and why? |
| 15 | How many customers may want each recommended product? |
| 16 | Which customers belong to each RFM segment? |

All question commands are read-only: they query the existing MySQL database without changing its tables.

## What the CSV files contain

### `reports/customer_segments.csv`

There is one row per customer. Its columns show:

- customer ID and code;
- days since the customer's latest valid order;
- number of valid orders;
- total historical spending;
- recency, frequency, and monetary scores from 1 to 4;
- final segment: `VIP`, `Regular`, `Occasional`, or `Inactive`.

### `reports/recommendations.csv`

There is one row per customer-product recommendation. Its columns show:

- customer ID and code;
- recommended product ID and name;
- recommendation rank;
- similarity-based recommendation score;
- a readable explanation naming a similar customer who bought that product.

The CSV files are refreshed by `.\demo.bat`. They make it easy to open, filter, chart, or share the results in Excel without querying MySQL.

**Note** : To run your own SQL query, add it to questions.py by following the same format as the existing questions, then use the commands above to execute it.