-- ============================================================
-- Movie_DB_App - 7 Management Queries (JOIN, GROUP BY, etc.)
-- Run in Supabase SQL Editor. Copy outputs to report.
-- ============================================================

-- Q1: Movies with director + genre + avg rating (JOIN + ORDER BY)
SELECT m.movie_id, m.title, m.release_year,
       d.full_name AS director, g.genre_name AS genre,
       m.avg_rating, COUNT(r.review_id) AS review_count
FROM movies m
LEFT JOIN directors d ON d.director_id = m.director_id
LEFT JOIN genres g ON g.genre_id = m.genre_id
LEFT JOIN reviews r ON r.movie_id = m.movie_id
GROUP BY m.movie_id, m.title, m.release_year, d.full_name, g.genre_name, m.avg_rating
ORDER BY m.avg_rating DESC, m.title;

-- Q2: Movie count per genre (JOIN + GROUP BY + COUNT)
SELECT g.genre_name, COUNT(m.movie_id) AS movie_count
FROM genres g
LEFT JOIN movies m ON m.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY movie_count DESC;

-- Q3: Average rating per director (JOIN + AVG + HAVING)
SELECT d.full_name AS director,
       COUNT(m.movie_id) AS movies_directed,
       ROUND(AVG(m.avg_rating),2) AS avg_director_rating
FROM directors d
LEFT JOIN movies m ON m.director_id = d.director_id
GROUP BY d.full_name
HAVING COUNT(m.movie_id) > 0
ORDER BY avg_director_rating DESC;

-- Q4: Top 5 most reviewed movies (subquery + COUNT + LIMIT)
SELECT m.title, sub.review_count, sub.avg_given
FROM movies m
JOIN (
  SELECT movie_id, COUNT(*) AS review_count, ROUND(AVG(rating),2) AS avg_given
  FROM reviews
  GROUP BY movie_id
) sub ON sub.movie_id = m.movie_id
ORDER BY sub.review_count DESC, sub.avg_given DESC
LIMIT 5;

-- Q5: Active customers with >1 review (JOIN + GROUP BY + HAVING)
SELECT u.username, u.full_name, COUNT(r.review_id) AS total_reviews,
       ROUND(AVG(r.rating),2) AS avg_given
FROM users u
JOIN user_groups ug ON ug.group_id = u.group_id
JOIN reviews r ON r.user_id = u.user_id
WHERE ug.group_name = 'customer'
GROUP BY u.username, u.full_name
HAVING COUNT(r.review_id) >= 1
ORDER BY total_reviews DESC;

-- Q6: Movies with NO reviews (LEFT JOIN / NOT EXISTS)
SELECT m.movie_id, m.title, m.release_year
FROM movies m
LEFT JOIN reviews r ON r.movie_id = m.movie_id
WHERE r.review_id IS NULL;

-- Q7: Overall statistics for management (SUM, AVG, COUNT)
SELECT
  (SELECT COUNT(*) FROM movies) AS total_movies,
  (SELECT COUNT(*) FROM users) AS total_users,
  (SELECT COUNT(*) FROM reviews) AS total_reviews,
  (SELECT ROUND(AVG(avg_rating),2) FROM movies) AS overall_avg_movie_rating,
  (SELECT ROUND(AVG(rating),2) FROM reviews) AS overall_avg_given_rating,
  (SELECT SUM(duration_minutes) FROM movies) AS total_minutes_catalog;
