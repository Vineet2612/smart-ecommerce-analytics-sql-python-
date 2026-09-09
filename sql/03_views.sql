USE smart_ecommerce;

-- One reliable calculation for order value, reused by customer analytics.
CREATE OR REPLACE VIEW v_order_totals AS
SELECT
    o.order_id,
    o.order_number,
    o.customer_id,
    o.order_date,
    o.status,
    ROUND(SUM(oi.quantity * oi.unit_price - oi.discount_amount)
          + o.shipping_amount - o.discount_amount, 2) AS order_total
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY o.order_id, o.order_number, o.customer_id, o.order_date, o.status,
         o.shipping_amount, o.discount_amount;

CREATE OR REPLACE VIEW v_customer_metrics AS
SELECT
    c.customer_id,
    c.customer_code,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(vot.order_id) AS order_count,
    COALESCE(ROUND(SUM(vot.order_total), 2), 0) AS total_spent,
    COALESCE(ROUND(AVG(vot.order_total), 2), 0) AS average_order_value,
    MAX(vot.order_date) AS most_recent_order
FROM customers AS c
LEFT JOIN v_order_totals AS vot ON vot.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_code, c.first_name, c.last_name;

CREATE OR REPLACE VIEW v_product_performance AS
SELECT
    p.product_id,
    p.product_code,
    p.product_name,
    c.category_name,
    COALESCE(SUM(CASE WHEN o.status IN ('paid', 'shipped', 'delivered') THEN oi.quantity ELSE 0 END), 0) AS units_sold,
    COALESCE(ROUND(SUM(CASE WHEN o.status IN ('paid', 'shipped', 'delivered')
        THEN oi.quantity * oi.unit_price - oi.discount_amount ELSE 0 END), 2), 0) AS revenue,
    COALESCE(ROUND(SUM(CASE WHEN o.status IN ('paid', 'shipped', 'delivered')
        THEN oi.quantity * (oi.unit_price - p.unit_cost) - oi.discount_amount ELSE 0 END), 2), 0) AS gross_profit
FROM products AS p
JOIN categories AS c ON c.category_id = p.category_id
LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
LEFT JOIN orders AS o ON o.order_id = oi.order_id
GROUP BY p.product_id, p.product_code, p.product_name, c.category_name;

