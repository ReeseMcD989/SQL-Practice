--GBQ functions and differences
--SELECT EXTRACT(YEAR FROM date) as year





/*4.1 --CORRECT-- In the SQLite database, write a statement which creates an empty table with four columns called
"year", "description", and "sales" with types integer, text, and numeric respectively. Include a line
before the create statement that drops the table if it exists. Call your table
product_summary . Paste a screenshot of the successful query log.*/

DROP TABLE IF EXISTS product_summary;
CREATE TABLE product_summary
(
year INTEGER
, description TEXT
, sales NUMERIC
)

SELECT * FROM product_summary

/*4.2 --CORRECT-- Write a statement or set of statements that inserts the following rows in your table:
year description sales
2014 BANANA Organic 176818.73
2015 BANANA Organic 258541.96
2014 AVOCADO Hass Organic 146480.34
2014 ChickenBreastBoneless/Skinless 204630.90
Select all rows from your table for your "results" file.*/

INSERT INTO product_summary
VALUES
('2014', 'BANANA Organic', '176818.73'),
('2015', 'BANANA Organic', '258541.96'),
('2014', 'AVOCADO Hass Organic', '146480.34'),
('2014', 'ChickenBreastBoneless/Skinless', '204630.90')

SELECT * FROM product_summary

/*4.3 --CORRECT-- Write a statement that updates the year for the row containing the avocado sales to 2022.
Select all rows from your table for your "results" file.*/

UPDATE product_summary
SET year = 2022
WHERE description LIKE '%AVOCADO Hass Organic%'

SELECT * FROM product_summary

/*4.4 --CORRECT-- Write a statement that deletes the oldest banana row from the table.
Select all rows from your table for your "results" file.*/

DELETE FROM product_summary
WHERE year = 2014 AND description LIKE '%BANANA Organic%'

SELECT * FROM product_summary

/*4.5 --CORRECT-- Using the table umt-msba.wedge_examples.department_date in GBQ, write a query
that returns department and a column called dept_spend , which should be the sum of
spending in the department in 2015. Join the department name from departments , so that
your query returns three columns. Sort the results from highest spend to lowest.
(This is a repeat of 2.2, translated to GBQ.)*/

SELECT dd.department
, ROUND(SUM(dd.spend), 2) AS dept_spend
, ds.dept_name
FROM `umt-msba.wedge_example.department_date` AS dd
INNER JOIN `umt-msba.wedge_example.departments` AS ds
ON dd.department = ds.department
WHERE EXTRACT(YEAR FROM dd.date) = 2015
GROUP BY dd.department, ds.dept_name
ORDER BY dept_spend DESC

/*4.6 --INCORRECT--CORRECTED Using the table umt-msba.wedge_example.owner_spend_date , write a query that
returns the following columns: card_no , year , month , spend , and items . Those
last two columns should be the sum of the columns of the same name in the original table. Filter
your results to owner-year-month combinations between $750 and $1250, order by spend in
descending order, and only return the top 10 rows.
(This is a variation of 3.1, translated to GBQ. We don't make our own tables here because this
server is a shared resource, so we don't want to be littering it with lots of tables.)*/

SELECT card_no
, EXTRACT(YEAR FROM date) AS year
, EXTRACT(MONTH FROM date) AS month
, SUM(spend) AS spend 
, SUM(items) AS items
FROM `umt-msba.wedge_example.owner_spend_date`
GROUP BY card_no, year, month
HAVING spend >= 750
AND spend <= 1250
ORDER BY spend DESC
LIMIT 10

/*4.7 --CORRECT-- As mentioned in the lecture, GBQ allows you to query a series of tables using the wildcard
operator. In this query we explore a single one of these tables, which are in the
transactions dataset. I've included a data dictionary for these types of tables in the
assignment.
For this query, use the table
umt-msba.transactions.transArchive_201001_201003 . Write a query against this
table with the following columns:
-The total number of rows, which you can get with COUNT(*)
-The number of unique card numbers
-The total "spend". This value is in a field called total
-The number of unique product descriptions ( description )
One of these return values is going to look pretty weird. See if you can figure out why it's so
weird. Type the answer in a comment in your .sql file.*/

SELECT COUNT(*) AS num_rows
, COUNT(DISTINCT card_no) AS num_cards
, SUM(total) AS total_spend
, COUNT(DISTINCT description) AS num_descriptions
FROM `umt-msba.transactions.transArchive_201001_201003` 

--spend looks strange because we've included a bunch of negative numbers in our aggregation that will need to be selected out

/*4.8 --CORRECT-- Repeat 4.7 but now query across all transactions and report the results at the year level. Your
query should return 8 rows.*/

SELECT EXTRACT(YEAR FROM datetime) AS year
, COUNT(*) AS num_rows
, COUNT(DISTINCT card_no) AS num_cards
, SUM(total) AS total_spend
, COUNT(DISTINCT description) AS num_descriptions
FROM `umt-msba.transactions.transArchive_*` 
GROUP BY year

/*4.9*/ --CORRECT--

SELECT EXTRACT(YEAR FROM datetime) AS year
, ROUND(SUM(total), 2) AS spend 
, COUNT(DISTINCT CONCAT(CAST(EXTRACT(DATE FROM datetime) AS STRING), CAST(register_no AS STRING), CAST(emp_no AS STRING), CAST(trans_no AS STRING))) AS trans 
, SUM(CASE trans_status WHEN "V" THEN -1 WHEN "R" THEN -1 ELSE 1 END) AS items
FROM `umt-msba.transactions.transArchive_*` 
WHERE (department != 0
AND department != 15)
AND (trans_status IS NULL
OR trans_status = "V"
OR trans_status = "R"
OR trans_status = '')
GROUP BY year
ORDER BY year

/*4.10*/ --INCORRECT--CORRECTED

SELECT EXTRACT(DATE FROM datetime) AS date
, EXTRACT(HOUR FROM datetime) AS hour
, ROUND(SUM(total), 2) AS spend 
, COUNT(DISTINCT CONCAT(CAST(EXTRACT(DATE FROM datetime) AS STRING), CAST(register_no AS STRING), CAST(emp_no AS STRING), CAST(trans_no AS STRING))) AS trans
, SUM(CASE trans_status WHEN "V" THEN -1 WHEN "R" THEN -1 ELSE 1 END) AS items
FROM `reese-msba.wedge_transactions.transArchive*` 
WHERE (department != 0
AND department != 15)
AND (trans_status IS NULL
OR trans_status = "V"
OR trans_status = "R"
OR trans_status = '')
GROUP BY date, hour
ORDER BY date DESC, hour DESC









--New Functions
--CONCAT(CAST(EXTRACT(DATE FROM datetime) AS STRING) || CAST(register_no AS STRING) || CAST(emp_no AS STRING) || CAST(trans_no AS STRING))
--CAST(expression AS STRING [format_clause [AT TIME ZONE timezone_expr]])