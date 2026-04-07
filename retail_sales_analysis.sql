-- Retail Sales & Customer Insights SQL Portfolio Project
-- Database: SQLite

-- 1. Executive KPI snapshot
SELECT
    ROUND(SUM(oi.sales_amount), 2) AS total_sales,
    ROUND(SUM(oi.profit_amount), 2) AS total_profit,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.profit_amount) / SUM(oi.sales_amount), 4) AS profit_margin,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id;

-- 2. Monthly sales and profit trend
SELECT
    strftime('%Y-%m', o.order_date) AS order_month,
    ROUND(SUM(oi.sales_amount), 2) AS monthly_sales,
    ROUND(SUM(oi.profit_amount), 2) AS monthly_profit,
    SUM(oi.quantity) AS units_sold
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY order_month
ORDER BY order_month;

-- 3. Top 10 products by revenue
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.sales_amount), 2) AS total_sales,
    ROUND(SUM(oi.profit_amount), 2) AS total_profit,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales DESC
LIMIT 10;

-- 4. Category performance and profit margin
SELECT
    p.category,
    ROUND(SUM(oi.sales_amount), 2) AS total_sales,
    ROUND(SUM(oi.profit_amount), 2) AS total_profit,
    ROUND(SUM(oi.profit_amount) / SUM(oi.sales_amount), 4) AS profit_margin
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- 5. Regional sales performance
SELECT
    c.region,
    ROUND(SUM(oi.sales_amount), 2) AS total_sales,
    ROUND(SUM(oi.profit_amount), 2) AS total_profit,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.region
ORDER BY total_sales DESC;

-- 6. Customer lifetime value (top 15 customers)
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    c.region,
    ROUND(SUM(oi.sales_amount), 2) AS lifetime_value,
    ROUND(SUM(oi.profit_amount), 2) AS lifetime_profit,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.region
ORDER BY lifetime_value DESC
LIMIT 15;

-- 7. Sales channel comparison
SELECT
    sales_channel,
    ROUND(SUM(order_sales), 2) AS total_sales,
    ROUND(SUM(order_profit), 2) AS total_profit,
    ROUND(AVG(order_sales), 2) AS avg_order_value
FROM (
    SELECT
        o.order_id,
        o.sales_channel,
        SUM(oi.sales_amount) AS order_sales,
        SUM(oi.profit_amount) AS order_profit
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.sales_channel
) channel_orders
GROUP BY sales_channel
ORDER BY total_sales DESC;

-- 8. Repeat customer behavior
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(1.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS repeat_customer_rate
FROM customer_orders;

-- 9. Best-selling product in each category using window functions
WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        ROUND(SUM(oi.sales_amount), 2) AS total_sales,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.sales_amount) DESC
        ) AS sales_rank
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    total_sales
FROM product_sales
WHERE sales_rank = 1
ORDER BY total_sales DESC;

-- 10. Quarterly segment analysis
SELECT
    strftime('%Y', o.order_date) || '-Q' ||
    CAST(((CAST(strftime('%m', o.order_date) AS INTEGER) - 1) / 3) + 1 AS INTEGER) AS quarter,
    c.segment,
    ROUND(SUM(oi.sales_amount), 2) AS total_sales,
    ROUND(SUM(oi.profit_amount), 2) AS total_profit
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY quarter, c.segment
ORDER BY quarter, total_sales DESC;
