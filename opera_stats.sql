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
	t1.composer_nationality,
	SUM(t1.performances) AS performance_count,
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2) AS composer_percent
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t1.composer_nationality,
	t2.total_sum
ORDER BY performance_count DESC

-- #1a
-- The above, with an additional column to calculate the rolling percentage of total performances per composer.
	-- Creation of temporary table
DROP TABLE IF EXISTS composer_pareto;
CREATE TEMP TABLE composer_pareto (
	composer VARCHAR(255),
	composer_nationality VARCHAR(255),
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
	t1.composer_nationality,
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t1.composer_nationality,
	t2.total_sum;

	-- Query that returns the rolling percentage
SELECT 
	composer,
	composer_nationality,
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
	t1.composer_nationality,
	t1.work,
	SUM(t1.performances) AS performance_count,
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2) AS work_percent
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer, 
	t1.composer_nationality,
	t1.work,
	t2.total_sum
ORDER BY performance_count DESC

-- #2a
-- The above, with an additional column to calculate the rolling percentage of total performances per work.
	-- Creation of temporary table
DROP TABLE IF EXISTS work_pareto;
CREATE TEMP TABLE work_pareto (
	composer VARCHAR(255),
	composer_nationality VARCHAR(255),
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
	t1.composer_nationality,
	t1.work,
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.composer,
	t1.composer_nationality,
	t1.work,
	t2.total_sum;

	-- Query that returns the rolling percentage
SELECT 
	composer,
	composer_nationality,
	work,
	performance_count,
	work_percent,
	SUM(work_percent) OVER (ORDER BY work_percent DESC) AS rolling_percent
FROM work_pareto
ORDER BY performance_count DESC;

-- #2b
-- Pareto charts with rolling percentages for different composers' works. This is for Mozart.
DROP TABLE IF EXISTS mozart_pareto;
CREATE TEMP TABLE mozart_pareto (
	composer VARCHAR(255),
	work VARCHAR(255),
	performance_count NUMERIC,
	work_percent NUMERIC
);

INSERT INTO mozart_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
WHERE composer = 'Mozart'
)
SELECT 
	t1.composer, 
	t1.work,
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
WHERE composer = 'Mozart'
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
FROM mozart_pareto
ORDER BY performance_count DESC;

-- #2c
-- Same as above but for Wagner
DROP TABLE IF EXISTS wagner_pareto;
CREATE TEMP TABLE wagner_pareto (
	composer VARCHAR(255),
	work VARCHAR(255),
	performance_count NUMERIC,
	work_percent NUMERIC
);

INSERT INTO wagner_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
WHERE composer = 'Wagner,Richard'
)
SELECT 
	t1.composer, 
	t1.work,
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
WHERE composer = 'Wagner,Richard'
GROUP BY 
	t1.composer, 
	t1.work,
	t2.total_sum;

	-- Query that returns rolling percentage
SELECT 
	composer,
	work,
	performance_count,
	work_percent,
	SUM(work_percent) OVER (ORDER BY work_percent DESC) AS rolling_percent
FROM wagner_pareto
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

-- #3a
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

-- #3b
-- Pareto charts with rolling percentages for different nationalities. This is Russia.
DROP TABLE IF EXISTS russia_pareto;
CREATE TEMP TABLE russia_pareto (
	composer VARCHAR(255),
	performance_count NUMERIC,
	composer_percent NUMERIC
);

INSERT INTO russia_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
WHERE composer_nationality = 'Russia'
)
SELECT 
	t1.composer, 
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
WHERE composer_nationality = 'Russia'
GROUP BY 
	t1.composer, 
	t2.total_sum;

	-- Query that returns the rolling percentage
SELECT 
	composer,
	performance_count,
	composer_percent,
	SUM(composer_percent) OVER (ORDER BY composer_percent DESC) AS rolling_percent
FROM russia_pareto
ORDER BY performance_count DESC;

-- #3c
-- Same as above, but for the US. Much more egalitarian
DROP TABLE IF EXISTS us_pareto;
CREATE TEMP TABLE us_pareto (
	composer VARCHAR(255),
	performance_count NUMERIC,
	composer_percent NUMERIC
);

INSERT INTO us_pareto
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
WHERE composer_nationality = 'United States'
)
SELECT 
	t1.composer, 
	SUM(t1.performances),
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2)
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
WHERE composer_nationality = 'United States'
GROUP BY 
	t1.composer, 
	t2.total_sum;

	-- Query that returns the rolling percentage
SELECT 
	composer,
	performance_count,
	composer_percent,
	SUM(composer_percent) OVER (ORDER BY composer_percent DESC) AS rolling_percent
FROM us_pareto
ORDER BY performance_count DESC;

-- #3d
-- Find the top composer from each nationality, along with the percentage of performances that composer gets within their nationality.
SELECT 
	comp.composer_nationality, 
	comp.composer, 
	comp.total_perf_by_comp, 
	nation.total_perf_by_nat, 
	ROUND((comp.total_perf_by_comp::NUMERIC/nation.total_perf_by_nat)*100, 2) AS pct_of_nat
FROM 
	(SELECT 
	 	t3.composer_nationality, 
	 	t3.composer, 
	 	t3.sum_perf total_perf_by_comp
	FROM 
		(SELECT 
			composer_nationality, 
		 	composer, 
		 	SUM(performances) AS sum_perf
		FROM opera_stats
	  	GROUP BY 1, 2) t3
	JOIN 
		(SELECT 
			composer_nationality, 
		 	MAX(sum_perf) max_sum_perf
		FROM 
			(SELECT 
				composer_nationality, 
			 	composer, 
			 	SUM(performances) AS sum_perf
			FROM opera_stats
			GROUP BY 1, 2
			HAVING SUM(performances) > 25) t1
		GROUP BY 1) t2
	ON 
		t2.composer_nationality = t3.composer_nationality 
	 	AND t2.max_sum_perf = t3.sum_perf) comp
JOIN (
	WITH total_performances AS (
	SELECT SUM(performances) total_sum FROM opera_stats
	)
	SELECT 
		t1.composer_nationality, 
		SUM(t1.performances) total_perf_by_nat
	FROM 
		opera_stats t1, 
		(SELECT total_sum FROM total_performances) t2
	GROUP BY 1, t2.total_sum) nation
ON comp.composer_nationality = nation.composer_nationality
ORDER BY 
	pct_of_nat DESC, 
	total_perf_by_nat DESC

-- #4
-- Find the total count of unique works that each composer has had performed
WITH total_works AS (
SELECT COUNT(DISTINCT(work)) total_count FROM opera_stats
)
SELECT 
	t1.composer,
	t1.composer_nationality,
	COUNT(DISTINCT(t1.work)) AS work_count,
	ROUND((COUNT(DISTINCT(t1.work)) * 1.0 / t2.total_count * 100), 2) AS work_percent
FROM 
	opera_stats t1, 
	(SELECT total_count FROM total_works) t2
GROUP BY 
	t1.composer, 
	t1.composer_nationality,
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

-- #5a
-- Find the number and percent of countries where a particular composer is most represented.
WITH country_total AS (
	SELECT COUNT(DISTINCT(performance_country)) countries
	FROM (
		SELECT performance_country, composer, SUM(performances) sum_perf
		FROM opera_stats
		GROUP BY 1,2
		HAVING SUM(performances) > 10
	) sub
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
			GROUP BY 1, 2
			HAVING SUM(performances) > 10) t1
		GROUP BY 1) t2
	ON 
	 	t2.performance_country = t3.performance_country 
		AND t2.max_sum_perf = t3.sum_perf) t4
GROUP BY 
	composer, 
	ct.countries
ORDER BY country_count DESC

-- #6
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

-- #6a
-- Find the number and percent of countries where a particular work is most represented.
WITH country_total AS (
	SELECT COUNT(DISTINCT(performance_country)) countries
	FROM (
		SELECT performance_country, composer, work, SUM(performances) sum_perf
		FROM opera_stats
		GROUP BY 1,2,3
		HAVING SUM(performances) > 10
	) sub
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
			GROUP BY 1, 2, 3
			HAVING SUM(performances) > 10) t1
		GROUP BY 1) t2
	ON 
	 	t2.performance_country = t3.performance_country 
		AND t2.max_sum_perf = t3.sum_perf) t4
GROUP BY 
	composer, 
	work,
	ct.countries
ORDER BY country_count DESC

-- #7
-- Find the average number of performances per work- Output is 49.09.
SELECT AVG(sum_perf)
FROM
	(SELECT 
		composer, 
		work, 
	 	SUM(performances) AS sum_perf
	FROM opera_stats
	GROUP BY 1, 2) t1

-- #7a
-- Find the number of operas per composer that have been performed more than average (49 performances).
SELECT 
	composer, 
	composer_nationality,
	COUNT(work) hits
FROM 
	(SELECT 
	 	composer, 
	 	composer_nationality,
	 	work, 
	 	SUM(performances) AS sum_perf
	FROM opera_stats
	GROUP BY 1, 2, 3
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
GROUP BY 
	composer, 
	composer_nationality
ORDER BY hits DESC

-- #7b
-- Find the "hit rate", or the percentage of total pieces that were performed an above-average number of times out of all the pieces by that composer that were performed at all. Constraint is the composer had to have written more than 4 operas.
SELECT 
	t3.composer,
	t3.composer_nationality,
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
	(SELECT 
	 	composer, 
	 	composer_nationality, 
	 	COUNT(work) hits
	FROM 
		(SELECT 
			composer, 
		 	composer_nationality,
		 	work, 
		 	SUM(performances)
		FROM opera_stats
		GROUP BY 1, 2, 3
		HAVING SUM(performances) > 
			(SELECT AVG(sum_perf)
			FROM
				(SELECT 
					composer, 
					work, 
					SUM(performances) sum_perf
				FROM opera_stats
				GROUP BY 1, 2) t1) 
		) t2
	GROUP BY 1, 2) t3
ON t3.composer = t4.composer
WHERE total_pieces > 4 
GROUP BY 
	t3.composer,
	t3.composer_nationality,
	t3.hits, 
	t4.total_pieces
ORDER BY 
	hit_rate DESC, 
	hits DESC, 
	total_pieces DESC

-- #8
-- Find the gender breakdown of performance counts.
WITH total_performances AS (
SELECT SUM(performances) total_sum FROM opera_stats
)
SELECT 
	t1.gender, 
	SUM(t1.performances) AS performance_count,
	ROUND((SUM(t1.performances) * 1.0 / t2.total_sum * 100), 2) AS gender_percent
FROM 
	opera_stats t1, 
	(SELECT total_sum FROM total_performances) t2
GROUP BY 
	t1.gender, 
	t2.total_sum
ORDER BY performance_count DESC

-- #8a
-- Find the top-performed female composer and how many performances she has
SELECT 
	composer, 
	SUM(performances) sum_perf
FROM opera_stats
WHERE gender = 'f'
GROUP BY composer
ORDER BY sum_perf DESC
LIMIT 1;

-- #8b
-- Find the names of all the composers who have more performances than the most-performed female composer. There are 146 of them
SELECT 
	composer, 
	gender, 
	SUM(performances) performance_count
FROM opera_stats
GROUP BY 
	composer, 
	gender
HAVING 
	SUM(performances) >= (
		SELECT MAX(sum_perf) max_female_perf
		FROM (
			SELECT 
				composer, 
				SUM(performances) sum_perf
			FROM opera_stats
			WHERE gender = 'f'
			GROUP BY composer) t1
	)
ORDER BY performance_count DESC

-- #8c
-- Find the names of all operas that have more performances than the most-performed opera by a female composer. There are 321 of them
SELECT 
	composer, 
	work, 
	gender, 
	SUM(performances) performance_count
FROM opera_stats
GROUP BY 
	composer, 
	work, 
	gender
HAVING 
	SUM(performances) >= (
		SELECT MAX(sum_perf) max_female_perf
		FROM (
			SELECT 
				composer, 
				work,
				SUM(performances) sum_perf
			FROM opera_stats
			WHERE gender = 'f'
			GROUP BY 
				composer, 
				work) t1
	)
ORDER BY 
	performance_count DESC, 
	gender DESC

-- #9
-- Find the total number of works and total number of performances per composer in the same table
SELECT 
	s.composer, 
	c.work_count, 
	s.sum_perf
FROM (
	WITH total_performances AS (
	SELECT SUM(performances) total_sum FROM opera_stats
	)
	SELECT 
		t1.composer, 
		SUM(t1.performances) sum_perf
	FROM 
		opera_stats t1, 
		(SELECT total_sum FROM total_performances) t2
	GROUP BY 
		t1.composer, 
		t2.total_sum) s
JOIN (
	WITH total_count AS (
	SELECT COUNT(DISTINCT(work)) distinct_works FROM opera_stats
	)
	SELECT 
		composer, 
		COUNT(DISTINCT(t1.work)) work_count
	FROM 
		opera_stats t1, 
		(SELECT distinct_works FROM total_count) t2
	GROUP BY 
		composer, 
		t2.distinct_works) c
ON s.composer = c.composer
ORDER BY 
	s.sum_perf DESC, 
	c.work_count DESC, 
	s.composer

-- #10
-- Find each composer's most popular opera, and the % that piece makes up of their total performances. Shows which composers wrote a wide range of popular operas, vs. those that have 1 hit
SELECT 
	comp.composer, 
	piece.work, 
	piece.total_perf_piece, 
	comp.total_perf_comp, 
	ROUND((piece.total_perf_piece::NUMERIC/comp.total_perf_comp)*100, 2) AS pct_of_comp
FROM (
	SELECT 
		t3.composer, 
		t3.work, 
		t3.sum_perf AS total_perf_piece
	FROM (
		SELECT 
			composer, 
			work, 
			SUM(performances) AS sum_perf
		FROM opera_stats
	  	GROUP BY 1,2) t3
	JOIN (
		SELECT 
			composer, 
			MAX(sum_perf) max_sum_perf
		FROM (
			SELECT 
				composer, 
				work, 
				SUM(performances) AS sum_perf
			FROM opera_stats
			GROUP BY 1, 2
			HAVING SUM(performances) > 250) t1
		GROUP BY 1) t2
	ON 
		t2.composer = t3.composer 
		AND t2.max_sum_perf = t3.sum_perf) piece
JOIN (
	WITH total_performances AS (
	SELECT SUM(performances) total_sum FROM opera_stats
	)
	SELECT 
		t1.composer, 
		SUM(t1.performances) total_perf_comp
	FROM 
		opera_stats t1, 
		(SELECT total_sum FROM total_performances) t2
	GROUP BY 1, t2.total_sum) comp
ON comp.composer = piece.composer
ORDER BY 
	pct_of_comp,
	total_perf_comp DESC

