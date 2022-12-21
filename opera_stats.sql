-- Create the table before uploading the dataset to Postgres
CREATE TABLE opera_stats (
	index SERIAL PRIMARY KEY,
	performance_country VARCHAR(255),
	composer VARCHAR(255),
	composer_nationality VARCHAR(255),
	gender VARCHAR(255),
	work VARCHAR(255),
	performances NUMERIC
)

-- #1
-- Find the total performance count and % of total performances for each composer. 
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.composer, 
	SUM(t1.performances) AS performance_count,
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2) AS composer_percent
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t2.total_sum
ORDER BY performance_count DESC

-- #2
-- Find the total performance count and % of total performances for each work. 
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.composer,
	t1.work,
	SUM(t1.performances) AS performance_count,
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2) AS work_percent
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t1.work,
	t2.total_sum
ORDER BY performance_count DESC

-- #3
-- Find the total performance count and % of total performances for each nationality. 
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.composer_nationality,
	SUM(t1.performances) AS performance_count,
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2) AS nationality_percent
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer_nationality, 
	t2.total_sum
ORDER BY performance_count DESC

-- #4
-- Find the total count of unique works that each composer has had performed
WITH total_works AS (
SELECT COUNT(DISTINCT(work)) total_count FROM opera_stats
)
SELECT 
	t1.composer, 
	COUNT(DISTINCT(t1.work)) AS work_count,
	ROUND((COUNT(DISTINCT(t1.work)) * 1.0 / t2.total_count * 100), 2) AS work_percent
FROM 
	opera_stats t1, 
	(SELECT total_count FROM total_works) t2
GROUP BY 
	t1.composer, 
	t2.total_count
ORDER BY work_count DESC

