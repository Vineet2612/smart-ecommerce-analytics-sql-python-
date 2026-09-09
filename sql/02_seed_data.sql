-- Phase 3:Dataset (Currency:Indian rupee).here we insert data into structure table we prepared in schema.sql file
USE smart_ecommerce;

INSERT INTO categories (category_id, category_name, description) VALUES
(1, 'Computers', 'Computers, monitors and computer accessories'),
(2, 'Mobile', 'Phones and mobile accessories'),
(3, 'Home & Kitchen', 'Useful products for the home'),
(4, 'Fitness', 'Sports and fitness products'),
(5, 'Books', 'Printed books'),
(6, 'Wearables', 'Smart wearable devices');

INSERT INTO products
(product_id, product_code, category_id, product_name, description, unit_price, unit_cost, stock_quantity) VALUES
(1, 'P001', 1, 'ProBook Laptop', '15-inch productivity laptop', 65000, 52000, 24),
(2, 'P002', 1, 'Wireless Mouse', 'Ergonomic wireless mouse', 1200, 650, 150),
(3, 'P003', 1, 'Mechanical Keyboard', 'Backlit mechanical keyboard', 2500, 1500, 85),
(4, 'P004', 1, 'HD Webcam', '1080p USB webcam', 3200, 2000, 62),
(5, 'P005', 1, 'USB-C Hub', 'Seven-port USB-C hub', 1800, 950, 110),
(6, 'P006', 1, '24-inch Monitor', 'Full-HD IPS monitor', 14500, 11000, 40),
(7, 'P007', 1, 'Noise-Cancelling Headphones', 'Over-ear Bluetooth headphones', 4500, 2800, 72),
(8, 'P008', 2, 'Nova Smartphone', '5G smartphone with 128 GB storage', 35000, 28000, 35),
(9, 'P009', 2, 'Fast Charger', '65 W USB-C charger', 1500, 800, 130),
(10, 'P010', 3, 'Coffee Maker', 'Programmable drip coffee maker', 3800, 2400, 44),
(11, 'P011', 4, 'Running Shoes', 'Cushioned daily running shoes', 3500, 2100, 90),
(12, 'P012', 4, 'Yoga Mat', 'Non-slip exercise mat', 1200, 500, 105),
(13, 'P013', 3, 'Everyday Backpack', 'Water-resistant laptop backpack', 2200, 1200, 78),
(14, 'P014', 5, 'Data Analytics Handbook', 'Practical introduction to analytics', 700, 250, 200),
(15, 'P015', 3, 'Ergonomic Desk Chair', 'Adjustable mesh office chair', 9500, 6800, 20),
(16, 'P016', 6, 'Active Smartwatch', 'Fitness and notification smartwatch', 8500, 5900, 48);

INSERT INTO customers
(customer_id, customer_code, first_name, last_name, email, phone, city, state, joined_at) VALUES
(1, 'C101', 'Aarav', 'Sharma', 'aarav@example.com', '9000000101', 'Delhi', 'Delhi', '2025-06-15 10:00:00'),
(2, 'C102', 'Diya', 'Patel', 'diya@example.com', '9000000102', 'Ahmedabad', 'Gujarat', '2025-07-20 11:00:00'),
(3, 'C103', 'Kabir', 'Singh', 'kabir@example.com', '9000000103', 'Chandigarh', 'Chandigarh', '2025-08-12 12:00:00'),
(4, 'C104', 'Meera', 'Nair', 'meera@example.com', '9000000104', 'Kochi', 'Kerala', '2025-09-02 09:30:00'),
(5, 'C105', 'Vihaan', 'Rao', 'vihaan@example.com', '9000000105', 'Hyderabad', 'Telangana', '2025-10-18 15:00:00'),
(6, 'C106', 'Ananya', 'Iyer', 'ananya@example.com', '9000000106', 'Chennai', 'Tamil Nadu', '2025-11-09 16:10:00'),
(7, 'C107', 'Arjun', 'Verma', 'arjun@example.com', '9000000107', 'Lucknow', 'Uttar Pradesh', '2025-12-01 12:45:00'),
(8, 'C108', 'Ishita', 'Gupta', 'ishita@example.com', '9000000108', 'Jaipur', 'Rajasthan', '2026-01-11 10:25:00'),
(9, 'C109', 'Reyansh', 'Joshi', 'reyansh@example.com', '9000000109', 'Pune', 'Maharashtra', '2026-02-02 14:00:00'),
(10, 'C110', 'Saanvi', 'Das', 'saanvi@example.com', '9000000110', 'Kolkata', 'West Bengal', '2026-02-25 13:30:00'),
(11, 'C111', 'Aditya', 'Kumar', 'aditya@example.com', '9000000111', 'Patna', 'Bihar', '2026-03-08 17:00:00'),
(12, 'C112', 'Myra', 'Kapoor', 'myra@example.com', '9000000112', 'Mumbai', 'Maharashtra', '2026-04-04 10:15:00'),
(13, 'C113', 'Rohan', 'Bose', 'rohan@example.com', '9000000113', 'Bengaluru', 'Karnataka', '2026-08-01 09:00:00');

INSERT INTO orders
(order_id, order_number, customer_id, order_date, status, shipping_amount, discount_amount) VALUES
(1, 'ORD-1001', 1, '2026-02-10 10:10:00', 'delivered', 0, 0),
(2, 'ORD-1002', 1, '2026-06-18 14:20:00', 'delivered', 0, 0),
(3, 'ORD-1003', 1, '2026-08-25 09:40:00', 'delivered', 0, 0),
(4, 'ORD-1004', 2, '2026-01-14 11:30:00', 'delivered', 0, 0),
(5, 'ORD-1005', 2, '2026-03-02 16:00:00', 'delivered', 0, 0),
(6, 'ORD-1006', 2, '2026-05-09 12:15:00', 'delivered', 0, 0),
(7, 'ORD-1007', 2, '2026-07-22 18:20:00', 'delivered', 0, 0),
(8, 'ORD-1008', 2, '2026-09-01 10:05:00', 'shipped', 0, 0),
(9, 'ORD-1009', 3, '2026-02-22 13:20:00', 'delivered', 0, 0),
(10, 'ORD-1010', 3, '2026-05-21 17:30:00', 'delivered', 0, 0),
(11, 'ORD-1011', 3, '2026-08-14 08:50:00', 'delivered', 0, 0),
(12, 'ORD-1012', 4, '2026-01-28 15:00:00', 'delivered', 0, 0),
(13, 'ORD-1013', 4, '2026-04-16 12:00:00', 'delivered', 0, 0),
(14, 'ORD-1014', 4, '2026-08-29 10:00:00', 'paid', 0, 0),
(15, 'ORD-1015', 5, '2026-01-05 09:00:00', 'delivered', 0, 0),
(16, 'ORD-1016', 5, '2026-02-05 09:30:00', 'delivered', 0, 0),
(17, 'ORD-1017', 6, '2026-04-08 14:00:00', 'delivered', 0, 0),
(18, 'ORD-1018', 6, '2026-08-20 19:10:00', 'delivered', 0, 0),
(19, 'ORD-1019', 7, '2025-12-20 12:00:00', 'delivered', 0, 0),
(20, 'ORD-1020', 8, '2026-03-11 10:30:00', 'delivered', 0, 0),
(21, 'ORD-1021', 9, '2026-07-10 17:00:00', 'delivered', 0, 0),
(22, 'ORD-1022', 9, '2026-08-12 17:20:00', 'delivered', 0, 0),
(23, 'ORD-1023', 10, '2026-05-14 12:30:00', 'delivered', 0, 0),
(24, 'ORD-1024', 11, '2026-08-31 09:20:00', 'delivered', 0, 0),
(25, 'ORD-1025', 12, '2026-09-03 16:40:00', 'paid', 0, 0),
(26, 'ORD-1026', 3, '2026-09-04 13:10:00', 'cancelled', 0, 0);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_amount) VALUES
(1, 1, 1, 65000, 0), (1, 2, 1, 1200, 0),
(2, 3, 1, 2500, 0), (2, 7, 1, 4500, 0),
(3, 13, 1, 2200, 0), (3, 14, 1, 700, 0),
(4, 1, 1, 65000, 0), (4, 2, 1, 1200, 0),
(5, 4, 1, 3200, 0), (5, 5, 1, 1800, 0),
(6, 6, 1, 14500, 0), (6, 3, 1, 2500, 0),
(7, 7, 1, 4500, 0), (7, 13, 1, 2200, 0),
(8, 14, 1, 700, 0),
(9, 1, 1, 65000, 0), (9, 3, 1, 2500, 0),
(10, 4, 1, 3200, 0), (10, 6, 1, 14500, 0),
(11, 5, 1, 1800, 0), (11, 7, 1, 4500, 0),
(12, 8, 1, 35000, 0), (12, 9, 1, 1500, 0),
(13, 16, 1, 8500, 0), (13, 9, 1, 1500, 0),
(14, 7, 1, 4500, 0),
(15, 10, 1, 3800, 0), (15, 14, 1, 700, 0),
(16, 15, 1, 9500, 0),
(17, 11, 1, 3500, 0), (17, 12, 1, 1200, 0),
(18, 16, 1, 8500, 0), (18, 12, 1, 1200, 0),
(19, 14, 2, 700, 0),
(20, 10, 1, 3800, 0), (20, 13, 1, 2200, 0),
(21, 11, 1, 3500, 0), (21, 12, 1, 1200, 0),
(22, 16, 1, 8500, 0),
(23, 8, 1, 35000, 0), (23, 9, 1, 1500, 0),
(24, 2, 1, 1200, 0), (24, 3, 1, 2500, 0),
(25, 10, 1, 3800, 0),
(26, 1, 1, 65000, 0);

-- The amount is calculated from the order items, preventing copy/paste mismatches.
INSERT INTO payments (order_id, payment_date, amount, payment_method, payment_status, transaction_reference)
SELECT
    o.order_id,
    o.order_date,
    ROUND(SUM(oi.quantity * oi.unit_price - oi.discount_amount), 2),
    CASE MOD(o.order_id, 4)
        WHEN 0 THEN 'card'
        WHEN 1 THEN 'upi'
        WHEN 2 THEN 'net_banking'
        ELSE 'wallet'
    END,
    CASE WHEN o.status = 'cancelled' THEN 'failed' ELSE 'completed' END,
    CONCAT('TXN-', LPAD(o.order_id, 6, '0'))
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.status;

INSERT INTO reviews (customer_id, product_id, rating, review_text, reviewed_at) VALUES
(1, 1, 5, 'Fast and reliable for daily work.', '2026-02-18 10:00:00'),
(1, 3, 4, 'Comfortable keyboard with good feedback.', '2026-06-25 10:00:00'),
(2, 4, 4, 'Clear image in video meetings.', '2026-03-10 10:00:00'),
(3, 6, 5, 'Excellent display for the price.', '2026-06-01 10:00:00'),
(4, 8, 4, 'Good battery life.', '2026-02-08 10:00:00'),
(6, 11, 5, 'Comfortable on long runs.', '2026-04-20 10:00:00');

INSERT INTO product_views (customer_id, product_id, viewed_at, session_id) VALUES
(1, 4, '2026-08-20 09:00:00', 'S001'), (1, 5, '2026-08-20 09:05:00', 'S001'),
(1, 6, '2026-08-20 09:10:00', 'S001'), (1, 6, '2026-08-21 09:10:00', 'S002'),
(2, 6, '2026-08-01 10:00:00', 'S003'), (2, 6, '2026-08-02 10:00:00', 'S004'),
(3, 6, '2026-08-03 10:00:00', 'S005'), (4, 6, '2026-08-04 10:00:00', 'S006'),
(5, 6, '2026-08-05 10:00:00', 'S007'), (6, 6, '2026-08-06 10:00:00', 'S008'),
(7, 6, '2026-08-07 10:00:00', 'S009'), (8, 6, '2026-08-08 10:00:00', 'S010'),
(9, 6, '2026-08-09 10:00:00', 'S011'), (10, 6, '2026-08-10 10:00:00', 'S012'),
(11, 6, '2026-08-11 10:00:00', 'S013'), (12, 6, '2026-08-12 10:00:00', 'S014'),
(1, 4, '2026-08-22 11:00:00', 'S015'), (2, 4, '2026-08-22 11:00:00', 'S016'),
(4, 16, '2026-08-23 11:00:00', 'S017'), (5, 16, '2026-08-23 11:00:00', 'S018'),
(8, 16, '2026-08-23 11:00:00', 'S019'), (10, 15, '2026-08-24 11:00:00', 'S020'),
(11, 15, '2026-08-24 11:00:00', 'S021'), (12, 15, '2026-08-24 11:00:00', 'S022'),
(NULL, 15, '2026-08-25 11:00:00', 'S023'), (NULL, 15, '2026-08-25 11:05:00', 'S024');

