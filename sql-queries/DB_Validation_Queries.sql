-- ============================================================
-- E-Commerce Web Application – Database Validation Queries
-- Tester: Alok Thokale
-- Purpose: Backend data validation using SQL
-- ============================================================

-- ─────────────────────────────────────────
-- 1. USER REGISTRATION VALIDATION
-- ─────────────────────────────────────────

-- Verify new user was inserted correctly
SELECT user_id, full_name, email, mobile, created_at
FROM users
WHERE email = 'testuser@example.com';

-- Check no duplicate emails exist
SELECT email, COUNT(*) AS count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Verify password is stored (should not be plain text)
SELECT email, password
FROM users
WHERE email = 'testuser@example.com';


-- ─────────────────────────────────────────
-- 2. PRODUCT SEARCH VALIDATION
-- ─────────────────────────────────────────

-- Verify product exists in DB
SELECT product_id, product_name, category, price, stock_qty
FROM products
WHERE product_name LIKE '%laptop%';

-- Check products with zero stock are not shown in search
SELECT product_id, product_name, stock_qty
FROM products
WHERE stock_qty = 0;

-- Validate product price matches what is displayed on UI
SELECT product_id, product_name, price, discount_price
FROM products
WHERE product_id = 101;


-- ─────────────────────────────────────────
-- 3. CART VALIDATION
-- ─────────────────────────────────────────

-- Verify item added to cart is saved in DB
SELECT c.cart_id, u.email, p.product_name, c.quantity, c.added_at
FROM cart c
JOIN users u ON c.user_id = u.user_id
JOIN products p ON c.product_id = p.product_id
WHERE u.email = 'testuser@example.com';

-- Check cart total matches sum of items
SELECT 
    SUM(p.discount_price * c.quantity) AS expected_total
FROM cart c
JOIN products p ON c.product_id = p.product_id
WHERE c.user_id = 5;


-- ─────────────────────────────────────────
-- 4. ORDER PLACEMENT VALIDATION
-- ─────────────────────────────────────────

-- Verify order is created after checkout
SELECT order_id, user_id, total_amount, order_status, order_date
FROM orders
WHERE user_id = 5
ORDER BY order_date DESC
LIMIT 1;

-- Verify order items are stored correctly
SELECT oi.order_id, p.product_name, oi.quantity, oi.unit_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.order_id = 1023;

-- Check stock is reduced after order
SELECT product_id, product_name, stock_qty
FROM products
WHERE product_id = 101;


-- ─────────────────────────────────────────
-- 5. PAYMENT VALIDATION
-- ─────────────────────────────────────────

-- Verify payment record is created
SELECT payment_id, order_id, amount, payment_method, payment_status, paid_at
FROM payments
WHERE order_id = 1023;

-- Cross-check payment amount matches order total
SELECT o.order_id, o.total_amount, p.amount AS paid_amount
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_id = 1023;


-- ─────────────────────────────────────────
-- 6. PROFILE UPDATE VALIDATION
-- ─────────────────────────────────────────

-- Verify profile changes are saved
SELECT user_id, full_name, email, mobile, address
FROM users
WHERE user_id = 5;


-- ─────────────────────────────────────────
-- 7. DEFECT-RELATED VALIDATION QUERIES
-- ─────────────────────────────────────────

-- BUG-003: Verify cart quantity cannot exceed stock
SELECT c.quantity, p.stock_qty
FROM cart c
JOIN products p ON c.product_id = p.product_id
WHERE c.cart_id = 45;

-- BUG-007: Verify cancelled order status updated in DB
SELECT order_id, order_status
FROM orders
WHERE order_id = 1023;

-- BUG-011: Verify coupon is applied correctly
SELECT order_id, coupon_code, discount_amount, total_amount
FROM orders
WHERE order_id = 1024;
