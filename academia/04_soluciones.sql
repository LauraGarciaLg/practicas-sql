/* =====================================================================
   CASO ACADEMIA · 04_soluciones.sql — SOLUCIONES (para el docente)
   ---------------------------------------------------------------------
   Una solución posible para cada ejercicio de 03_ejercicios.sql, con el
   resultado esperado en los comentarios.

   - Partes 1 y 2: se ejecutan en orden sobre la base recién cargada.
   - Parte 3: antes de empezarla se recarga la base (01_esquema.sql y
     02_datos.sql) para que los resultados coincidan con los comentarios.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;
SET SQL_SAFE_UPDATES = 0;


/* =====================================================================
   PARTE 1 · DDL
   ===================================================================== */

-- 1.1  La academia quiere registrar sus salas. Crear la tabla "salas" con:
--      id_sala (clave primaria autoincremental), nombre (obligatorio y
--      sin repetirse) y capacidad (obligatoria y mayor que cero, con una
--      restricción llamada chk_capacidad).
CREATE TABLE salas (
    id_sala    INT          PRIMARY KEY AUTO_INCREMENT,
    nombre     VARCHAR(40)  NOT NULL UNIQUE,
    capacidad  INT          NOT NULL,
    CONSTRAINT chk_capacidad CHECK (capacidad > 0)
);
DESCRIBE salas;

-- 1.2  Cada curso se dicta en una sala. Agregar a "cursos" la columna
--      id_sala y la clave foránea fk_curso_sala hacia salas.
ALTER TABLE cursos ADD COLUMN id_sala INT;
ALTER TABLE cursos ADD CONSTRAINT fk_curso_sala
    FOREIGN KEY (id_sala) REFERENCES salas(id_sala);
DESCRIBE cursos;

-- 1.3  Agregar a "estudiantes" la columna acudiente (texto de hasta 80
--      caracteres), ubicada justo después de nombre.
ALTER TABLE estudiantes ADD COLUMN acudiente VARCHAR(80) AFTER nombre;
DESCRIBE estudiantes;

-- 1.4  Hay instrumentos con nombres largos. Ampliar la columna
--      instrumento de "profesores" a 60 caracteres sin perder el NOT NULL.
ALTER TABLE profesores MODIFY instrumento VARCHAR(60) NOT NULL;
DESCRIBE profesores;

-- 1.5  Crear la tabla "asistencias": id_asistencia, id_estudiante,
--      id_curso, fecha y presente (BOOLEAN, por defecto TRUE).
--      Reglas: un estudiante no puede tener dos registros del mismo curso
--      el mismo día, y solo se registra asistencia de quien esté
--      MATRICULADO en ese curso.
--      Pista: la clave foránea apunta a la clave primaria de matriculas.
--      NOTA: La FK compuesta apunta a la PK compuesta de matriculas:
--            solo se registra asistencia de quien está matriculado en ese curso.
CREATE TABLE asistencias (
    id_asistencia  INT      PRIMARY KEY AUTO_INCREMENT,
    id_estudiante  INT      NOT NULL,
    id_curso       INT      NOT NULL,
    fecha          DATE     NOT NULL,
    presente       BOOLEAN  NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_asistencia UNIQUE (id_estudiante, id_curso, fecha),
    CONSTRAINT fk_asis_matricula FOREIGN KEY (id_estudiante, id_curso)
        REFERENCES matriculas(id_estudiante, id_curso)
);
SHOW TABLES;   -- 7 tablas

-- 1.6  Al final se decidió no guardar el acudiente: eliminar esa columna.
ALTER TABLE estudiantes DROP COLUMN acudiente;
DESCRIBE estudiantes;


/* =====================================================================
   PARTE 2 · DML
   ===================================================================== */

-- 2.1  Registrar tres salas: 'Sala Beethoven' (6 personas),
--      'Sala Mozart' (10) y 'Auditorio' (20).
INSERT INTO salas (nombre, capacidad) VALUES
    ('Sala Beethoven', 6),
    ('Sala Mozart',    10),
    ('Auditorio',      20);
SELECT * FROM salas;

-- 2.2  Asignar salas: los cursos de piano a la Sala Beethoven, Teoría
--      Musical al Auditorio y todos los demás a la Sala Mozart.
--      ¿Cuántas filas afectó cada UPDATE?
UPDATE cursos SET id_sala = 1 WHERE nombre LIKE 'Piano%';                     -- 2 filas
UPDATE cursos SET id_sala = 3 WHERE nombre = 'Teoría Musical';                -- 1 fila
UPDATE cursos SET id_sala = 2 WHERE id_sala IS NULL;                          -- 5 filas
SELECT nombre, id_sala FROM cursos;

-- 2.3  Registrar a la estudiante Camila Duarte: documento 1098013,
--      camila@mail.com, 3113334455, Aguachica, nacida el 2009-01-19.
--      No indicar id ni fecha de registro.
--      PREGUNTA: ¿qué valores tomaron esas dos columnas y por qué?
INSERT INTO estudiantes (documento, nombre, email, telefono, ciudad, fecha_nacimiento)
VALUES ('1098013', 'Camila Duarte', 'camila@mail.com', '3113334455', 'Aguachica', '2009-01-19');
SELECT * FROM estudiantes WHERE documento = '1098013';
-- id_estudiante = 13 (AUTO_INCREMENT) y fecha_registro = hoy (DEFAULT)

-- 2.4  Tomás Navarro (id 11) se matricula hoy en Violín Inicial (id 6) y
--      paga la cuota de ingreso (40000) y la primera mensualidad del curso.
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (11, 6);
INSERT INTO pagos (id_estudiante, id_curso, valor, concepto) VALUES
    (11, NULL,  40000, 'Matrícula'),
    (11, 6,    200000, 'Mensualidad');
SELECT * FROM pagos WHERE id_estudiante = 11;

-- 2.5  Ejecutar las tres instrucciones y explicar cada error:
--      a) Matricular de nuevo a Tomás en Violín Inicial.
--      b) Registrar un pago de Tomás de 50000 con concepto 'Donación'.
--      c) Matricular al estudiante 99 en el curso 1.
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (11, 6);
-- Error 1062: Duplicate entry '11-6' for key 'matriculas.PRIMARY'
INSERT INTO pagos (id_estudiante, valor, concepto) VALUES (11, 50000, 'Donación');
-- Error 3819: Check constraint 'chk_concepto' is violated.
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (99, 1);
-- Error 1452: Cannot add or update a child row: a foreign key constraint fails

-- 2.6  Subir 5 % el precio de los cursos de nivel Intermedio.
UPDATE cursos SET precio = precio * 1.05 WHERE nivel = 'Intermedio';          -- 3 filas
SELECT nombre, nivel, precio FROM cursos;
-- Piano Intermedio 231000, Guitarra Eléctrica 178500, Batería Rock 199500

-- 2.7  Asignar a Felipe Arango (profesor 6) el curso Teoría Musical.
UPDATE cursos SET id_profesor = 6 WHERE nombre = 'Teoría Musical';            -- 1 fila

-- 2.8  Daniela Torres (id 3) actualiza sus datos: correo
--      daniela@mail.com y teléfono 3150009988 (en un solo UPDATE).
UPDATE estudiantes SET email = 'daniela@mail.com', telefono = '3150009988'
WHERE id_estudiante = 3;

-- 2.9  Isabel Romero (id 12) se retira de la academia: eliminarla.
--      PREGUNTA: ¿por qué falla el primer intento? ¿Qué hay que borrar
--      antes?
DELETE FROM estudiantes WHERE id_estudiante = 12;
-- Error 1451: Cannot delete or update a parent row: a foreign key constraint fails
DELETE FROM pagos WHERE id_estudiante = 12;                                   -- 1 fila
DELETE FROM estudiantes WHERE id_estudiante = 12;                             -- 1 fila

-- 2.10 Andrés Cárdenas (id 10) cancela Guitarra Eléctrica (id 4):
--      eliminar SOLO esa matrícula.
DELETE FROM matriculas WHERE id_estudiante = 10 AND id_curso = 4;             -- 1 fila
SELECT * FROM matriculas WHERE id_estudiante = 10;                            -- solo el curso 3

-- 2.11 Dejar la estructura como al principio: eliminar asistencias, la
--      columna id_sala de cursos y la tabla salas.
--      PREGUNTA: ¿en qué orden hay que hacerlo y por qué?
DROP TABLE asistencias;
ALTER TABLE cursos DROP FOREIGN KEY fk_curso_sala;
ALTER TABLE cursos DROP COLUMN id_sala;
DROP TABLE salas;
SHOW TABLES;   -- de nuevo las 5 tablas originales


/* =====================================================================
   PARTE 3 · CONSULTAS
   ANTES: recargar la base con 01_esquema.sql y 02_datos.sql.
   ===================================================================== */

-- 3.1  Listar cada profesor con sus cursos: profesor, curso, cupo máximo
--      y precio.
--      PREGUNTA: hay 8 cursos, ¿cuál falta y por qué?
SELECT p.nombre AS 'profesor', c.nombre AS 'curso', c.cupo_maximo, c.precio
FROM cursos c
INNER JOIN profesores p
ON c.id_profesor = p.id_profesor;
-- 7 filas: Teoría Musical no aparece (no tiene profesor)

-- 3.2  Repetir 3.1 de modo que aparezcan TODOS los cursos.
SELECT p.nombre AS 'profesor', c.nombre AS 'curso', c.cupo_maximo, c.precio
FROM cursos c
LEFT JOIN profesores p
ON c.id_profesor = p.id_profesor;
-- 8 filas: Teoría Musical aparece con profesor NULL

-- 3.3  Obtener los 3 mayores pagos: nombre del estudiante, concepto y
--      valor.
SELECT e.nombre, p.concepto, p.valor
FROM pagos p
INNER JOIN estudiantes e
ON p.id_estudiante = e.id_estudiante
ORDER BY p.valor DESC LIMIT 3;
-- Nicolás Acosta 220000 · Samuel Ortega 190000 · Juliana Rueda 190000
-- (los dos de 190000 empatan: pueden salir en cualquier orden)

-- 3.4  Obtener el total pagado por concepto.
SELECT concepto, SUM(valor) AS 'total'
FROM pagos
GROUP BY concepto;
-- Matrícula 440000 · Mensualidad 3030000 · Material 120000

-- 3.5  Igual que 3.4, agregando cuántos pagos hay de cada concepto y
--      ordenando de mayor a menor total.
SELECT concepto, COUNT(*) AS 'cantidad', SUM(valor) AS 'total'
FROM pagos
GROUP BY concepto
ORDER BY total DESC;
-- Mensualidad 20 · Matrícula 11 · Material 3

-- 3.6  Listar los estudiantes con sus cursos matriculados: id y nombre
--      del estudiante, curso, precio, profesor y fecha de matrícula, de la
--      más reciente a la más antigua.
--      PREGUNTA: hay 17 matrículas, ¿por qué salen menos filas?
SELECT e.id_estudiante, e.nombre AS 'estudiante', c.nombre AS 'curso', c.precio,
       p.nombre AS 'profesor', m.fecha_matricula
FROM matriculas m
INNER JOIN estudiantes e
ON m.id_estudiante = e.id_estudiante
INNER JOIN cursos c
ON m.id_curso = c.id_curso
INNER JOIN profesores p
ON c.id_profesor = p.id_profesor
ORDER BY m.fecha_matricula DESC;
-- 13 filas: las 4 matrículas de Teoría Musical se pierden en el
-- último INNER JOIN porque ese curso no tiene profesor.
-- Con LEFT JOIN profesores aparecen las 17.

-- 3.7  Para cada matrícula, mostrar estudiante, curso, fecha de
--      matrícula y el total que ese estudiante ha pagado POR ESE CURSO.
--      Pista: el pago se relaciona con la matrícula por dos columnas.
--      NOTA: El pago se une por estudiante Y curso: unir solo por estudiante
--            mezclaría los pagos de todos sus cursos.
SELECT e.nombre AS 'estudiante', c.nombre AS 'curso', m.fecha_matricula,
       SUM(pa.valor) AS 'total_pagado'
FROM matriculas m
INNER JOIN estudiantes e
ON m.id_estudiante = e.id_estudiante
INNER JOIN cursos c
ON m.id_curso = c.id_curso
INNER JOIN pagos pa
ON pa.id_estudiante = m.id_estudiante AND pa.id_curso = m.id_curso
GROUP BY e.nombre, c.nombre, m.fecha_matricula
ORDER BY m.fecha_matricula DESC;
-- 17 filas. Ana Beltrán · Piano Básico: 395000 (2 mensualidades + material)

-- 3.8  Para cada curso: cupo máximo, cantidad de matriculados y cupos
--      libres. Deben aparecer también los cursos sin estudiantes.
SELECT c.nombre AS 'curso', c.cupo_maximo,
       COUNT(m.id_estudiante) AS 'matriculados',
       c.cupo_maximo - COUNT(m.id_estudiante) AS 'cupos_libres'
FROM cursos c
LEFT JOIN matriculas m
ON c.id_curso = m.id_curso
GROUP BY c.id_curso, c.nombre, c.cupo_maximo
ORDER BY matriculados DESC;
-- Teoría Musical 4 … Violín Inicial 0 (5 cupos libres)

-- 3.9  Listar los estudiantes que no están matriculados en ningún curso.
SELECT e.nombre, e.ciudad
FROM estudiantes e
LEFT JOIN matriculas m
ON e.id_estudiante = m.id_estudiante
WHERE m.id_estudiante IS NULL;
-- Tomás Navarro, Isabel Romero

-- 3.10 Total recaudado por cada profesor (pagos de sus cursos), de mayor
--      a menor.
SELECT pr.nombre AS 'profesor', SUM(pa.valor) AS 'recaudado'
FROM profesores pr
INNER JOIN cursos c
ON c.id_profesor = pr.id_profesor
INNER JOIN pagos pa
ON pa.id_curso = c.id_curso
GROUP BY pr.id_profesor, pr.nombre
ORDER BY recaudado DESC;
-- Jorge Castillo 1110000 · Valentina Ríos 795000 · Natalia Vargas 445000 ·
-- Paola Jiménez 440000. Ricardo Mendoza no aparece: su curso no tiene pagos.
-- Los pagos de 'Matrícula' (id_curso NULL) no cuentan para ningún profesor.

-- 3.11 Ciudades con 3 o más estudiantes y cuántos tiene cada una.
SELECT ciudad, COUNT(*) AS 'estudiantes'
FROM estudiantes
GROUP BY ciudad
HAVING COUNT(*) >= 3
ORDER BY estudiantes DESC;
-- Aguachica 5 · Ocaña 3
