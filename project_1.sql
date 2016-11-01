CREATE TABLE friends (id INTEGER, name TEXT, birthday DATE);

INSERT INTO friends (id, name, birthday) VALUES (1, 'Jane Doe', '1993-05-19');

INSERT INTO friends (id, name, birthday) VALUES (2, 'Danier Kim', '1984-06-22');

INSERT INTO friends (id, name, birthday) VALUES (3, 'Davido Mundo', '1985-05-17');

INSERT INTO friends (id, name, birthday) VALUES (4, 'Cho Mo', '1984-05-30');

UPDATE friends 
SET name = 'Jane Smith'
WHERE id = 1;

ALTER TABLE friends ADD COLUMN
email TEXT;

UPDATE friends
SET email = 'jdoe@example.com'
WHERE id = 1;

UPDATE friends
SET email = 'dkim@example.com'
WHERE id = 2;

UPDATE friends
SET email = 'dmundo@example.com'
WHERE id = 3;

UPDATE friends
SET email = 'cmo@example.com'
WHERE id = 4;

DELETE FROM friends WHERE
name IS 'Jane Smith';

SELECT * FROM friends;
