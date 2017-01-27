/*1.1 SQL Manipulations (friends)*/

CREATE TABLE friends (id INTEGER, name TEXT, birthday TEXT);

INSERT INTO friends (id, name, birthday)
VALUES (1, 'Jane Doe', '1993-05-19');

INSERT INTO friends (id, name, birthday) 
VALUES (2, 'crazy bunz', '1984-01-17');

INSERT INTO friends (id, name, birthday) 
VALUES (3, 'jonny b', '1984-11-20');

INSERT INTO friends (id, name, birthday)
VALUES (4, 'danier', '1984-06-22');

UPDATE friends
SET name = 'Jane Smith'
WHERE name = 'Jane Doe'; 

ALTER TABLE friends ADD COLUMN
email TEXT;

UPDATE friends
SET email = 'jdoe@example.com'
WHERE id = 1;

UPDATE friends
SET email = 'crazy@bunz.com'
WHERE id = 2;

UPDATE friends
SET email = 'under@bruin.com'
WHERE id = 3;

UPDATE friends
SET email = 'danier@bunz.com'
WHERE id = 4;

DELETE FROM friends
WHERE id = 3;

SELECT * FROM friends;