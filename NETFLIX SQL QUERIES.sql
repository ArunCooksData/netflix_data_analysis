-- Netflix Data Analysis using SQL

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


select * from netflix 

-- Solutions of 15 business problems

-- 1. Count the number of Movies vs TV Shows

SELECT 
	typess,
	COUNT(*)
FROM netflix
GROUP BY 1



-- 2. Find the most common rating for movies and TV shows

with my_cte as
(
select typess,rating,count(rating) rating_count,rank() over (partition by typess order by count(rating) desc) as rankk
from netflix
group by 1,2
)
select typess,rating,rating_count from my_cte
where rankk = 1

-----

WITH RatingCounts AS (
    SELECT 
        typess,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY typess, rating
),
RankedRatings AS (
    SELECT 
        typess,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY typess ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    typess,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE typess = 'Movie' and release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Identify the longest movie

SELECT *
FROM netflix
WHERE typess = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC

--

SELECT *
FROM netflix
WHERE typess = 'Movie' and duration = (select max(duration) from netflix)
ORDER BY duration DESC


-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM
(SELECT *,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM netflix
)
WHERE director_name = 'Rajiv Chilaka'

---

select * from netflix
where director like '%Rajiv Chilaka%'

---

select * from netflix
where director ilike '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	typess = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		
		COUNT(show_id)::numeric/
		(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- 11. List all movies that are documentaries


SELECT 
    release_year, 
    COUNT(show_id) AS total_release,
    AVG(COUNT(show_id)) OVER () AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY total_release DESC
LIMIT 5;

	
-----

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List All Movies that are Documentaries

select * 
from netflix
where typess = 'Movie' and listed_in like '%Documentaries%'


-- 12 . Find All Content Without a Director

select * from netflix
where director is null

-- 13 . Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select count(show_id) 
from netflix
where casts like '%Prabhas%' and  release_year > CURRENT_DATE - INTERVAL '10 years';


-- 

select count(show_id)
from netflix
where casts like '%Prabhas%' and release_year > extract(year from current_date)- 10 



-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select unnest(string_to_array(casts,',')) as Actor,count(title)as acted_count
from netflix
where country = 'India'
group by 1
order by 2 desc
limit 10


-- 15 . Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT *,
       CASE 
           WHEN description LIKE '%kill%' OR description LIKE '%Violence%' THEN 'BAD'
           ELSE 'GOOD'
       END AS Warning
FROM netflix;

