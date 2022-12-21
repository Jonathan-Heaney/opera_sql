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

-- The above, with an additional column to calculate the rolling percentage of total performances per composer.
	-- Creation of temporary table
DROP TABLE IF EXISTS composer_pareto;
CREATE TEMP TABLE composer_pareto (
	composer VARCHAR(255),
	performance_count NUMERIC,
	composer_percent NUMERIC
);

	-- Insertion into temporary table
INSERT INTO composer_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.composer, 
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t2.total_sum

	-- Query that returns the rolling percentage
SELECT 
	composer,
	performance_count,
	composer_percent,
	SUM(composer_percent) OVER (ORDER BY composer_percent DESC) AS rolling_percent
FROM composer_pareto
ORDER BY performance_count DESC;

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

-- The above, with an additional column to calculate the rolling percentage of total performances per work.
	-- Creation of temporary table
DROP TABLE IF EXISTS work_pareto;
CREATE TEMP TABLE work_pareto (
	composer VARCHAR(255),
	work VARCHAR(255),
	performance_count NUMERIC,
	work_percent NUMERIC
);

	-- Insertion into temporary table
INSERT INTO work_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.composer, 
	t1.work,
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t1.work,
	t2.total_sum

	-- Query that returns the rolling percentage
SELECT 
	composer,
	work,
	performance_count,
	work_percent,
	SUM(work_percent) OVER (ORDER BY work_percent DESC) AS rolling_percent
FROM work_pareto
ORDER BY performance_count DESC;

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

-- The above, with an additional column to calculate the rolling percentage of total performances per nationality.
	-- Creation of temporary table
DROP TABLE IF EXISTS nationality_pareto;
CREATE TEMP TABLE nationality_pareto (
	nationality VARCHAR(255),
	performance_count NUMERIC,
	nationality_percent NUMERIC
);

-- Insertion into temporary table
INSERT INTO nationality_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.composer_nationality,
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer_nationality,
	t2.total_sum

	-- Query that returns the rolling percentage
SELECT 
	nationality,
	performance_count,
	nationality_percent,
	SUM(nationality_percent) OVER (ORDER BY nationality_percent DESC) AS rolling_percent
FROM nationality_pareto
ORDER BY performance_count DESC;

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

-- #5
-- Find the most represented composer per country. Includes the restraint that the composer had to have at least 10 performances total.
SELECT 
	t1.performance_country, 
	t1.composer, 
	t1.performance_count
FROM 
	(SELECT 
	 	performance_country, 
	 	composer, 
	 	SUM(performances) AS performance_count
	FROM opera_stats
	GROUP BY 1, 2) t1
JOIN 
	(SELECT 
	  	performance_country, 
	  	MAX(performance_count) max_perf_count
	FROM 
		(SELECT 
			performance_country, 
			composer, 
			SUM(performances) AS performance_count
		FROM opera_stats
		GROUP BY 1, 2
		HAVING SUM(performances) > 10) t2
	GROUP BY 1) t3
ON 
	t1.performance_country = t3.performance_country 
	AND t1.performance_count = t3.max_perf_count 
ORDER BY performance_count DESC

-- #6
-- Find the number and percent of countries where a particular composer is most represented.
WITH country_total AS (
	SELECT COUNT(DISTINCT performance_country) countries
	FROM opera_stats
)
SELECT 
	composer, 
	COUNT(performance_country) AS country_count,
	ROUND((COUNT(performance_country)/ct.countries::numeric)*100, 2) AS composer_percent
FROM 
	(SELECT countries FROM country_total) ct, 
	(SELECT 
	 	t3.performance_country, 
	 	t3.composer, 
		t3.sum_perf
	FROM 
		(SELECT 
			performance_country, 
			composer, 
			SUM(performances) AS sum_perf
		FROM opera_stats
		GROUP BY 1, 2) t3
	JOIN 
		(SELECT 
			performance_country, 
			MAX(sum_perf) max_sum_perf
		FROM 
			(SELECT 
				performance_country, 
			 	composer, 
			 	SUM(performances) AS sum_perf
			FROM opera_stats
			GROUP BY 1, 2) t1
		GROUP BY 1) t2
	ON 
	 	t2.performance_country = t3.performance_country 
		AND t2.max_sum_perf = t3.sum_perf) t4
GROUP BY 
	composer, 
	ct.countries
ORDER BY country_count DESC

-- #7
-- Find the most represented work per country. Includes the restraint that the work had to have at least 10 performances total.
SELECT 
	t1.performance_country, 
	t1.composer, 
	t1.work,
	t1.performance_count
FROM 
	(SELECT 
	 	performance_country, 
	 	composer,
	 	work,
	 	SUM(performances) AS performance_count
	FROM opera_stats
	GROUP BY 1, 2, 3) t1
JOIN 
	(SELECT 
	  	performance_country, 
	  	MAX(performance_count) max_perf_count
	FROM 
		(SELECT 
			performance_country, 
			composer,
		 	work,
			SUM(performances) AS performance_count
		FROM opera_stats
		GROUP BY 1, 2, 3
		HAVING SUM(performances) > 10) t2
	GROUP BY 1) t3
ON 
	t1.performance_country = t3.performance_country 
	AND t1.performance_count = t3.max_perf_count 
ORDER BY performance_count DESC

-- #8
-- Find the number and percent of countries where a particular work is most represented.
WITH country_total AS (
	SELECT COUNT(DISTINCT performance_country) countries
	FROM opera_stats
)
SELECT 
	composer,
	work,
	COUNT(performance_country) AS country_count,
	ROUND((COUNT(performance_country)/ct.countries::numeric)*100, 2) AS work_percent
FROM 
	(SELECT countries FROM country_total) ct, 
	(SELECT 
	 	t3.performance_country, 
	 	t3.composer,
	 	t3.work,
		t3.sum_perf
	FROM 
		(SELECT 
			performance_country, 
			composer, 
		 	work,
			SUM(performances) AS sum_perf
		FROM opera_stats
		GROUP BY 1, 2, 3) t3
	JOIN 
		(SELECT 
			performance_country, 
			MAX(sum_perf) max_sum_perf
		FROM 
			(SELECT 
				performance_country, 
			 	composer,
			 	work,
			 	SUM(performances) AS sum_perf
			FROM opera_stats
			GROUP BY 1, 2, 3) t1
		GROUP BY 1) t2
	ON 
	 	t2.performance_country = t3.performance_country 
		AND t2.max_sum_perf = t3.sum_perf) t4
GROUP BY 
	composer, 
	work,
	ct.countries
ORDER BY country_count DESC

-- #9
-- Find the average number of performances per work- Output is 49.09.
SELECT AVG(sum_perf)
FROM
	(SELECT 
		composer, 
		work, 
	 	SUM(performances) AS sum_perf
	FROM opera_stats
	GROUP BY 1, 2) t1

-- #10 
-- Find the number of operas per composer that have been performed more than average (49 performances).
SELECT 
	composer, 
	COUNT(work) hits
FROM 
	(SELECT 
	 	composer, 
	 	work, 
	 	SUM(performances) AS sum_perf
	FROM opera_stats
	GROUP BY 1, 2
	HAVING SUM(performances) > 
		(SELECT AVG(sum_perf)
		FROM
			(SELECT 
				composer, 
			 	work, 
			 	SUM(performances) AS sum_perf
			FROM opera_stats
			GROUP BY 1, 2) t1) 
		) t2
GROUP BY composer
ORDER BY hits DESC

-- #11
-- Find the "hit rate", or the percentage of total pieces that were performed an above-average number of times out of all the pieces by that composer that were performed at all. Constraint is the composer had to have written more than 4 operas.
SELECT 
	t3.composer, 
	t3.hits, 
	t4.total_pieces, 
	ROUND((t3.hits::numeric/t4.total_pieces::numeric)*100, 2) AS hit_rate
FROM
	(SELECT 
	 	composer, 
	 	COUNT(DISTINCT(work)) total_pieces
	FROM opera_stats
	GROUP BY 1
	ORDER BY 2 DESC) t4
JOIN 
	(SELECT composer, COUNT(*) hits
	FROM 
		(SELECT 
			composer, 
		 	work, 
		 	SUM(performances)
		FROM opera_stats
		GROUP BY 1, 2
		HAVING SUM(performances) > 
			(SELECT AVG(sum)
			FROM
				(SELECT 
					composer, 
					work, 
					SUM(performances) sum
				FROM opera_stats
				GROUP BY 1, 2) t1) 
		) t2
	GROUP BY 1) t3
ON t3.composer = t4.composer
WHERE total_pieces > 4 
GROUP BY 
	t3.composer, 
	t3.hits, 
	t4.total_pieces
ORDER BY 
	hit_rate DESC, 
	hits DESC, 
	total_pieces DESC

-- #12

