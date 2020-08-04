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