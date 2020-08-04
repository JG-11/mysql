DROP DATABASE IF EXISTS library;

CREATE DATABASE IF NOT EXISTS library;

SHOW DATABASES;

USE library;

SELECT DATABASE();

--Storage engines: https://dev.mysql.com/doc/refman/8.0/en/storage-engines.html
SHOW ENGINES \G

CREATE TABLE IF NOT EXISTS books (
    book_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    author_id INTEGER UNSIGNED,
    title VARCHAR(100) NOT NULL,
    `year` INTEGER UNSIGNED NOT NULL DEFAULT 1900,
    language VARCHAR(2) NOT NULL DEFAULT 'es' COMMENT 'ISO 639-1 Language',
    cover_url VARCHAR(500),
    price DOUBLE(6,2) NOT NULL DEFAULT 10.0,
    sellable TINYINT(1) DEFAULT 1,
    copies INTEGER NOT NULL DEFAULT 1,
    description TEXT  
);

CREATE TABLE IF NOT EXISTS authors (
    author_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    nationality VARCHAR(3)
);

DESCRIBE books;

DESC authors;

SHOW FULL COLUMNS FROM books;

SHOW FULL COLUMNS FROM books \G

CREATE TABLE IF NOT EXISTS clients (
    client_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    birthdate DATETIME,
    gender ENUM('M', 'F', 'ND') NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

SHOW FULL COLUMNS FROM clients \G

CREATE TABLE IF NOT EXISTS operations (
    operation_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    client_id INTEGER UNSIGNED,
    book_id INTEGER UNSIGNED,
    `type` ENUM('Prestado', 'Devuelto', 'Vendido') NOT NULL,
    finished TINYINT(1) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DESC operations;

--INSERT
INSERT INTO authors(author_id, name, nationality)
VALUES(NULL, 'Juan Rulfo', 'MEX');

INSERT INTO authors(name, nationality)
VALUES('Gabriel García Márquez', 'COL');

INSERT INTO authors
VALUES(NULL, 'Juan Gabriel Vásquez', 'COL');

--Chunks
INSERT INTO authors(name, nationality)
VALUES('Isabel Allende', 'CHL'),
    ('Julio Cortázar', 'ARG'),
    ('Pablo Neruda', 'CHL');

INSERT INTO authors SET name = 'Carlos Fuentes', nationality = 'MEX';


INSERT INTO clients (name, email, birthdate, gender, active)
VALUES ('Martita Forrestall', 'mforrestall0@weibo.com', '1997-08-08', 'F', 1),
    ('Car Rolph', 'crolph1@indiegogo.com', '1974-05-06', 'M', 1),
    ('Giorgi Rolfi', 'grolfi2@scribd.com', '2015-08-13', 'M', 0),
    ('Marcy Marquis', 'mmarquis3@livejournal.com', '1995-06-26', 'F', 1),
    ('Innis Charity', 'icharity4@wp.com', '2007-08-07', 'M', 0),
    ('Leo Romer', 'lromer5@addtoany.com', '1981-04-29', 'M', 1),
    ('Drake Biaggioli', 'dbiaggioli6@prnewswire.com', '2002-07-07', 'M', 1),
    ('Wallis Drane', 'wdrane7@omniture.com', '1972-09-15', 'M', 0),
    ('Jonas Paffitt', 'jpaffitt8@phoca.cz', '2009-05-10', 'M', 1),
    ('Hartwell Degoe', 'hdegoe9@lycos.com', '1995-03-02', 'M', 1);

--ON DUPLICATE KEY
--ON DUPLICATE KEY IGNORE ALL -> Disappear all errors
INSERT INTO clients (name, email, birthdate, gender, active)
VALUES ('Hartwell Degoe', 'hdegoe9@lycos.com', '1995-03-02', 'M', 0)
ON DUPLICATE KEY UPDATE active = VALUES(active);


SELECT author_id FROM authors WHERE name = 'Pablo Neruda';
INSERT INTO books(author_id, title) VALUES(6, 'Cien sonetos de amor');

--Nested queries -> Subquery
INSERT INTO books(author_id, title) VALUES(
    (SELECT author_id FROM authors WHERE name = 'Pablo Neruda' LIMIT 1),
    'Confieso que he vivido');

/*
    Bash and SQL files
    mysql -u root -p -h localhost -D library < data.sql
*/

--SELECT 
SELECT name FROM clients;

SELECT name FROM clients LIMIT 2;

SELECT name, email FROM clients WHERE gender = 'M';
SELECT name, email FROM clients WHERE gender = 'F';

--Functions
SELECT name, YEAR(birthdate) FROM clients LIMIT 5;

--Current laptop datetime
SELECT NOW();
SELECT YEAR(NOW());

SELECT name, YEAR(NOW()) - YEAR(birthdate) FROM clients;

SELECT name, YEAR(NOW()) - YEAR(birthdate) AS age FROM clients
WHERE name LIKE 'M%' AND gender = 'F';

/* 
    MySQL provides two wildcard characters for constructing patterns:
    % -> Matches any string of zero or more characters
    _ -> Matches any single character

    Source: https://www.mysqltutorial.org/mysql-like/
*/

SELECT COUNT(*) FROM authors;
SELECT COUNT(*) FROM books;

SELECT name FROM authors WHERE author_id > 0 AND author_id < 6;

SELECT * FROM books;

--BETWEEN recommended for numbers and dates
SELECT * FROM books WHERE author_id BETWEEN 1 AND 5;

INSERT INTO books(author_id, title)
VALUES(2, 'Cien años de soledad'),
    (2, 'El amor en los tiempos del cólera');

INSERT INTO books(author_id, title)
VALUES(1, 'Pedro Páramo'),
    (1, 'El llano en llamas');


--JOIN
SELECT books.title, authors.name
FROM books JOIN authors ON books.author_id = authors.author_id;

--Multiple INNER JOIN
SELECT b.title, a.name, c.name, o.type
FROM operations AS o
JOIN clients AS c ON o.client_id = c.client_id
JOIN books AS b ON o.book_id = b.book_id
JOIN authors AS a ON b.author_id = a.author_id;

--Unexplicit JOIN
SELECT a.name, b.title
FROM authors AS a, books AS b
WHERE b.author_id = a.author_id;

--Explicit JOIN
SELECT a.name, b.title
FROM authors AS a
JOIN books AS b ON b.author_id = a.author_id;

--Left JOIN (pretty useful to know when data does not exist)
SELECT a.author_id, a.name, a.nationality, COUNT(b.book_id)
FROM authors AS a
LEFT JOIN books AS b
ON a.author_id = b.author_id
GROUP BY a.author_id
ORDER BY a.author_id DESC;


/*
    Other JOINs:
        1. Right Join
        2. Full Outer Join
        3. Left Excluding Join
        4. Right Exluding Join
        5. Outer Excluding Join
*/

/* 
    Business questions
    1. ¿Qué nacionalidades hay?
*/
SELECT DISTINCT nationality FROM authors ORDER BY nationality;

/*
    2. ¿Cuántos escritores hay de cada nacionalidad?
*/
SELECT nationality, COUNT(author_id) AS c_authors FROM authors
GROUP BY nationality
ORDER BY c_authors DESC, nationality;

/*
    3. ¿Cuántos libros hay de cada nacionalidad?
*/
SELECT a.nationality, COUNT(b.book_id) FROM authors AS a
JOIN books AS b ON a.author_id = b.author_id
GROUP BY a.nationality;

/*
    4. ¿Cuál es el promedio y desviación estándar del precio de los libros?
*/ 
SELECT AVG(price) AS average, STDDEV(price) AS standard_deviation FROM books;

/*
    5. ídem, pero por nacionalidad
*/
SELECT a.nationality, AVG(b.price) AS average, STDDEV(b.price) AS standard_deviation FROM books AS b
JOIN authors AS a ON a.author_id = b.author_id
GROUP BY a.nationality
ORDER BY a.nationality;

/* 
    6. ¿Cuál es el precio máximo y minímo de un libro?
*/
SELECT MAX(price), MIN(price) FROM books;

/*
    7. ídem, pero por nacionalidad
*/
SELECT nationality, MAX(price), MIN(price) FROM books AS b
JOIN authors AS a ON a.author_id = b.author_id
GROUP BY nationality;

--Operations report
SELECT c.name, o.type, b.title, CONCAT(a.name, ' (', a.nationality, ')') AS author, TO_DAYS(NOW()) - TO_DAYS(o.created_at) AS ago
FROM operations AS o
LEFT JOIN clients AS c ON o.client_id = c.client_id 
LEFT JOIN books AS b ON o.book_id = b.book_id
LEFT JOIN authors AS a ON b.author_id = a.author_id;

--DELETE
BEGIN; --We start the transaction
DELETE FROM clients WHERE client_id = 9 LIMIT 1;
ROLLBACK; --We revert the transaction. We can use commit instead

--UPDATE
UPDATE clients SET active = 1 WHERE client_id = 10;
UPDATE books SET `year`= 1950 WHERE book_id = 1;
UPDATE books SET `year`= 1970 WHERE book_id = 2;
UPDATE books SET `year`= 2010 WHERE book_id = 3;
UPDATE books SET `year`= 2005 WHERE book_id = 4;
UPDATE books SET `year`= 1940 WHERE book_id = 5;

--TRUNCATE (delete table content)
TRUNCATE operations;

--Super query (add intelligence to columns) 
SELECT nationality, COUNT(book_id) AS total, SUM(IF(year <= 1950, 1, 0)) AS '<=1950',
    SUM(IF(year > 1950 AND year <= 2000, 1, 0)) AS '<=2000',
    SUM(IF(year > 2000, 1, 0)) AS '>2000'
FROM books
JOIN authors ON books.author_id = authors.author_id
GROUP BY nationality;
