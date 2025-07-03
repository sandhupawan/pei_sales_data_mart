-- Data Quality Checks
/*
	1. Accuracy
		a. Valid Value Ranges
		b. Correct Formats
		c. Accepted values
	2. Completeness
		a. NULLS & Blank Spaces
		c. Refrential Integrity
	3. Reliability
		a. duplicates
		b. consistent data types
*/

--------------------- Customers --------------------------------
-- 1.a Accuracy-> Valid Value Ranges
-- Age should not be negative, 0, greater than 120

WITH data_accuracy_check AS(
	SELECT
		CASE WHEN age < 0 THEN 'age is negative'
			 WHEN age = 0 THEN 'age is zero'
			 WHEN age > 120 THEN 'age is greater than 120'
			 ELSE 'all values are within the range'
		END AS test_result
	FROM analytics.raw.customers
)
SELECT
	test_result,
	COUNT(*) AS row_cnt
FROM data_accuracy_check
GROUP BY 1
;
-- Test Result: No Transformations are required as all values are within the range

--1.b Accuracy>Correct Formats
-- Assumption is first_name & last_name should not contain any numbers or special characters
WITH correct_formats_test AS (
	SELECT
	    customer_id,
		first_name,
		first_name ~ '[0-9]' AS first_name_has_digits,
		first_name ~ '[^a-zA-Z0-9]' AS first_name_has_special_characters,
		last_name,
		last_name ~ '[0-9]' AS last_name_has_digits,
		last_name ~ '[^a-zA-Z0-9]' AS last_name_has_special_characters
	FROM analytics.raw.customers
	WHERE first_name ~ '[0-9]' OR first_name ~ '[^a-zA-Z0-9]'
	OR last_name ~ '[0-9]' OR last_name ~ '[^a-zA-Z0-9]'
	ORDER BY first_name
)
SELECT COUNT(customer_id) FROM correct_formats_test
;

-- Test Result: Transformations are required. 12 records out of 250 contains numeric or special characters in first or last name.


-- 1.c Accuracy>Accepted Values
-- Multiple variants of country name should not exist

SELECT
	DISTINCT country
FROM analytics.raw.customers
;

-- Test Result: No transformations are required as all country names are displayed as expected.


-- 2. Completeness Checks
/*
Assumptions:
	1. customer_id can't be null or blank
	2. first_name can't be null or blank
	3. age can't be null or blank
	4. country can't be null or blank
	5. Relationships test/Referential Integrity test is not applicable for this table as it only contains dimensions.
*/

WITH data_completeness_check AS (
	SELECT
		*,
		CASE WHEN customer_id IS NULL THEN 'customer_id is null'
		     WHEN first_name IS NULL OR first_name = '' THEN 'first name is null or blank'
			 WHEN age IS NULL THEN 'age is null'
			 WHEN country IS NULL or country = '' THEN 'country is null or blank'
			 ELSE 'no completeness isses'
		END AS test_results
	FROM analytics.raw.customers
)
SELECT
	test_results,
	COUNT(*) AS row_cnt
FROM data_completeness_check
GROUP BY 1
;

-- Test Results: No Transformations are required all of the columns has data and there are no Nulls.

-- 3. Reliability Test
/*
	a. Duplicates:
		1. customer_id is unique for each customer and It can't have duplicates.
		2. Assumption is that a people with same first_name, last_name and age
		   can exists in the same country provided they have unique custmer id

	b. Data Types:
		1. customer_id should be integer
		2. first_name should be VARCHAR(20)
		3. last_name should be VARCHAR(20)
		4. age should be integer
		5. country should be VARCHAR(6)

*/

SELECT
	customer_id,
	COUNT(*) AS row_cnt
FROM analytics.raw.customers
GROUP BY 1
HAVING COUNT(*) > 1
;

-- Test Result: There are no duplicates customer ids

--------------------- Orders --------------------------------
--1.a Accuracy > Valid Value Ranges
-- Amount should not in negatives, 0
WITH data_accuracy_check AS (
	SELECT
		*,
		CASE WHEN amount < 0 THEN 'amount is in negatives'
		     WHEN amount = 0 THEN 'amount is zero'
			 ELSE 'all values are within the range'
		END AS test_results
	FROM analytics.raw.orders
)
SELECT
	test_results,
	COUNT(*)
FROM data_accuracy_check
GROUP BY 1
;


-- Test Results: No transformations are required as amount is greater than 0 in all the records.


-- 1.b Accuracy > Correct Formats
-- Assumption is Item name should not contain any numeric  and special characters and

SELECT *
FROM analytics.raw.orders
WHERE item ~ '[^a-zA-Z0-9] '
	OR item ~ '[0-9]'
;
-- Test Result: None of the item names contains any numeric of special characters therefoere no transformations are required


-- 1.c Accuracy > Consistent Categories
-- Assumption is item name should not have multiple variants


SELECT
	DISTINCT item
FROM analytics.raw.orders
;

-- Test Result: There are no variants for item name exists. No Transforamtions required


/*
	2.a Completeness > Nulls or Blank Spaces
		1. order_id should not be null
		2. item should not be null or blank
		3. amount should not be null or blank
		4. customer id should not be null or blank
*/

WITH data_completeness_check AS (
	SELECT
		*,
		CASE WHEN order_id IS NULL THEN 'order_id is null'
		     WHEN item IS NULL OR item = '' THEN 'item is null'
			 WHEN amount IS NULL THEN 'amount is null'
			 WHEN customer_id IS NULL THEN 'customer_id is null'
		     ELSE 'no completeness issues'
		END AS test_results
	FROM analytics.raw.orders
)
SELECT
	test_results,
	COUNT(*) AS row_cnt
FROM data_completeness_check
GROUP BY 1
;
-- Test Result: There are no nulls or blanks in the data therefore no transformations are required

-- 2.b Completeness > Missing Relationships/Referential Integrity
------ All the records in orders table should have an equivalent record in customers table

SELECT
	o.customer_id,
	c.customer_id
FROM analytics.raw.orders o
LEFT JOIN analytics.raw.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
;

-- Test Result: All of the records in orders table has an equavalent record in customers table. No transformations are required


-- 3. Reliability > Duplicates
/*
	1. order_id should be unique in the entire table
	2. Assumption is that a customer can order same item with same amount more than once therefore uniquenes
	   test is only applicable for order_id column
*/

SELECT
	order_id,
	COUNT(*) AS row_cnt
FROM analytics.raw.orders
GROUP BY 1
HAVING COUNT(*) > 1
;

-- Test Result: There are no duplicates for order_id

--------------------- Shippings --------------------------------
-- 1.a Accuracy > Consistent Categories
-- Accepted Values for the Status are "Delivered" & "Pending"

SELECT DISTINCT status
FROM analytics.stage.stg_shippings
;

-- Test Results: All accpted values are appearing as expcted. No Transformations are required.

-- 2. Completeness > Nulls or Blanks
WITH shippings AS (
	SELECT
		CAST(data->>'Shipping_ID' AS INT) AS shipping_id,
		data->>'Status' AS status,
		CAST(data->>'Customer_ID' AS INT) AS customer_id
	FROM analytics.raw.shipping_json
),
data_completeness_checks AS (
	SELECT
		*,
		CASE WHEN shipping_id IS NULL THEN 'shipping_id is null'
		     WHEN status IS NULL OR status = '' THEN 'status is null'
			 WHEN customer_id IS NULL THEN 'customer_id is null'
			 ELSE 'no data completeness issues'
		END AS test_results
	FROM shippings
)
SELECT
	test_results,
	COUNT(*) AS row_cnt
FROM data_completeness_checks
GROUP BY 1
;

-- Test Results: No Transformations are required as all of the columns have data.

-- 2. Completeness > Referential Integrity
WITH shippings AS (
	SELECT
		CAST(data->>'Shipping_ID' AS INT) AS shipping_id,
		data->>'Status' AS status,
		CAST(data->>'Customer_ID' AS INT) AS customer_id
	FROM analytics.raw.shipping_json
)
SELECT *
FROM shippings s
LEFT JOIN analytics.raw.customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL
;

-- Test Result:No Transformations are required. For each customer_id in shippings we have a record in customers table.

-- 3. Reliability> Duplicates
-- Assumption: No Duplicate shipping_id should appear
WITH shippings AS (
	SELECT
		CAST(data->>'Shipping_ID' AS INT) AS shipping_id,
		data->>'Status' AS status,
		CAST(data->>'Customer_ID' AS INT) AS customer_id
	FROM analytics.raw.shipping_json
)
SELECT
	shipping_id,
	COUNT(*) AS cnt
FROM shippings
GROUP BY 1
HAVING COUNT(*) > 1
;

-- Test Result: There are no duplicates in shipping_id column

-- Assumption: In shipping table a customer can only have either Delivered or Pending status if for a customer we have more than one value or Delivered/Pending then that would be considered as duplicate
WITH shippings AS (
	SELECT
		CAST(data->>'Shipping_ID' AS INT) AS shipping_id,
		data->>'Status' AS status,
		CAST(data->>'Customer_ID' AS INT) AS customer_id
	FROM analytics.raw.shipping_json
)
SELECT
	customer_id,
	status,
	COUNT(*) AS cnt
FROM shippings
GROUP BY 1,2
HAVING COUNT(*) > 1
;
-- Test Results: There are duplicates for the combination of customer_id & status we have to de-duplicate these.



