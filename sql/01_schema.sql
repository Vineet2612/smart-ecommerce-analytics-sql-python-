-- Phase 1 and 2: database design and table creation.
-- This project owns the smart_ecommerce database. Tables are dropped so that
-- setup.sql always produces the same demonstration data on every run.

CREATE DATABASE IF NOT EXISTS smart_ecommerce
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE smart_ecommerce;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS recommendations;
DROP TABLE IF EXISTS customer_segments;
DROP TABLE IF EXISTS product_views;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE customers (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(10) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;

CREATE TABLE categories (
    category_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500)
) ENGINE = InnoDB;

CREATE TABLE products (
    product_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL UNIQUE,
    category_id SMALLINT UNSIGNED NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    description VARCHAR(500),
    unit_price DECIMAL(12,2) NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_product_price CHECK (unit_price >= 0),
    CONSTRAINT chk_product_cost CHECK (unit_cost >= 0),
    CONSTRAINT chk_price_above_cost CHECK (unit_price >= unit_cost),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE orders (
    order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) NOT NULL UNIQUE,
    customer_id INT UNSIGNED NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded')
        NOT NULL DEFAULT 'pending',
    shipping_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_shipping_nonnegative CHECK (shipping_amount >= 0),
    CONSTRAINT chk_discount_nonnegative CHECK (discount_amount >= 0),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE order_items (
    order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity SMALLINT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0),
    CONSTRAINT chk_item_discount CHECK (discount_amount >= 0),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE payments (
    payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('card', 'upi', 'net_banking', 'wallet', 'cash_on_delivery') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(100) UNIQUE,
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE reviews (
    review_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    rating TINYINT UNSIGNED NOT NULL,
    review_text VARCHAR(1000),
    reviewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_product_review UNIQUE (customer_id, product_id),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE = InnoDB;

CREATE TABLE product_views (
    view_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NULL,
    product_id INT UNSIGNED NOT NULL,
    viewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    session_id VARCHAR(64) NOT NULL,
    CONSTRAINT fk_views_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_views_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE = InnoDB;

CREATE TABLE customer_segments (
    customer_id INT UNSIGNED PRIMARY KEY,
    recency_days INT UNSIGNED NOT NULL,
    frequency INT UNSIGNED NOT NULL,
    monetary DECIMAL(14,2) NOT NULL,
    r_score TINYINT UNSIGNED NOT NULL,
    f_score TINYINT UNSIGNED NOT NULL,
    m_score TINYINT UNSIGNED NOT NULL,
    segment ENUM('VIP', 'Regular', 'Occasional', 'Inactive') NOT NULL,
    calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_r_score CHECK (r_score BETWEEN 1 AND 4),
    CONSTRAINT chk_f_score CHECK (f_score BETWEEN 1 AND 4),
    CONSTRAINT chk_m_score CHECK (m_score BETWEEN 1 AND 4),
    CONSTRAINT fk_segments_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE recommendations (
    customer_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    recommendation_rank TINYINT UNSIGNED NOT NULL,
    score DECIMAL(12,6) NOT NULL,
    reason VARCHAR(500) NOT NULL,
    generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, product_id),
    CONSTRAINT uq_customer_recommendation_rank UNIQUE (customer_id, recommendation_rank),
    CONSTRAINT chk_recommendation_rank CHECK (recommendation_rank > 0),
    CONSTRAINT chk_recommendation_score CHECK (score >= 0),
    CONSTRAINT fk_recommendations_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_recommendations_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_status_date ON orders(status, order_date);
CREATE INDEX idx_items_product_order ON order_items(product_id, order_id);
CREATE INDEX idx_products_category_active ON products(category_id, is_active);
CREATE INDEX idx_views_product_date ON product_views(product_id, viewed_at);

