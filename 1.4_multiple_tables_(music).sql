/*Multiple Tables*/

--0 <create tables> 
CREATE TABLE artists (id INTEGER PRIMARY KEY, name TEXT);

INSERT INTO artists (id, name)
VALUES (1, 'The Beatles');

INSERT INTO artists (id, name)
VALUES (2, 'Elvis Presley');

INSERT INTO artists (id, name)
VALUES (3, 'Michael Jackson');

INSERT INTO artists (id, name)
VALUES (4, 'Madonna');

INSERT INTO artists (id, name)
VALUES (5, 'Elton John');

INSERT INTO artists (id, name)
VALUES (6, 'Led Zeppelin');

INSERT INTO artists (id, name)
VALUES (7, 'Pink Floyd');

CREATE TABLE albums (id INTEGER PRIMARY KEY, name TEXT, artist_id INTEGER, year INTEGER);

COPY albums (id, name, artist_id, year) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/albums.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM artists;
SELECT * FROM albums;
SELECT * FROM tracks;

-- 1
CREATE TABLE tracks (id INTEGER PRIMARY KEY, title TEXT, album_id INTEGER);

-- 2
INSERT INTO tracks (id, title, album_id) 
VALUES (1, 'Smooth Criminal', 8);

-- 3
INSERT INTO tracks (id, title, album_id)
VALUES (2, 'Material Girl', 6);

INSERT INTO tracks (id, title, album_id)
VALUES (3, 'All Together Now', 4);

INSERT INTO tracks (id, title, album_id)
VALUES (4, 'Blank Space', 3);

INSERT INTO tracks (id, title, album_id)
VALUES (5, 'Blue Suede Shoes', 2);

INSERT INTO tracks (id, title, album_id)
VALUES (6, 'P.Y.T. (Pretty Young Thing)', 12);

INSERT INTO tracks (id, title, album_id)
VALUES (7, 'Time', 11);

-- 4
SELECT * FROM tracks
JOIN albums ON
   albums.id = tracks.album_id
ORDER BY album_id;

-- 5
SELECT * FROM albums
LEFT JOIN artists ON
	albums.artist_id = artists.id;

-- 6  
SELECT * FROM artists
LEFT JOIN albums ON
	artists.id = albums.artist_id;
/* Interesting thing to note - left join here will include multiple artist rows if an artist has >1 album */

-- 7
SELECT 
  tracks.title AS song_title,
  albums.name AS album,
  albums.id AS album_id
FROM tracks
LEFT JOIN albums ON
	tracks.album_id = albums.id;
/* again, Postgres does not accept quoted aliases, but SQL Lite does; had to change them here. Also curious, how would I add artists to this? A secondary join?*/