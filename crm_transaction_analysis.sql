-- CRM & Transaction Analysis Queries (MySQL)
-- No real company data is included in this file

-- Show each order with related customer, sender, receiver, and sales employee information
SELECT
  o.order_id,
  o.created_at,
  o.status,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  se.sales_employee_name,
  o.from_currency,
  o.to_currency,
  o.from_amount,
  o.to_amount,
  o.fx_rate,
  s.full_name AS sender_name,
  r.full_name AS receiver_name
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN sales_employees se ON se.sales_employee_id = o.sales_employee_id
LEFT JOIN senders s ON s.sender_id = o.sender_id
LEFT JOIN receivers r ON r.receiver_id = o.receiver_id
ORDER BY o.created_at DESC;


-- Summarise usage and volume by currency pair
SELECT
  CONCAT(o.from_currency, '->', o.to_currency) AS fx_pair,
  COUNT(*) AS order_count,
  SUM(o.from_amount) AS total_from_amount
FROM orders o
GROUP BY fx_pair
ORDER BY order_count DESC;


-- Track monthly transaction volume to identify trends over time
SELECT
  DATE_FORMAT(o.created_at, '%Y-%m') AS month,
  SUM(o.from_amount) AS total_volume
FROM orders o
GROUP BY month
ORDER BY month;


-- Group orders into size buckets based on sent amount
SELECT
  o.order_id,
  o.created_at,
  o.from_amount,
  CASE
    WHEN o.from_amount < 1000 THEN 'Small'
    WHEN o.from_amount < 10000 THEN 'Medium'
    ELSE 'Large'
  END AS amount_bucket
FROM orders o
ORDER BY o.created_at DESC;


-- Identify customers with high activity in the last 90 days
SELECT
  o.customer_id,
  COUNT(*) AS orders_last_90_days,
  SUM(o.from_amount) AS total_from_amount_last_90_days
FROM orders o
WHERE o.created_at >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY o.customer_id
HAVING COUNT(*) >= 5
ORDER BY total_from_amount_last_90_days DESC;


-- Find customers in the CRM who have not yet made any orders
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.created_at AS customer_created_at
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.created_at DESC;


-- Summarise performance of sales department employees by volume and customers handled
SELECT
  se.sales_employee_name,
  COUNT(o.order_id) AS order_count,
  COUNT(DISTINCT o.customer_id) AS unique_customers,
  SUM(o.from_amount) AS total_from_amount
FROM sales_employees se
LEFT JOIN orders o ON o.sales_employee_id = se.sales_employee_id
GROUP BY se.sales_employee_name
ORDER BY total_from_amount DESC;
