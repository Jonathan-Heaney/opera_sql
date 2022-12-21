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

