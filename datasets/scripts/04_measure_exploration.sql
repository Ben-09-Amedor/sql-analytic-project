/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
	-- Find the total sales
SELECT SUM(sales_amount) FROM gold.fact_sales

	-- find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

	-- find the average selling price
SELECT AVG(price) AS Avg_price FROM gold.fact_sales

	-- find the total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

	-- find the total number of products
SELECT COUNT( DISTINCT product_number) AS total_products FROM gold.dim_products

	-- find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

	-- find the total number of customers that has place an orders
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales


	-- Generate a report that shows the key metrics of the business
SELECT 'Total Sale' AS measure_name,  SUM(sales_amount) AS measure_Value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS meaure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Order' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Product'  AS measure_name, COUNT( DISTINCT product_number) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
