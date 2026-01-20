-- Operations Performance & Trend Analysis
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Purpose: Analyze order volume, delivery performance,
--          and regional operational efficiency



-- Query 1: Order volume by purchase date 
SELECT 
    DATE(order_purchase_timestamp) AS order_date,
    COUNT(order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY DATE(order_purchase_timestamp)
ORDER BY order_date;

-- Query 2: Average delivery time in days 

SELECT
    AVG(
        julianday(order_delivered_customer_date) -
        julianday(order_purchase_timestamp)
    ) AS avg_delivery_time_days

FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;

-- Query 3: Average delivery time by customer state

SELECT
    c.customer_state,
    AVG(
        julianday(o.order_delivered_customer_date) - 
        julianday(o.order_purchase_timestamp)
    ) AS avg_delivery_time_days
FROM olist_orders_dataset o 
JOIN olist_customers_dataset c 
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_time_days DESC;

-- Query 4: Late delivery rate by state using CTE 

WITH delivery_metrics AS (
    SELECT 
        o.order_id,
        c.customer_state,
        CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END AS is_late
    FROM olist_orders_dataset o 
    JOIN olist_customers_dataset c 
        ON o.customer_id = c.customer_id
    WHERE o.order_delivered_customer_date IS NOT NULL

)

SELECT 
    customer_state,
    COUNT(order_id) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(
        SUM(is_late) * 100.0 / COUNT(order_id),
        2
    ) AS late_delivery_rate_pct
FROM delivery_metrics
GROUP BY customer_state
ORDER BY late_delivery_rate_pct DESC;
