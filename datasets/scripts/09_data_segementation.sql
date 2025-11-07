/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/
	/* Segment products into cost range and
	count how many products falls into each segement */

WITH product_segements AS(
	SELECT 
	product_key,
	product_name,
	cost, 
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
		 ELSE 'Above 1000'
	END cost_range
	FROM gold.dim_products
) 
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segements
GROUP BY cost_range
ORDER BY total_products DESC;


/* Group customers into three segement base on their spending behaviour
	-- VIP: Customers with at least 12 months of history and spending more than $ 5000
	-- Regular: Customers with at lest 12 month history but spending less than $ 5000
	-- New: Customers with lifespan less than 12 months
And find the total number of customers by each group
*/

WITH customer_spending AS(

  SELECT 
    c.customer_key,
    SUM(f.sales_amount) AS total_sales,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF (Month, MIN(order_date), MAX(order_date)) AS lifespan
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_customers c
  ON f.customer_key = c.customer_key
  GROUP BY c.customer_key
)
SELECT 
     customer_segement,
     COUNT (customer_key) AS total_customers
    FROM(
SELECT
      customer_key,
      CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
      	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
      	 ELSE 'New'
      END customer_segement
FROM customer_spending)t
GROUP BY customer_segement
ORDER BY   total_customers DESC;
