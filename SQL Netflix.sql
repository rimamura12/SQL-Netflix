SELECT*
FROM dbo.netflix_titles;

SELECT COUNT(show_id)
FROM dbo.netflix_titles;

SELECT COUNT(*) AS nullcount
FROM dbo.netflix_titles
WHERE date_added is null;

--number of movies and tv shows--

SELECT COUNT(*) AS type_count, type
FROM dbo.netflix_titles
GROUP BY type;


-- number of rating by type and most common rating for movies and TV shows
SELECT type, rating, COUNT(*) AS rating_count
FROM dbo.netflix_titles
GROUP BY type, rating
ORDER BY COUNT(*) DESC;


SELECT type, MAX(rating) 
FROM dbo.netflix_titles
GROUP BY type;

SELECT type, rating, COUNT(*) AS rating_count, rank() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM dbo.netflix_titles
GROUP BY type, rating;

SELECT type, rating
FROM 
(
SELECT type, rating, COUNT(*) AS rating_count, rank() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM dbo.netflix_titles
GROUP BY type, rating
) AS t1
WHERE ranking = 1;

--list all movies released in year 2020
SELECT*
FROM dbo.netflix_titles;

SELECT*
FROM dbo.netflix_titles
WHERE release_year = '2020' AND
type = 'Movie';

SELECT COUNT(release_year)
FROM dbo.netflix_titles
WHERE release_year = '2020' AND
type = 'Movie';

--Find the top 5 countries with the most content on Netflix
SELECT*
FROM dbo.netflix_titles;

SELECT country, COUNT(country)
FROM dbo.netflix_titles
GROUP BY country;

SELECT country, COUNT(show_id) AS total_content
FROM dbo.netflix_titles
GROUP BY country
ORDER BY COUNT(show_id) DESC;

ALTER TABLE dbo.netflix_titles
ALTER COLUMN country NVARCHAR(MAX);

SELECT TRIM(value) AS new_country_list
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(country, ',');

SELECT TRIM(value) AS new_country_list, COUNT(*) as country_count
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;

SELECT TOP 5 TRIM(value) AS new_country_list, COUNT(*) as country_count
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;


-- find the longest movie
SELECT*
FROM dbo.netflix_titles;

SELECT duration
FROM dbo.netflix_titles
WHERE type = 'Movie'
ORDER BY duration desc;

SELECT 
    LEFT(duration, PATINDEX('%[a-zA-Z]%', duration) - 1) AS time_minutes
FROM 
    dbo.netflix_titles
WHERE 
    type = 'Movie' AND duration IS NOT NULL;

SELECT 
    LEFT(duration, PATINDEX('%[a-zA-Z]%', duration) - 1) AS time_minutes
FROM 
    dbo.netflix_titles
WHERE 
    type = 'Movie' AND duration IS NOT NULL
ORDER BY time_minutes DESC;

SELECT 
    CAST(LEFT(duration, PATINDEX('%[a-zA-Z]%', duration) - 1)AS INT) AS time_minutes
FROM 
    dbo.netflix_titles
WHERE 
    type = 'Movie' AND duration IS NOT NULL
ORDER BY time_minutes DESC;

-- find content added in the last 5 years
SELECT*
FROM dbo.netflix_titles;

SELECT *
FROM dbo.netflix_titles
WHERE date_added >= DATEADD(YEAR, -5, GETDATE());

SELECT count(*)
FROM dbo.netflix_titles
WHERE date_added >= DATEADD(YEAR, -5, GETDATE());

--Find all the movies/tv show directed by director Rajiv Chilaka
SELECT *
FROM dbo.netflix_titles;

SELECT director, count(*) AS director_count
FROM dbo.netflix_titles
GROUP BY director
ORDER BY director_count DESC;

SELECT*
FROM dbo.netflix_titles
WHERE director = 'Rajiv Chilaka';

SELECT*
FROM dbo.netflix_titles
WHERE director LIKE '%Rajiv Chilaka%';

-- List all TV shows with more than 4 seasons
SELECT*
FROM dbo.netflix_titles;

SELECT 
    CAST(LEFT(duration, PATINDEX('%[a-zA-Z]%', duration) - 1)AS INT) AS season_number
FROM 
    dbo.netflix_titles
WHERE 
    type = 'TV Show' AND duration IS NOT NULL;

SELECT title, CAST(LEFT(duration, PATINDEX('%[a-zA-Z]%', duration) - 1)AS INT) AS season_number
FROM dbo.netflix_titles
WHERE 
	type ='TV Show' AND 
	CAST(LEFT(duration, PATINDEX('%[a-zA-Z]%', duration) - 1)AS INT) > 3 AND
	duration IS NOT NULL
ORDER BY season_number DESC;

-- count the number of content items in each genre

SELECT*
FROM dbo.netflix_titles;

SELECT TRIM(value) AS new_genre
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',');

SELECT TRIM(value) AS new_genre, COUNT(*) as genre_count
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;


SELECT TOP 5 TRIM(value) AS new_genre, COUNT(*) as genre_count
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;

-- find each year and average number of content release by United States on netflix. return top 5 year with highest avg content release

SELECT*
FROM dbo.netflix_titles;

SELECT*
FROM dbo.netflix_titles
WHERE country = 'United States';

SELECT*
FROM dbo.netflix_titles
WHERE country LIKE '%United States%';

SELECT count(*)
FROM dbo.netflix_titles
WHERE country LIKE '%United States%';

SELECT 
	YEAR(CAST(date_added AS DATE)) AS year, 
	COUNT(*) as content_released_year
FROM dbo.netflix_titles
WHERE country LIKE '%United States%'
GROUP BY YEAR(CAST(date_added AS DATE))
ORDER BY content_released_year DESC;

SELECT
	TOP 5
	YEAR(CAST(date_added AS DATE)) AS year, 
	COUNT(*) as content_released_year
FROM dbo.netflix_titles
WHERE country LIKE '%United States%'
GROUP BY YEAR(CAST(date_added AS DATE))
ORDER BY content_released_year DESC;

WITH Yearly_Content AS 
(
SELECT 
	YEAR(CAST(date_added AS DATE)) AS year, 
	COUNT(*) as content_released_year
FROM dbo.netflix_titles
WHERE country LIKE '%United States%'
GROUP BY YEAR(CAST(date_added AS DATE))
)

SELECT 
	SUM(content_released_year) AS total_content_released_years
FROM 
(
SELECT 
	content_released_year
FROM Yearly_Content
) 
AS total;


WITH Yearly_Content AS 
(
SELECT 
	YEAR(CAST(date_added AS DATE)) AS year, 
	COUNT(*) as content_released_year
FROM dbo.netflix_titles
WHERE country LIKE '%United States%'
GROUP BY YEAR(CAST(date_added AS DATE))
),
total_content AS
(
SELECT 
	SUM(content_released_year) AS total_content_released_years
FROM Yearly_Content
)
SELECT 
	TOP 5
	yc.year,
    yc.content_released_year,
    ROUND(CAST(yc.content_released_year AS FLOAT) / tc.total_content_released_years * 100, 2) AS percentage
FROM 
    Yearly_Content yc
CROSS JOIN 
    Total_Content tc
ORDER BY percentage DESC;

-- List all movies that are documentaries

SELECT*
FROM dbo.netflix_titles;

SELECT count(*)
FROM dbo.netflix_titles
WHERE listed_in LIKE '%documentaries%' AND
type = 'Movie'
;

SELECT*
FROM dbo.netflix_titles
WHERE listed_in LIKE '%documentaries%' AND
type = 'Movie';

-- find all content without director

SELECT*
FROM dbo.netflix_titles;

SELECT*
FROM dbo.netflix_titles
WHERE director is null;


SELECT COUNT(*)
FROM dbo.netflix_titles
WHERE director is null;

-- find how many movies actress Meryl Streep appeared in the last 10 years

SELECT*
FROM dbo.netflix_titles;

SELECT*
FROM dbo.netflix_titles
WHERE cast LIKE '%Meryl Streep%' AND
date_added >= DATEADD(Year, -10,GETDATE());

--Find the top 10 actors/actresses who have appeared in the highest number of movies produced in the United States

SELECT*
FROM dbo.netflix_titles;

SELECT*
FROM dbo.netflix_titles
WHERE country LIKE '%United States%' AND
type = 'Movie';

SELECT TRIM(value) as new_cast
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country LIKE '%United States%' AND
type = 'Movie';

SELECT TRIM(value) as new_cast, count(*) as num_in_movies
FROM dbo.netflix_titles
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country LIKE '%United States%' AND
type = 'Movie'
GROUP BY TRIM(value)
ORDER BY num_in_movies DESC;

