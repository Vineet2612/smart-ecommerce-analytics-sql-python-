-- Phase 4 and 5: queries that answer the business questions.
USE smart_ecommerce;
SET @inactive_days = 90;
SET @target_customer_code = 'C101';

-- 1. Top 10 customers. The view prevents repeating order-total logic.
SELECT *
FROM v_customer_metrics
ORDER BY total_spent DESC, order_count DESC
LIMIT 10;

-- 2. Inactive customers, including customers who have never ordered.
SELECT customer_code, customer_name, most_recent_order,
       CASE
           WHEN most_recent_order IS NULL THEN 'Never purchased'
           ELSE CONCAT(DATEDIFF(CURDATE(), DATE(most_recent_order)), ' days ago')
       END AS inactivity
FROM v_customer_metrics
WHERE most_recent_order IS NULL
   OR most_recent_order < CURDATE() - INTERVAL 90 DAY
ORDER BY most_recent_order;

-- 3. One-time versus repeat customers (CASE and LEFT JOIN are inside the view).
SELECT customer_code, customer_name, order_count,
       CASE
           WHEN order_count = 0 THEN 'Prospect'
           WHEN order_count = 1 THEN 'One-time'
           ELSE 'Repeat'
       END AS customer_type
FROM v_customer_metrics
ORDER BY order_count DESC;

-- 4. Average observed customer lifetime value (purchasing customers only).
SELECT ROUND(AVG(total_spent), 2) AS average_customer_lifetime_value
FROM v_customer_metrics
WHERE order_count > 0;

-- 5. Customers at risk: their last purchase was 60-90 days ago.
SELECT customer_code, customer_name, total_spent, most_recent_order,
       DATEDIFF(CURDATE(), DATE(most_recent_order)) AS days_since_purchase
FROM v_customer_metrics
WHERE most_recent_order >= CURDATE() - INTERVAL 90 DAY
  AND most_recent_order < CURDATE() - INTERVAL 60 DAY
ORDER BY total_spent DESC;

-- Customer metrics plus most frequently purchased category.
WITH category_counts AS (
    SELECT o.customer_id, c.category_name, SUM(oi.quantity) AS units,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id
               ORDER BY SUM(oi.quantity) DESC, c.category_name
           ) AS category_rank
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories c ON c.category_id = p.category_id
    WHERE o.status IN ('paid', 'shipped', 'delivered')
    GROUP BY o.customer_id, c.category_id, c.category_name
)
SELECT m.*, cc.category_name AS favorite_category
FROM v_customer_metrics m
LEFT JOIN category_counts cc
  ON cc.customer_id = m.customer_id AND cc.category_rank = 1
ORDER BY m.total_spent DESC;

-- High-value customers: above-average spending AND above-average frequency.
SELECT customer_code, customer_name, order_count, total_spent
FROM v_customer_metrics
WHERE total_spent > (SELECT AVG(total_spent) FROM v_customer_metrics WHERE order_count > 0)
  AND order_count > (SELECT AVG(order_count) FROM v_customer_metrics WHERE order_count > 0)
ORDER BY total_spent DESC;

-- 6. Best-selling and most profitable products.
SELECT product_code, product_name, units_sold, revenue, gross_profit
FROM v_product_performance
ORDER BY units_sold DESC, revenue DESC;

-- 7. Category revenue and profit.
SELECT category_name, SUM(units_sold) AS units_sold,
       ROUND(SUM(revenue), 2) AS revenue,
       ROUND(SUM(gross_profit), 2) AS gross_profit
FROM v_product_performance
GROUP BY category_name
HAVING revenue > 0
ORDER BY revenue DESC;

-- 8. Products bought together. The self-join creates each pair once.
SELECT p1.product_name AS product_a, p2.product_name AS product_b,
       COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2
  ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN orders o ON o.order_id = oi1.order_id
JOIN products p1 ON p1.product_id = oi1.product_id
JOIN products p2 ON p2.product_id = oi2.product_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY p1.product_id, p1.product_name, p2.product_id, p2.product_name
HAVING COUNT(DISTINCT oi1.order_id) >= 1
ORDER BY times_bought_together DESC, product_a, product_b;

-- 9. Products losing sales: latest complete month versus prior month in data.
WITH month_sales AS (
    SELECT oi.product_id, DATE_FORMAT(o.order_date, '%Y-%m-01') AS sales_month,
           SUM(oi.quantity) AS units
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status IN ('paid', 'shipped', 'delivered')
    GROUP BY oi.product_id, DATE_FORMAT(o.order_date, '%Y-%m-01')
),
latest_month AS (
    SELECT MAX(sales_month) AS month_start FROM month_sales
),
comparison AS (
    SELECT p.product_id, p.product_name,
           COALESCE(SUM(CASE WHEN ms.sales_month = lm.month_start THEN ms.units END), 0) AS latest_units,
           COALESCE(SUM(CASE WHEN ms.sales_month = DATE_FORMAT(DATE_SUB(lm.month_start, INTERVAL 1 MONTH), '%Y-%m-01') THEN ms.units END), 0) AS previous_units
    FROM products p
    CROSS JOIN latest_month lm
    LEFT JOIN month_sales ms ON ms.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT *, latest_units - previous_units AS unit_change
FROM comparison
WHERE latest_units < previous_units
ORDER BY unit_change;

-- High views but low purchases (conversion attention list).
WITH views AS (
    SELECT product_id, COUNT(*) AS view_count
    FROM product_views GROUP BY product_id
), purchases AS (
    SELECT oi.product_id, SUM(oi.quantity) AS purchase_count
    FROM order_items oi JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status IN ('paid', 'shipped', 'delivered')
    GROUP BY oi.product_id
)
SELECT p.product_code, p.product_name, v.view_count,
       COALESCE(pc.purchase_count, 0) AS purchase_count,
       ROUND(100 * COALESCE(pc.purchase_count, 0) / v.view_count, 2) AS view_to_purchase_percent
FROM views v
JOIN products p ON p.product_id = v.product_id
LEFT JOIN purchases pc ON pc.product_id = v.product_id
WHERE v.view_count >= 3
ORDER BY view_to_purchase_percent, view_count DESC;

-- 10 and 11. Recommendations for C101, including the explanation.
SELECT c.customer_code, p.product_code, p.product_name,
       r.recommendation_rank, r.score, r.reason
FROM recommendations r
JOIN customers c ON c.customer_id = r.customer_id
JOIN products p ON p.product_id = r.product_id
WHERE c.customer_code = @target_customer_code
ORDER BY r.recommendation_rank;

-- 12. How many customers received each product recommendation?
SELECT p.product_code, p.product_name,
       COUNT(DISTINCT r.customer_id) AS interested_customers,
       ROUND(AVG(r.score), 4) AS average_score
FROM recommendations r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_code, p.product_name
ORDER BY interested_customers DESC, average_score DESC;

