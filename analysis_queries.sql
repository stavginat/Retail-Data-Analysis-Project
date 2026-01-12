-- 1. Checking for no nulls and no duplicates in sale_id
SELECT COUNT(*) AS tot,
COUNT(sale_id) AS tot_sale,
COUNT (DISTINCT sale_id) AS dist_sale
FROM bqproj-435911.Final_Project_2025.log_sales;

-- 2. Checking for nulls in other fields
SELECT *
FROM bqproj-435911.Final_Project_2025.log_sales
WHERE sale_id IS NULL
OR timestamp IS NULL
OR subtotal IS NULL
OR tax IS NULL
OR total IS NULL
OR payment_method IS NULL;

-- 3. Checking the table's time frame
SELECT MIN(timestamp) AS min_time,
MAX(timestamp) AS max_time
FROM bqproj-435911.Final_Project_2025.log_sales;

-- 4. Checking sales over time period + day of the week
SELECT EXTRACT (date FROM timestamp) AS date, 
EXTRACT (dayofweek FROM timestamp) AS day,
COUNT(sale_id) AS sale_count,
FORMAT("%'d",CAST(SUM(total) AS int64)) AS tot_sale
FROM  bqproj-435911.Final_Project_2025.log_sales
GROUP BY 1,2
ORDER BY 1,2;

-- 5. Checking for patterns by month and week
SELECT 
EXTRACT (month FROM timestamp) AS month,
COUNT(sale_id) AS sale_count,
FORMAT("%'d",CAST(SUM(total) AS int64)) AS tot_sale
FROM `bqproj-435911.Final_Project_2025.log_sales`
GROUP BY 1
ORDER BY 1;

SELECT 
EXTRACT (week FROM timestamp) AS week,
COUNT(sale_id) AS sale_count,
FORMAT("%'d",CAST(SUM(total) AS int64)) AS tot_sale
FROM `bqproj-435911.Final_Project_2025.log_sales`
GROUP BY 1
ORDER BY 1;

-- 6. Checking for sales by hour
SELECT EXTRACT (hour FROM timestamp) AS hour,
COUNT(sale_id) AS sale_count,
FORMAT("%'d",CAST(SUM(total) AS int64)) AS tot_sale
FROM `bqproj-435911.Final_Project_2025.log_sales`
GROUP BY 1
ORDER BY 1;

-- 7. Checking sales for app using customers vs. non-app customers
WITH customers AS (
  SELECT DISTINCT device_id AS id,
  role
  FROM bqproj-435911.Final_Project_2025.geolocation
  WHERE role IN ('repeat_customer','one_time_customer')
)

SELECT
  CASE 
    WHEN s.customer_id IS NULL THEN 'no_app'
    WHEN c.role = 'repeat_customer' THEN 'repeat'
    WHEN c.role = 'one_time_customer' THEN 'one_time'
  END AS customer_type,
  COUNT(*) AS transaction_count,
  ROUND(AVG(s.total), 2) AS avg_basket,
  FORMAT("%'d",CAST(SUM(s.total) AS int64)) AS total_revenue
FROM `bqproj-435911.Final_Project_2025.log_sales` s
LEFT JOIN customers c
  ON s.customer_id = c.id
WHERE c.role IN ('repeat_customer','one_time_customer')
OR s.customer_id IS NULL
GROUP BY 1;

-- 8. Checking for payment method distribution
SELECT payment_method,
COUNT(sale_id) AS count
FROM `bqproj-435911.Final_Project_2025.log_sales`
GROUP BY 1;

--9. Checking for Supermarkets per population
with supercount as (
  select city, count(*) as super_count
  from bqproj-435911.Final_Project_2025.supermarkets_il
  group by 1
)

select l.city_name as city,
l.total_population as population,
s.super_count,
round((s.super_count/l.total_population*100),2) as supers_divide_population
from bqproj-435911.Final_Project_2025.Lamas_israel_2025 l
join supercount s
on l.city_name = s.city

-- 9a Workers by time
SELECT
EXTRACT (date FROM timestamp) AS Date,
EXTRACT(WEEK FROM timestamp) AS Week_Number,
EXTRACT (dayofweek FROM timestamp) AS Day_of_Week,
EXTRACT (hour FROM timestamp) AS Hour,
CASE
  WHEN role = 'cashier' THEN 'Cashier'
  WHEN role = 'manager' THEN 'Manager'
  WHEN role = 'delivery_guy' THEN 'Delivery Guy'
  WHEN role = 'general_worker' THEN 'General Worker'
  WHEN role = 'butcher' THEN 'Butcher'
  WHEN role = 'senior_general_worker' THEN 'Senior General Worker'
  WHEN role = 'security_guy' THEN 'Security Guy'
END AS worker_type,
COUNT(DISTINCT device_id) AS worker_count
FROM `bqproj-435911.Final_Project_2025.geolocation`
WHERE role IN ('cashier','manager','delivery_guy','general_worker','butcher','senior_general_worker','security_guy')
GROUP BY 1, 2, 3, 4, 5;

-- 10. Checking for nulls in geolocation table
SELECT *
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE device_id IS NULL
OR lat IS NULL
OR lon IS NULL
OR timestamp IS NULL
OR accuracy_m IS NULL
OR role IS NULL
OR area IS NULL;

-- 11. Geolocation table: Checking what are the roles in the table.
SELECT DISTINCT role,
SUBSTR(device_id,1,3) AS device
FROM bqproj-435911.Final_Project_2025.geolocation;

SELECT *
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE SUBSTR(device_id,1,3) != SUBSTR(role,1,3);

-- 12. Checking how many users exist in each category
SELECT role,
COUNT (DISTINCT device_id) AS unique
FROM bqproj-435911.Final_Project_2025.geolocation
GROUP BY 1
ORDER BY 2;

-- 13. How to identify different roles.
SELECT DISTINCT area
FROM bqproj-435911.Final_Project_2025.geolocation;

-- 14. Finding the manager.
SELECT device_id,
COUNT(*) AS head_office_visits
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area = 'HEAD_OFFICE'
GROUP BY 1
ORDER BY 2 DESC;

-- 15. Finding the cashiers
SELECT device_id,
COUNT(*) AS cashiers_visits
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area = 'CASH_REGISTERS'
GROUP BY 1
ORDER BY 2 DESC;

-- 16. Finding the butchers
SELECT device_id,
COUNT(*) AS butchery_visits
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area = 'BUTCHERY'
GROUP BY 1
ORDER BY 2 DESC;

-- 17. Finding general workers
SELECT device_id,
COUNT(*) AS general_area_visits
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area = 'SUPERMARKET'
GROUP BY 1
HAVING general_area_visits > 5000
ORDER BY 2 DESC;

-- 18. Finding security people
SELECT device_id,
COUNT(*) AS parking_visits
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area = 'PARKING'
GROUP BY 1
HAVING parking_visits > 2000
ORDER BY 2 DESC;

-- 19. Finding delivery people
SELECT device_id,
COUNT(*) AS warehouns_visits
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area = 'WAREHOUSE'
GROUP BY 1
ORDER BY 2 DESC;

-- 20. Identifing outliers in accuracy
SELECT FORMAT("%'d",COUNT(CASE WHEN accuracy_m >30 THEN accuracy_m END)) AS unaccurate_count,
ROUND(COUNT (CASE WHEN accuracy_m >30 THEN accuracy_m END) / COUNT(accuracy_m)*100,2) AS unaccurate_rate
FROM bqproj-435911.Final_Project_2025.geolocation;

-- 21. Outliers per role
SELECT role,
COUNT(CASE WHEN accuracy_m >30 THEN accuracy_m END) AS unaccurate_count,
ROUND(COUNT (CASE WHEN accuracy_m >30 THEN accuracy_m END) / COUNT(accuracy_m)*100,2) AS unaccurate_rate
FROM bqproj-435911.Final_Project_2025.geolocation
GROUP BY 1
ORDER BY 2 DESC;

-- 22. Outliers per area
SELECT area,
COUNT(CASE WHEN accuracy_m >30 THEN accuracy_m END) AS unaccurate_count,
ROUND(COUNT (CASE WHEN accuracy_m >30 THEN accuracy_m END) / COUNT(accuracy_m)*100,2) AS unaccurate_rate
FROM bqproj-435911.Final_Project_2025.geolocation
GROUP BY 1
ORDER BY 2 DESC;

-- 23. Mega outliers
SELECT FORMAT("%'d",COUNT(CASE WHEN accuracy_m >100 THEN accuracy_m END)) AS unaccurate_count,
ROUND(COUNT (CASE WHEN accuracy_m >100 THEN accuracy_m END) / COUNT(accuracy_m)*100,2) AS unaccurate_rate
FROM bqproj-435911.Final_Project_2025.geolocation;

-- 24. Performance analysis: Checking for 40% location broadcasts
WITH broadcasting AS (
SELECT device_id,
DATE (timestamp) AS date,
TIME_DIFF(MAX(TIME(timestamp)),MIN(TIME(timestamp)),MINUTE) + 1 AS max_broadcastst_per_user_daily,
COUNT(*) AS broadcast_count,
SAFE_DIVIDE(COUNT(*) * 100, TIME_DIFF(MAX(TIME(timestamp)),MIN(TIME(timestamp)),MINUTE) + 1) AS broadcasting_percent
FROM bqproj-435911.Final_Project_2025.geolocation
GROUP BY 1,2)

SELECT COUNT(CASE WHEN broadcasting_percent >= 40 THEN broadcasting_percent END) / COUNT(broadcasting_percent) AS over_40_percent
FROM broadcasting;

-- 25. How to improve performance analysis
WITH broadcasting AS (
SELECT device_id,
DATE (timestamp) AS date,
TIME_DIFF(MAX(TIME(timestamp)),MIN(TIME(timestamp)),MINUTE) + 1 AS max_broadcastst_per_user_daily,
COUNT(*) AS broadcast_count,
SAFE_DIVIDE(COUNT(*) * 100, TIME_DIFF(MAX(TIME(timestamp)),MIN(TIME(timestamp)),MINUTE) + 1) AS broadcasting_percent
FROM bqproj-435911.Final_Project_2025.geolocation
WHERE area != 'PARKING'
GROUP BY 1,2)

SELECT COUNT(CASE WHEN broadcasting_percent >= 40 THEN broadcasting_percent END) / COUNT(broadcasting_percent) AS over_40_percent
FROM broadcasting;

-- 26. Looking for other anomalies in the geolocation table: lon and lat
SELECT DISTINCT CONCAT(SUBSTR(CAST (lat AS STRING),1,6), ", ", SUBSTR(CAST (lon AS STRING),1,6)) AS all_locations
FROM bqproj-435911.Final_Project_2025.geolocation;

-- 27. Looking for different areas in the same location
SELECT CONCAT(lat, ", ",lon) AS locations,
accuracy_m,
COUNT(DISTINCT area) AS area_count,
STRING_AGG(DISTINCT area ORDER BY area) AS areas
FROM bqproj-435911.Final_Project_2025.geolocation
GROUP BY 1,2
HAVING area_count > 1
ORDER BY 2;

-- 28. Looking for missing delivery dates
WITH dates AS (
  SELECT DISTINCT EXTRACT (date FROM timestamp) AS day
  FROM bqproj-435911.Final_Project_2025.geolocation
  WHERE EXTRACT (dayofweek FROM timestamp) IN (2, 5)
),

deliveries AS (
  SELECT DISTINCT EXTRACT (date FROM timestamp) AS delivery_day
  FROM bqproj-435911.Final_Project_2025.geolocation
  WHERE EXTRACT (dayofweek FROM timestamp) IN (2, 5)
  AND role = 'delivery_guy'
)

SELECT d.day
FROM dates d
LEFT JOIN deliveries de
ON d.day = de.delivery_day
WHERE de.delivery_day IS NULL;

-- 29. Finding the customers with most visits
SELECT device_id,
COUNT(DISTINCT EXTRACT(DATE FROM timestamp)) AS number_of_visits
FROM `bqproj-435911.Final_Project_2025.geolocation`
WHERE role = 'repeat_customer'
GROUP BY 1
QUALIFY RANK() OVER (ORDER BY COUNT(DISTINCT EXTRACT(DATE FROM timestamp)) DESC) <= 5
ORDER BY 2 DESC;

-- 30. Finding the customers that spent the most.
SELECT customer_id,
ROUND(SUM(total),2) AS total_spending
FROM bqproj-435911.Final_Project_2025.log_sales
WHERE customer_id IS NOT NULL
GROUP BY 1
QUALIFY RANK() OVER (ORDER BY SUM(total) DESC) <= 5
ORDER BY 2 DESC;

-- 31. Customer presence and traffic
  SELECT 
    EXTRACT(DATE FROM timestamp) AS date,
    EXTRACT(DAYOFWEEK FROM timestamp) AS day_of_week,
    EXTRACT(HOUR FROM timestamp) AS hour,
    CASE 
      WHEN role = 'repeat_customer' THEN 'Repeat Customer'
      WHEN role = 'one_time_customer' THEN 'One Time Customer'
      WHEN role = 'not_paying' THEN 'Not Paying'
      WHEN role IS NULL THEN 'No App'
    END AS customer_type,
    COUNT(DISTINCT id_to_count) AS segment_count
  FROM (
    SELECT timestamp, device_id AS id_to_count, role 
    FROM `bqproj-435911.Final_Project_2025.geolocation`
    WHERE role IN ('repeat_customer', 'one_time_customer', 'not_paying')
    UNION ALL
    SELECT timestamp, sale_id AS id_to_count, NULL AS role 
    FROM `bqproj-435911.Final_Project_2025.log_sales`
    WHERE customer_id IS NULL
  )
  GROUP BY 1, 2, 3, 4;

-- 32. Looking for patterns in busy and quiet times
SELECT EXTRACT (dayofweek FROM timestamp) AS day,
EXTRACT (hour FROM timestamp) AS hour,
ROUND(AVG(total),2) AS avg_buy,
ROUND(AVG(dwell_minutes),2) AS avg_stay
FROM bqproj-435911.Final_Project_2025.log_sales
GROUP BY 1, 2
ORDER BY 1, 2;

-- 33. More patterns
SELECT
EXTRACT (date FROM timestamp) AS Date,
EXTRACT (dayofweek FROM timestamp) AS Day_of_Week,
EXTRACT (hour FROM timestamp) AS Hour,
CASE 
    WHEN SUBSTR(customer_id,1,3) = 'rep' THEN 'Repeat Customer'
    WHEN  SUBSTR(customer_id,1,3) = 'one' THEN 'One Time Customer'
    WHEN customer_id IS NULL THEN 'No App'
  END AS customer_type,
SUM(total) AS Total_Sales,
COUNT(sale_id) AS Transaction_Count
FROM `bqproj-435911.Final_Project_2025.log_sales`
GROUP BY 1, 2, 3, 4;

-- 34. Different patterns for clients (returning, one-time, no-app)
WITH hourly_sums AS (
   SELECT 
    EXTRACT(DAYOFWEEK FROM COALESCE(g.timestamp, s.timestamp)) AS day_of_week,
    EXTRACT(HOUR FROM COALESCE(g.timestamp, s.timestamp)) AS hour,
    COUNTIF(g.role = 'repeat_customer') AS repeat_cust,
    COUNTIF(g.role = 'one_time_customer') AS one_time_cust,
    COUNTIF(s.customer_id IS NULL AND s.sale_id IS NOT NULL) AS non_app_cust
  FROM `bqproj-435911.Final_Project_2025.geolocation` g
  FULL OUTER JOIN `bqproj-435911.Final_Project_2025.log_sales` s 
    ON g.timestamp = s.timestamp AND g.device_id = s.customer_id 
  GROUP BY 1, 2
),
totals AS (
  SELECT *,
    (repeat_cust + one_time_cust + non_app_cust) AS total_in_hour
  FROM hourly_sums
)
SELECT 
  day_of_week,
  hour,
  total_in_hour,
  ROUND(SAFE_DIVIDE(repeat_cust, total_in_hour) * 100,2) AS pct_repeat,
  ROUND(SAFE_DIVIDE(one_time_cust, total_in_hour) * 100,2) AS pct_one_time,
  ROUND(SAFE_DIVIDE(non_app_cust, total_in_hour) * 100,2) AS pct_non_app
FROM totals
WHERE total_in_hour > 0
ORDER BY day_of_week, hour;

--35. Looking for long lines in the cashiers
SELECT 
    device_id,
    role,
    EXTRACT(DATE FROM timestamp) AS visit_date,
    TIMESTAMP_DIFF(MAX(timestamp), MIN(timestamp), SECOND) / 60.0 AS dwell_minutes
  FROM `bqproj-435911.Final_Project_2025.geolocation`
  WHERE role IN ('not_paying','repeat_customer','one_time_customer')
  AND area = 'CASH_REGISTERS'
  GROUP BY 1, 2, 3
  ORDER BY 4 DESC;

--  36. Sales-cashier ratio
WITH sales AS (
  SELECT
  EXTRACT(date FROM timestamp) AS Date,
  EXTRACT (dayofweek FROM timestamp) AS Day_of_week,
  EXTRACT (hour FROM timestamp) AS hour,
  SUM(total) AS sales
  FROM `bqproj-435911.Final_Project_2025.log_sales`
  GROUP BY 1, 2, 3
),

cashiers AS (
  SELECT
  EXTRACT(date FROM timestamp) AS Date,
  EXTRACT (dayofweek FROM timestamp) AS Day_of_week,
  EXTRACT (hour FROM timestamp) AS hour,
  COUNT(DISTINCT device_id) AS cashiers
  FROM `bqproj-435911.Final_Project_2025.geolocation`
  WHERE role = 'cashier'
  GROUP BY 1, 2, 3
)

SELECT s.Date, s.Day_of_Week, s.Hour, s.sales,
COALESCE(c.cashiers,0) AS cashier_count,
SAFE_DIVIDE(s.sales,c.cashiers) AS sales_per_cashier
FROM sales s
LEFT JOIN cashiers c
ON s.Date = c.Date AND s.Hour = c.Hour;

-- 37. Cashier usage per hour
WITH cashiers AS (
   SELECT 
    DATE(timestamp) AS transaction_date,
    EXTRACT(HOUR FROM timestamp) AS hour,
    EXTRACT(DAYOFWEEK FROM timestamp) AS day,
    COUNT(DISTINCT IF(role = 'cashier', device_id, NULL)) AS unique_cashiers
     FROM bqproj-435911.Final_Project_2025.geolocation
  WHERE area = 'CASH_REGISTERS'
  GROUP BY 1, 2, 3
),

customers AS (
  SELECT 
    DATE(timestamp) AS transaction_date,
    EXTRACT(HOUR FROM timestamp) AS hour,
    EXTRACT(DAYOFWEEK FROM timestamp) AS day,
    COUNT (sale_id) AS unique_customers
  FROM bqproj-435911.Final_Project_2025.log_sales
  GROUP BY 1, 2, 3
)

SELECT 
  ca.day,
  ca.hour,
  ROUND(AVG(cu.unique_customers), 0) AS avg_customers,
  ROUND(AVG(ca.unique_cashiers), 0) AS avg_cashiers,
  ROUND(SAFE_DIVIDE(AVG(cu.unique_customers), AVG(ca.unique_cashiers)), 1) AS cashier_customer_ratio,
FROM cashiers ca
LEFT JOIN customers cu
ON ca.day = cu.day
AND ca.hour = cu.hour
GROUP BY 1, 2
ORDER BY 1, 2;

-- 37a. Finding missing dates
SELECT day 
FROM UNNEST(GENERATE_DATE_ARRAY(
  (SELECT MIN(DATE(timestamp)) FROM bqproj-435911.Final_Project_2025.geolocation), 
  (SELECT MAX(DATE(timestamp)) FROM bqproj-435911.Final_Project_2025.geolocation)
)) AS day
WHERE EXTRACT(DAYOFWEEK FROM day) != 7

EXCEPT DISTINCT

SELECT DISTINCT DATE(timestamp) FROM bqproj-435911.Final_Project_2025.geolocation
ORDER BY day;

-- 38. Data for first regression
SELECT
DATE_DIFF(DATE(timestamp), DATE('2025-06-01'), WEEK(SUNDAY)) + 1 AS week_number,
COUNT(DISTINCT device_id) AS unique_device
FROM `bqproj-435911.Final_Project_2025.geolocation`
WHERE role IN ('repeat_customer', 'one_time_customer','not_paying')
GROUP BY 1
ORDER BY 1;

-- 39. Data for second regression
SELECT dwell_minutes,
ROUND(AVG(total),2) AS spend
FROM `bqproj-435911.Final_Project_2025.log_sales`
WHERE dwell_minutes IS NOT NULL
GROUP BY 1
ORDER BY 1;


