/*
========================================================================================================
	Customer Reoport
========================================================================================================
Purpose:
		- This report consolidates key customer metrics and behaviours

Highlights:
	1. Gathers essential fields such names, age, transaction details
	2. Segement Customers into categories (VIP, Regular, New) and age group
	3. Aggregate customer-level metrics:
		- total orders
		- total  sales
		- total quantity purchased
		- total products
		- lifespan( in months)
	4. Calcaulate valuable KPIs
		- recency ( month since last order)
		- average order value
		- average monthly spending 

===========================================================================================================

*/
/*
------------------------------------------------------------------------------------------------------------
1) Base Query : Retrive Core Column from the Tables
------------------------------------------------------------------------------------------------------------
*/
CREATE VIEW gold.report_customers AS
WITH base_query AS(
/*
------------------------------------------------------------------------------------------------------------
1) Base Query : Retrive Core Column from the Tables
------------------------------------------------------------------------------------------------------------
*/
SELECT 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(first_name, ' ', last_name) AS customer_name,
	DATEDIFF (Year,birthdate, GETDATE()) AS age
FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.Customer_key
	WHERE order_date IS NOT NULL),

 customer_aggregation AS(
/*
------------------------------------------------------------------------------------------------------------
	2) Customer aggreagtion: summarizes key metrics at the customer level
-------------------------------------------------------------------------------------------------------------
*/
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age, 
	COUNT(order_number) AS total_orders,
	SUM(sales_amount) AS  total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF (Month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age)
/*
------------------------------------------------------------------------------------------------------------
	3) Final Query: combines all results into one output
-------------------------------------------------------------------------------------------------------------
*/

SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
CASE WHEN age < 20 THEN 'under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE 'Above 50'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segement,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS rescency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compute average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales/total_orders
END AS avg_order_value,
	-- Compute average monthly spending 
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales/lifespan
END AS avg_monthly_spending
	FROM customer_aggregation
