/* =====================================================================
   CASO BIBLIOTECA · 01_base_datos.sql — ESQUEMA Y DATOS
   ---------------------------------------------------------------------
   Crea (o reinicia) la base de datos de una biblioteca con sus 5 tablas
   y carga los datos de prueba. Se ejecuta COMPLETO, y se puede volver a
   ejecutar siempre que haga falta dejar la base como al principio.

   El negocio:
     - Cada LIBRO lo escribe un AUTOR (o ninguno conocido, como las
       antologías de cuentos populares).
     - Un SOCIO toma en PRÉSTAMO muchos libros y un libro se presta a
       muchos socios (relación muchos a muchos → tabla prestamos).
     - Mientras el libro no se ha devuelto, fecha_devolucion queda en
       NULL. El plazo de cada préstamo es de 14 días.
     - Un préstamo puede generar MULTAS por retraso, daño o pérdida.

   Los datos traen a propósito algunos casos especiales:
     - Un autor sin libros: Rosa Montero.
     - Un libro sin autor y sin año: Cuentos populares colombianos.
     - Un libro que nunca se ha prestado: Bestiario.
     - Dos socios sin préstamos: Luis Mendoza y Paola Zuleta.
     - Cuatro préstamos sin devolver (fecha_devolucion en NULL).

   ATENCIÓN: borra la base "biblioteca" si ya existe.
   ===================================================================== */

SET NAMES utf8mb4;   -- tildes y ñ correctas también desde la consola

DROP DATABASE IF EXISTS biblioteca;
CREATE DATABASE biblioteca CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE biblioteca;

/* ---------- Tablas ---------- */

CREATE TABLE autores (
    id_autor  INT          PRIMARY KEY AUTO_INCREMENT,
    nombre    VARCHAR(80)  NOT NULL,
    pais      VARCHAR(40)  NOT NULL
);

CREATE TABLE libros (
    id_libro          INT          PRIMARY KEY AUTO_INCREMENT,
    titulo            VARCHAR(100) NOT NULL,
    genero            VARCHAR(20)  NOT NULL,
    anio_publicacion  INT,                            -- NULL: año desconocido
    ejemplares        INT          NOT NULL DEFAULT 1,
    id_autor          INT,                            -- NULL: sin autor conocido
    CONSTRAINT chk_genero     CHECK (genero IN ('Novela', 'Cuento', 'Poesía', 'Memorias')),
    CONSTRAINT chk_ejemplares CHECK (ejemplares > 0),
    CONSTRAINT fk_libro_autor FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

CREATE TABLE socios (
    id_socio          INT           PRIMARY KEY AUTO_INCREMENT,
    documento         VARCHAR(15)   NOT NULL UNIQUE,
    nombre            VARCHAR(100)  NOT NULL,
    email             VARCHAR(100),
    telefono          VARCHAR(15),
    ciudad            VARCHAR(40)   NOT NULL,
    fecha_afiliacion  DATE          NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE prestamos (
    id_prestamo       INT   PRIMARY KEY AUTO_INCREMENT,
    id_socio          INT   NOT NULL,
    id_libro          INT   NOT NULL,
    fecha_prestamo    DATE  NOT NULL DEFAULT (CURRENT_DATE),
    fecha_devolucion  DATE,                           -- NULL: no se ha devuelto
    CONSTRAINT chk_fechas CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_prestamo),
    CONSTRAINT fk_prestamo_socio FOREIGN KEY (id_socio) REFERENCES socios(id_socio),
    CONSTRAINT fk_prestamo_libro FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
);

CREATE TABLE multas (
    id_multa     INT            PRIMARY KEY AUTO_INCREMENT,
    id_prestamo  INT            NOT NULL,
    valor        DECIMAL(10,2)  NOT NULL,
    motivo       VARCHAR(20)    NOT NULL,
    fecha_multa  DATE           NOT NULL,
    CONSTRAINT chk_valor  CHECK (valor > 0),
    CONSTRAINT chk_motivo CHECK (motivo IN ('Retraso', 'Daño', 'Pérdida')),
    CONSTRAINT fk_multa_prestamo FOREIGN KEY (id_prestamo) REFERENCES prestamos(id_prestamo)
);


/* ---------- Datos ---------- */

INSERT INTO autores (id_autor, nombre, pais) VALUES
    (1, 'Gabriel García Márquez', 'Colombia'),
    (2, 'Isabel Allende',         'Chile'),
    (3, 'Jorge Luis Borges',      'Argentina'),
    (4, 'Laura Restrepo',         'Colombia'),
    (5, 'Julio Cortázar',         'Argentina'),
    (6, 'Mario Mendoza',          'Colombia'),
    (7, 'Rosa Montero',           'España');      -- sin libros

INSERT INTO libros (id_libro, titulo, genero, anio_publicacion, ejemplares, id_autor) VALUES
    ( 1, 'Cien años de soledad',              'Novela',   1967, 3, 1),
    ( 2, 'El amor en los tiempos del cólera', 'Novela',   1985, 2, 1),
    ( 3, 'Crónica de una muerte anunciada',   'Novela',   1981, 2, 1),
    ( 4, 'La casa de los espíritus',          'Novela',   1982, 2, 2),
    ( 5, 'Ficciones',                         'Cuento',   1944, 1, 3),
    ( 6, 'El Aleph',                          'Cuento',   1949, 1, 3),
    ( 7, 'Delirio',                           'Novela',   2004, 2, 4),
    ( 8, 'Rayuela',                           'Novela',   1963, 1, 5),
    ( 9, 'Satanás',                           'Novela',   2002, 2, 6),
    (10, 'Cuentos populares colombianos',     'Cuento',   NULL, 1, NULL),   -- sin autor ni año
    (11, 'Bestiario',                         'Cuento',   1951, 1, 5),      -- nunca prestado
    (12, 'Paula',                             'Memorias', 1994, 1, 2);

INSERT INTO socios (id_socio, documento, nombre, email, telefono, ciudad, fecha_afiliacion) VALUES
    ( 1, '1065001', 'Camilo Ospina',     'camilo@gmail.com',   '3001110001', 'Valledupar', '2026-01-15'),
    ( 2, '1065002', 'Mariana Quintero',  'mariana@hotmail.com', '3001110002', 'Valledupar', '2026-01-20'),
    ( 3, '1065003', 'Kevin Arrieta',     NULL,                 '3001110003', 'Aguachica',  '2026-01-22'),
    ( 4, '1065004', 'Daniela Mejía',     'daniela@gmail.com',  NULL,         'Bosconia',   '2026-02-01'),
    ( 5, '1065005', 'Sebastián Royero',  'sebas@gmail.com',    '3001110005', 'Valledupar', '2026-02-03'),
    ( 6, '1065006', 'Valentina Fuentes', 'vale@outlook.com',   '3001110006', 'La Paz',     '2026-02-10'),
    ( 7, '1065007', 'Jesús Maestre',     NULL,                 '3001110007', 'Aguachica',  '2026-02-14'),
    ( 8, '1065008', 'Ángela Baquero',    'angela@gmail.com',   '3001110008', 'Valledupar', '2026-03-01'),
    ( 9, '1065009', 'Luis Mendoza',      'luis@hotmail.com',   '3001110009', 'Bosconia',   '2026-03-05'),   -- sin préstamos
    (10, '1065010', 'Paola Zuleta',      'paola@gmail.com',    '3001110010', 'La Paz',     '2026-05-02');   -- sin préstamos

-- El plazo de cada préstamo es de 14 días.
INSERT INTO prestamos (id_prestamo, id_socio, id_libro, fecha_prestamo, fecha_devolucion) VALUES
    ( 1, 1,  1, '2026-02-02', '2026-02-16'),
    ( 2, 1,  5, '2026-02-02', '2026-02-16'),
    ( 3, 2,  4, '2026-02-05', '2026-02-19'),
    ( 4, 3,  1, '2026-02-10', '2026-03-05'),   -- devuelto tarde
    ( 5, 4,  7, '2026-02-12', '2026-02-26'),
    ( 6, 5,  9, '2026-02-18', '2026-03-02'),
    ( 7, 1,  2, '2026-03-01', '2026-03-15'),
    ( 8, 2,  1, '2026-03-03', '2026-03-17'),
    ( 9, 6,  3, '2026-03-05', '2026-03-30'),   -- devuelto tarde
    (10, 5,  8, '2026-03-08', '2026-03-22'),
    (11, 7,  9, '2026-03-10', '2026-04-15'),   -- devuelto tarde
    (12, 8, 12, '2026-03-15', '2026-03-29'),
    (13, 3,  6, '2026-03-20', '2026-04-03'),
    (14, 2,  7, '2026-04-02', '2026-04-16'),
    (15, 4,  1, '2026-04-05', '2026-04-19'),
    (16, 1,  3, '2026-04-10', NULL),           -- sin devolver
    (17, 6, 10, '2026-04-12', '2026-05-08'),   -- devuelto tarde
    (18, 8,  4, '2026-04-20', NULL),           -- sin devolver
    (19, 5,  2, '2026-05-04', NULL),           -- sin devolver
    (20, 7,  7, '2026-05-06', '2026-05-20'),
    (21, 2,  9, '2026-05-10', '2026-05-24'),
    (22, 3,  1, '2026-05-15', NULL);           -- sin devolver

INSERT INTO multas (id_prestamo, valor, motivo, fecha_multa) VALUES
    ( 4, 15000, 'Retraso', '2026-03-05'),
    ( 6, 30000, 'Daño',    '2026-03-02'),
    ( 9, 10000, 'Retraso', '2026-03-30'),
    (11, 25000, 'Retraso', '2026-04-15'),
    (12, 20000, 'Daño',    '2026-03-29'),
    (17, 12000, 'Retraso', '2026-05-08');

/* ---------- Verificación ---------- */

-- Cantidad de filas por tabla
SELECT 'autores' AS tabla, COUNT(*) AS filas FROM autores
UNION ALL SELECT 'libros',    COUNT(*) FROM libros
UNION ALL SELECT 'socios',    COUNT(*) FROM socios
UNION ALL SELECT 'prestamos', COUNT(*) FROM prestamos
UNION ALL SELECT 'multas',    COUNT(*) FROM multas;
-- Resultado esperado: 7, 12, 10, 22, 6
