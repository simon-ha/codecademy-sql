/*1.2 SQL Queries (movies)*/

CREATE TABLE movies (id INTEGER PRIMARY KEY, name TEXT, genre TEXT, year INTEGER, imdb_rating REAL);

COPY movies (id, name, genre, year, imdb_rating) 
FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/movies.csv' DELIMITER ',' CSV HEADER;
/* Weird thing I found out - must save file in MS Excel as .csv (MS-DOS), and NOT .csv (comma-separated)*/

SELECT * FROM movies;

SELECT DISTINCT year FROM movies
ORDER BY year ASC;

SELECT * FROM movies
WHERE genre = 'drama';

SELECT * FROM movies
WHERE name LIKE '%Bride%';
/* um interesting ^ had to change 'bride' to 'Bride' - it's case sensitive? */

SELECT * FROM movies
WHERE year BETWEEN 2000 AND 2015;
/* BETWEEN x AND y */

SELECT * FROM movies
WHERE year = 1995 OR imdb_rating = 9;

SELECT name, imdb_rating FROM movies
WHERE year > 2009
ORDER BY name;

SELECT * FROM movies
WHERE imdb_rating = 7
LIMIT 3;

SELECT * FROM movies
WHERE imdb_rating > 6
AND genre = 'comedy'
AND year > 1995
ORDER BY imdb_rating DESC
LIMIT 10;

SELECT * FROM movies
WHERE name = 'Cast Away';

SELECT * FROM movies
WHERE imdb_rating != 7;

SELECT * FROM movies
WHERE genre = 'horror'
AND imdb_rating < 6;

SELECT * FROM movies
WHERE imdb_rating > 8
ORDER BY genre
LIMIT 10;

SELECT * FROM movies
WHERE name LIKE '%King%';

SELECT * FROM movies
WHERE name LIKE '%Out';

SELECT * FROM movies
WHERE name LIKE 'The%'
ORDER BY imdb_rating DESC;

SELECT * FROM movies;

SELECT name, id FROM movies
WHERE id > 125;

SELECT * FROM movies
WHERE name LIKE 'X-Men%';

SELECT * FROM movies
ORDER BY name DESC
LIMIT 10;

SELECT id, name, genre FROM movies
WHERE genre = 'romance';

SELECT * FROM movies
WHERE name LIKE '%Twilight%'
ORDER BY year ASC;

SELECT * FROM movies
WHERE year = 2012
AND genre = 'comedy';