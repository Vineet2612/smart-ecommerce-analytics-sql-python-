-- Optional learning example: safely create one order and update stock together.
-- If any statement fails, the EXIT HANDLER rolls back every change.
USE smart_ecommerce;

DROP PROCEDURE IF EXISTS place_single_item_order;
DELIMITER $$
CREATE PROCEDURE place_single_item_order(
    IN p_order_number VARCHAR(20),
    IN p_customer_id INT UNSIGNED,
    IN p_product_id INT UNSIGNED,
    IN p_quantity SMALLINT UNSIGNED
)
BEGIN
    DECLARE v_price DECIMAL(12,2);
    DECLARE v_stock INT UNSIGNED;
    DECLARE v_order_id BIGINT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT unit_price, stock_quantity INTO v_price, v_stock
    FROM products
    WHERE product_id = p_product_id AND is_active = TRUE
    FOR UPDATE;

    IF v_price IS NULL OR v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product unavailable or insufficient stock';
    END IF;

    INSERT INTO orders (order_number, customer_id, status)
    VALUES (p_order_number, p_customer_id, 'pending');
    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);

    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;

    COMMIT;
END$$
DELIMITER ;

