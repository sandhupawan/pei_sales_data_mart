--1. the total amount spent and the country for the Pending delivery status for each country.
SELECT
	c.country,
	SUM(o.amount) AS total_amount
FROM sales_mart.dim_customers c
INNER JOIN sales_mart.dim_shipping_status s ON c.customer_id = s.customer_id -- Inner join becasue not all customer have shipping data
INNER JOIN sales_mart.fact_orders o ON c.customer_id = o.customer_id -- Inner join becasue not all customer have orders data
WHERE s.status = 'Pending' -- to get customers with pending orders
GROUP BY 1
ORDER BY 2 DESC
;

-- 2. The total number of transactions, total quantity sold, and total amount spent for each customer, along with the product details.
/*
	1. One order can be considered as one transaction as we don't have transaction level date
	2. We don't have quantity sold column, for quantity i'll look at number of times an item is ordered and if it's ordered once
	then order quantity would be 1 if it's ordered 10 times then quantity would be 10
*/

SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	o.item,
	COUNT(o.order_id) AS total_transactions,
	COUNT(o.order_id) AS total_quantity,
	SUM(o.amount) AS total_amount_spent
FROM sales_mart.dim_customers c
INNER JOIN sales_mart.fact_orders o ON c.customer_id = o.customer_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC
;

-- 3. the maximum product purchased for each country.
WITH item_quantity_per_country AS (
	SELECT c.country,
		   o.item,
		   COUNT(o.order_id) AS item_sold_cnt,
		   ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(o.order_id) DESC) AS rn
	FROM sales_mart.dim_customers c
	INNER JOIN sales_mart.fact_orders o ON c.customer_id = o.customer_id
	GROUP BY 1,2
)
SELECT
	country,
	item,
	item_sold_cnt
FROM item_quantity_per_country
WHERE rn = 1
;


-- 4. the most purchased product based on the age category less than 30 and above 30.
WITH items_sold_per_age_group AS (
	SELECT
		CASE WHEN c.age < 30 THEN 'Less than 30'
		     WHEN c.age >= 30 THEN '30 and Above'
		END AS age_range,
	    o.item,
		COUNT(o.order_id) AS item_sold_cnt
	FROM sales_mart.dim_customers c
	INNER JOIN sales_mart.fact_orders o ON c.customer_id = o.customer_id
	GROUP BY 1,2
),
ranking AS (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY age_range ORDER BY item_sold_cnt DESC) AS rn
	FROM items_sold_per_age_group
)
SELECT
	age_range,
	item,
	item_sold_cnt
FROM ranking
WHERE rn = 1
;

-- 5. the country that had minimum transactions and sales amount.
-- We don't have transactions table so I'll consider transaction amount = sales_amount

SELECT
	c.country,
	SUM(o.amount) AS sales_amount
FROM sales_mart.dim_customers c
INNER JOIN sales_mart.fact_orders o ON c.customer_id = o.customer_id
GROUP BY 1
ORDER BY 2
LIMIT 1
;

