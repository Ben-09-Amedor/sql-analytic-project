/*
========================================================================================================
	Product Reoport
========================================================================================================
Purpose:
		- This report consolidates key Product metrics and behaviours

Highlights:
	1. Gathers essential fields such product name, category, subcategory and cost.
	2. Segement product by revenue to identify High Performer, Mid Range or Low Performers.
	3. Aggregate customer-level metrics:
		- total orders
		- total  sales
		- total quantity sold
		- total customers (unique)
		- lifespan( in months)
	4. Calcaulate valuable KPIs
		- recency ( month since last sales)
		- average order revenue
		- average monthly revenue 

===========================================================================================================
*/
/*
------------------------------------------------------------------------------------------------------------
*/
CREATE VIEW gold.report_products AS
WITH base_query AS (
/*
1) Base Query : Retrive Core Column from fact_sale and dim_products Tables
*/
SELECT 
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p. product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL -- eliminate orders with null dates
	),
 product_aggregation AS (

/*
------------------------------------------------------------------------------------------------------------
	2) Product aggreagtion: summarizes key metrics at the customer level
-------------------------------------------------------------------------------------------------------------
*/

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT (DISTINCT order_number) AS total_orders,
	COUNT (DISTINCT customer_key)  AS total_customers,
	SUM(sales_amount) AS total_sales ,
	SUM(quantity) AS total_quanity,
	MAX(order_date) AS last_order_date,
	DATEDIFF (Month, MIN(order_date), MAX(order_date)) AS lifespan,
	ROUND( AVG(CAST( sales_amount AS FLOAT )/ NULLIF (quantity, 0)),1) AS avg_selling_price

FROM base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

/*
------------------------------------------------------------------------------------------------------------
	3) Final Query: combines all results into one output
-------------------------------------------------------------------------------------------------------------
*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	DATEDIFF (month, last_order_date, GETDATE()) AS recency_in_month,
	total_sales ,
	CASE WHEN total_sales > 50000 THEN 'High Performer'
		 WHEN total_sales >=10000 THEN 'Mid-Range'
		 ELSE 'Low Performer'
	END product_segments,
	lifespan,
	total_orders,
	total_sales
	total_quanity,
	total_customers,
	avg_selling_price,

		-- Average Order Revenue

	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales/total_orders
	END AS avg_order_revenue,

		-- Average Monthly Revenue
		CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales/lifespan
	END AS avg_monthly_revenue

FROM product_aggregation 
