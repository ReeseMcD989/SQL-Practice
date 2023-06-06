
/*Format*/

SELECT
CASE
WHEN THEN
WHEN THEN
ELSE END
FROM
INNER JOIN
ON =
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT

/*2.1 Using the table department_date , write a query that returns department and a column
called "Department Spend", which should be the sum of spending in the department across all
time. Join the department name from departments , so that your query returns three
columns. Sort the results from highest spend to lowest.*/

SELECT department_date.department
, SUM(spend) AS 'Department Spend'
, dept_name
FROM department_date 
INNER JOIN departments
ON department_date.department = departments.department
GROUP BY department_date.department
ORDER BY "Department Spend" DESC

/*2.2 Using the table department_date , write a query that returns department and a column
called "Department Spend", which should be the sum of spending in the department in 2015.
Again, join the department name from departments , so that your query returns three
columns. Sort the results from highest spend to lowest.*/

SELECT department_date.department
, SUM(spend) AS 'Department Spend'
, dept_name
FROM department_date
INNER JOIN departments
ON department_date.department = departments.department
WHERE department_date.date LIKE '%2015%'
GROUP BY department_date.department
ORDER BY "Department Spend" DESC

/*2.3 Using the table owner_spend_date , write a query that returns a count of distinct owners
and their total spend by year. Return three columns called year , num_owners , and
total_spend.*/

SELECT STRFTIME('%Y', date) AS "year"
, COUNT(DISTINCT card_no) AS 'num_owners'
, SUM(spend) AS 'total_spend'
FROM owner_spend_date
GROUP BY Year

/*2.4 Using the date_hour table, write a query that returns the number of rows in date_hour
by hour of the day, as well as the sum of spend in that hour. Return three columns (hour,
"Num Days", and "Total Sales") and order the results by hour. Round total sales to two decimal
places (cents).*/

SELECT hour
, COUNT(hour) AS 'Num Days'
, ROUND(SUM(spend), 2) AS 'Total Sales'
FROM date_hour
GROUP BY hour
ORDER BY hour

/*2.5 Using the date_hour table, write a query that returns the number of rows in date_hour
by hour of the day, as well as the sum of spend in that hour. Return three columns (hour,
"Num Days", and "Total Sales") and order the results by hour. Using a HAVING clause, only
return results that have fewer 2570 rows. Round total sales to two decimal places (cents).*/

SELECT hour
, COUNT(hour) AS 'Num Days'
, ROUND(SUM(spend), 2) AS 'Total Sales'
FROM date_hour
GROUP BY hour
HAVING "Num Days" < 2570
ORDER BY hour

/*2.6 Using the table owner_spend_date , write a query that returns total spend and number of
shopping days by card_no . Return three columns (card_no, "Num Days", and "Total
Spend"). Order the results by Total Spend descending.*/

SELECT card_no
, COUNT(DISTINCT date) AS 'Num Days'
, SUM(spend) AS 'Total Spend'
FROM owner_spend_date
GROUP BY card_no
ORDER BY "Total Spend" DESC

/*2.7 Again, using the table owner_spend_date , write a query that returns total spend and
number of shopping days by card_no . Add a column that calculates the average spend per
day (called "Average Daily Spend") and order the results by this column.*/

SELECT card_no
, COUNT(DISTINCT date) AS 'Num Days'
, SUM(spend) AS 'Total Spend'
, AVG(spend) AS 'Average Daily Spend'
FROM owner_spend_date
GROUP BY card_no
ORDER BY "Average Daily Spend"

/*2.8 Repeat the previous query but now summarize the results by zip, a field that you will have to join
from the owners table. In other words, use the table owner_spend_date , write a query
that returns total spend and number of shopping days across all the owners who live in a given
zip code. Name the "Num Days" column "Num Owner-Days" in this query. Again add a column
that calculates the average spend per day (called "Average Daily Spend"). Order the results by
"Total Spend" decreasing. Round "Total Spend" and "Average Daily Spend" to two decimal*/

SELECT zip
, COUNT(DISTINCT date) AS 'Num Owner-Days'
, ROUND(SUM(spend), 2) AS 'Total Spend'
, ROUND(AVG(spend), 2) AS 'Average Daily Spend'
FROM owner_spend_date
INNER JOIN owners
ON owner_spend_date.card_no = owners.card_no
GROUP BY zip
ORDER BY "Total Spend" DESC

/*2.9 This query is a variation on the above query.
The Wedge in the zip code 55405. Use a CASE statement to create a column called "Area"
that classifies zips into the following groups:
wedge : 55405
adjacent : 55442, 55416, 55408, 55404, 55403
other : any other zip codes.
Calculate For each group of zips, calculate the following information based on the
owner_spend_date table:XXXXXXXXXXXXXX

Number of owners x
Number of owner-days x
Average number of days per owner 
Total spend 
Average spend per owner 
Average spend per owner day
Use sensible column headers*/

SELECT 
CASE zip
WHEN 55405 THEN 'wedge'
WHEN 55442 THEN 'adjacent'
WHEN 55416 THEN 'adjacent' 
WHEN 55408 THEN 'adjacent' 
WHEN 55404 THEN 'adjacent' 
WHEN 55403 THEN 'adjacent'
ELSE 'other' END AS 'Area'
, COUNT(DISTINCT owner_spend_date.card_no) AS 'Num Owners'
, COUNT(DISTINCT date) AS 'Num Owner-Days'
, COUNT(DISTINCT owner_spend_date.card_no)/COUNT(DISTINCT date) AS 'Days per Owner'
, ROUND(SUM(spend), 2) AS 'Total Spend'
, ROUND(SUM(spend), 2)/COUNT(DISTINCT owner_spend_date.card_no) AS 'Spend per Owner'
, ROUND(SUM(spend), 2)/COUNT(DISTINCT date) AS 'Spend per Owner-Day'
FROM owner_spend_date
INNER JOIN owners
ON owner_spend_date.card_no = owners.card_no
GROUP BY "Area"
ORDER BY "Area"

/*2.10 Using the department_date table (and a join to deparments to get department name),
write a query that includes the following columns:
Department number
Department name
Total spend in that department (rounded to the nearest dollar)
Total number of items purchased in the department
Total number of transactions in the department
Average item price in the department
Return the results ordered by the average item price in the department, descending*/

SELECT department_date.department AS 'dept_num'
, departments.dept_name
, ROUND(SUM(spend), 0) AS 'Total Spend'
, SUM(items) AS 'Total Items'
, SUM(trans) AS 'Total Transaction'
, ROUND(SUM(spend), 0)/SUM(items) AS 'Average Item Price'
FROM department_date
INNER JOIN departments
ON department_date.department = departments.department
GROUP BY department_date.department
ORDER BY "Average Item Price" DESC









