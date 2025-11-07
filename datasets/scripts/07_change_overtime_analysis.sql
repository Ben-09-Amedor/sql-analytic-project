/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- sales Performance overtime -year
SELECT 
	Year(order_date) AS order_year,
	SUM(sales_amount) AS total_amount,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY Year(order_date)
ORDER BY Year(order_date);


-- Sales Performance overtime -month
-- Quick Date Function
SELECT 
	Year(order_date) AS order_year,
	Month(order_date) AS order_Month,
	SUM(sales_amount) AS total_amount,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY Year(order_date), Month(order_date)
ORDER BY Year(order_date) , Month(order_date);


-- Sales Performance Overtime -month
-- DATETRUNC ()
SELECT 
	DATETRUNC (MONTH,order_date) AS order_year,
	SUM(sales_amount) AS total_amount,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC (MONTH,order_date) 
ORDER BY DATETRUNC (MONTH,order_date);

	-- sales Performance overtime -month
	-- FORMAT ()
SELECT 
	FORMAT(order_date,'yyyy-MMM') AS order_date,
	SUM(sales_amount) AS total_amount,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
