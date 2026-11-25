/* =====================================================================
   CASO ACADEMIA · 07_vistas.sql
   VISTAS, PASO A PASO CON LA PRESENTACIÓN
   ---------------------------------------------------------------------
   Requisito: recargar la base con 01_esquema.sql y 02_datos.sql justo
   antes de empezar, y haber visto 06_subconsultas.sql (algunas vistas
   usan subconsultas).

   Este archivo acompaña las diapositivas de Subconsultas y vistas. Las
   partes van en el mismo orden de la presentación:

     PARTE 1 · Crear y consultar una vista                  (1.1 a 1.3)
     PARTE 2 · Las vistas muestran los datos actuales       (2.1 a 2.3)
     PARTE 3 · Modificar, revisar y eliminar una vista      (3.1 a 3.3)
     PARTE 4 · Guardar datos a través de una vista          (4.1 a 4.3)
     PARTE 5 · Todo junto                                   (5.1 y 5.2)

   Cómo trabajar:
     - Cada parte empieza con un EJEMPLO ya resuelto: es el mismo de la
       diapositiva. Ejecutarlo primero y comparar con el resultado que
       aparece en el comentario.
     - Después vienen los ejercicios, de los más sencillos a los más
       trabajables.
     - Los ejercicios se hacen EN ORDEN: unos usan las vistas y los
       datos que dejaron los anteriores.
     - Escribir la solución debajo de cada enunciado y ejecutarla sola.
     - Las PREGUNTAS se responden con un comentario (-- …) debajo de la
       solución.
     - Este archivo crea vistas y cambia datos. Si algo sale mal, se
       recarga la base (01_esquema.sql y 02_datos.sql, que también
       borran las vistas) y se empieza este archivo de nuevo.

   Tablas: profesores, estudiantes, cursos, matriculas, pagos.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;

-- Workbench bloquea los UPDATE que no filtran por una clave (error
-- 1175). Esta línea lo permite solo durante esta sesión.
SET SQL_SAFE_UPDATES = 0;



/* =====================================================================
   ¿QUÉ ES UNA VISTA?
   ---------------------------------------------------------------------
   Es una consulta guardada en la base de datos con un nombre. Se usa
   como si fuera una tabla (SELECT * FROM nombre_vista), pero NO guarda
   datos: cada vez que se consulta, MySQL ejecuta la consulta guardada
   sobre las tablas reales.

   Para qué sirve:
     - Simplificar: una consulta larga, con JOIN o subconsultas, se
       escribe una vez y se usa con un SELECT corto.
     - Mostrar solo una parte: deja por fuera columnas o filas que no
       todos deben ver.
     - Reutilizar: varias personas o programas usan la misma consulta
       sin repetirla.
   ===================================================================== */



/* =====================================================================
   PARTE 1 · CREAR Y CONSULTAR UNA VISTA
   ---------------------------------------------------------------------
   CREATE VIEW nombre AS
   SELECT ...;                crea la vista con esa consulta.

   Después se consulta como una tabla: con WHERE, ORDER BY, JOIN o
   dentro de una subconsulta.
   ===================================================================== */

-- EJEMPLO  Una vista con los cursos básicos.
CREATE VIEW cursos_basicos AS
SELECT nombre, nivel, precio
FROM cursos
WHERE nivel = 'Básico';

SELECT * FROM cursos_basicos ORDER BY precio;
-- 5 filas: Teoría Musical 90000, Técnica Vocal 140000, Guitarra
-- Acústica 150000, Piano Básico 180000, Violín Inicial 200000.

-- EJEMPLO  Una vista con JOIN: cada curso con su profesor.
CREATE VIEW cursos_con_profesor AS
SELECT c.nombre AS curso, p.nombre AS profesor, c.precio
FROM cursos c
JOIN profesores p ON p.id_profesor = c.id_profesor;

SELECT * FROM cursos_con_profesor WHERE profesor = 'Valentina Ríos';
-- 3 filas: Piano Básico, Piano Intermedio y Piano Avanzado.


-- 1.1  Crear la vista estudiantes_aguachica con el nombre y el teléfono
--      de los estudiantes de Aguachica. Consultarla en orden
--      alfabético.
--      PREGUNTA: ¿qué columnas de la tabla estudiantes no se ven en la
--      vista?


-- 1.2  Crear la vista cursos_baratos con el nombre y el precio de los
--      cursos que cuestan menos de 150000. Consultarla del más caro al
--      más barato.
--      PREGUNTA: el ORDER BY se escribió al consultar, no al crear la
--      vista. ¿Por qué conviene así?


-- 1.3  Más trabajable. Crear la vista inscritos_por_curso con el nombre
--      de cada curso y su cantidad de inscritos, con LEFT JOIN y
--      GROUP BY (deben salir los 11 cursos, también los que tienen 0).
--      Consultarla para ver solo los cursos con más de 5 inscritos, del
--      que más tiene al que menos.



/* =====================================================================
   PARTE 2 · LAS VISTAS MUESTRAN LOS DATOS ACTUALES
   ---------------------------------------------------------------------
   Como la vista ejecuta su consulta cada vez que se usa, cualquier
   cambio en las tablas (INSERT, UPDATE, DELETE) se ve de inmediato en
   la vista, sin tocarla.
   ===================================================================== */

-- EJEMPLO  Se cambia la TABLA y la vista lo refleja sola.
SELECT COUNT(*) FROM cursos_basicos;
-- 5
UPDATE cursos SET nivel = 'Intermedio' WHERE id_curso = 8;
SELECT COUNT(*) FROM cursos_basicos;
-- 4: Teoría Musical ya no es básico y sale de la vista.

-- EJEMPLO  Se devuelve el dato como estaba.
UPDATE cursos SET nivel = 'Básico' WHERE id_curso = 8;
SELECT COUNT(*) FROM cursos_basicos;
-- 5 otra vez.


-- 2.1  Registrar en la tabla estudiantes a Martín Quintero, documento
--      1098032, de Aguachica. Volver a consultar estudiantes_aguachica.
--      PREGUNTA: ¿cuántas filas tenía antes y cuántas ahora? ¿Hubo que
--      cambiar la vista?


-- 2.2  El curso Ensamble Musical sube a 160000. Hacer el cambio en la
--      tabla cursos y volver a consultar cursos_baratos.
--      PREGUNTA: ¿qué curso salió de la vista y por qué?


-- 2.3  Más trabajable. Tomás Navarro se matricula en Violín Inicial.
--      Registrarlo en matriculas sin escribir los ids a mano: buscarlos
--      con subconsultas dentro del VALUES, como en 06_subconsultas.sql.
--      Consultar en inscritos_por_curso solo la fila de Violín Inicial.



/* =====================================================================
   PARTE 3 · MODIFICAR, REVISAR Y ELIMINAR UNA VISTA
   ---------------------------------------------------------------------
   CREATE OR REPLACE VIEW nombre AS SELECT ...;
                         cambia la consulta de una vista que ya existe
                         (o la crea si no existe).
   DROP VIEW nombre;     elimina la vista. Las tablas no se tocan.
   SHOW FULL TABLES;     lista tablas y vistas; la columna Table_type
                         dice BASE TABLE o VIEW.
   SHOW CREATE VIEW nombre;
                         muestra la consulta guardada en la vista.
   Si se usa CREATE VIEW con un nombre que ya existe, sale el error
   1050 (Table '…' already exists).
   ===================================================================== */

-- EJEMPLO  Revisar qué hay en la base y qué guarda una vista.
SHOW FULL TABLES;
SHOW CREATE VIEW cursos_basicos;

-- EJEMPLO  Agregar el cupo máximo a cursos_basicos.
CREATE OR REPLACE VIEW cursos_basicos AS
SELECT nombre, nivel, precio, cupo_maximo
FROM cursos
WHERE nivel = 'Básico';

SELECT * FROM cursos_basicos;
-- 5 filas, ahora con la columna cupo_maximo.

-- EJEMPLO  Eliminar una vista: la tabla cursos sigue igual.
DROP VIEW cursos_con_profesor;


-- 3.1  Ejecutar SHOW FULL TABLES y luego ver con SHOW CREATE VIEW la
--      consulta guardada en cursos_baratos.
--      PREGUNTA: ¿cuántas tablas (BASE TABLE) y cuántas vistas (VIEW)
--      hay? ¿MySQL guardó la consulta tal como se escribió?


-- 3.2  Cambiar cursos_baratos para que muestre los cursos de menos de
--      160000. Probar primero con CREATE VIEW y después con CREATE OR
--      REPLACE VIEW. Consultarla.
--      PREGUNTA: ¿qué pasó con CREATE VIEW? ¿Cuántos cursos muestra
--      ahora?


-- 3.3  Más trabajable. Cambiar inscritos_por_curso para que también
--      muestre el cupo máximo y los cupos libres (cupo máximo menos
--      inscritos). Consultar los cursos que están llenos y luego la
--      fila de Violín Inicial.



/* =====================================================================
   PARTE 4 · GUARDAR DATOS A TRAVÉS DE UNA VISTA
   ---------------------------------------------------------------------
   Si una vista toma columnas de una sola tabla, sin GROUP BY y sin
   funciones de agregación (COUNT, SUM…), se puede
   hacer INSERT, UPDATE o DELETE sobre ella: el cambio se guarda en la
   tabla.
   WITH CHECK OPTION, escrito al final de la vista, impide guardar a
   través de ella filas que la vista no mostraría (que no cumplen su
   WHERE). Si se intenta, sale el error 1369 (CHECK OPTION failed).
   ===================================================================== */

-- EJEMPLO  Un UPDATE por la vista se guarda en la tabla.
UPDATE cursos_basicos SET precio = 95000 WHERE nombre = 'Teoría Musical';
SELECT precio FROM cursos WHERE nombre = 'Teoría Musical';
-- 95000

-- EJEMPLO  Sin WITH CHECK OPTION, una fila se puede "escapar" de la vista.
UPDATE cursos_basicos SET nivel = 'Avanzado' WHERE nombre = 'Teoría Musical';
SELECT COUNT(*) FROM cursos_basicos;
-- 4: el cambio se guardó, pero Teoría Musical ya no se ve en la vista.

-- Se devuelve el curso como estaba.
UPDATE cursos SET nivel = 'Básico', precio = 90000 WHERE nombre = 'Teoría Musical';

-- EJEMPLO  Con WITH CHECK OPTION, la vista no deja que se escape.
CREATE OR REPLACE VIEW cursos_basicos AS
SELECT nombre, nivel, precio, cupo_maximo
FROM cursos
WHERE nivel = 'Básico'
WITH CHECK OPTION;

UPDATE cursos_basicos SET nivel = 'Avanzado' WHERE nombre = 'Teoría Musical';
-- Error 1369: CHECK OPTION failed. El cambio no se guarda.


-- 4.1  Crear la vista estudiantes_ocana (id, documento, nombre y ciudad
--      de los estudiantes de Ocaña), SIN WITH CHECK OPTION. A través de
--      la vista, registrar a Valentina Pacheco, documento 1098033, de
--      Ocaña, y a Óscar Lobo, documento 1098034, de Gamarra. Contar las
--      filas de la vista y buscar a los dos en la tabla estudiantes.
--      PREGUNTA: ¿dónde quedó guardado Óscar? ¿Por qué no aparece en la
--      vista?


-- 4.2  Cambiar estudiantes_ocana para que tenga WITH CHECK OPTION y, a
--      través de ella, intentar registrar a Rosa Ibáñez, documento
--      1098035, de Pelaya.
--      PREGUNTA: ¿qué error sale y qué problema del 4.1 evita?


-- 4.3  Más trabajable. Probar estos dos cambios y leer el error de cada
--      uno:
--        a) UPDATE inscritos_por_curso SET inscritos = 0
--           WHERE curso = 'Piano Básico';
--        b) INSERT INTO estudiantes_aguachica (nombre, telefono)
--           VALUES ('Prueba', '3000000000');
--      PREGUNTA: ¿por qué no se puede ninguno de los dos? (Pista: para
--      el b, revisar qué columnas obligatorias de estudiantes no están
--      en la vista).



/* =====================================================================
   PARTE 5 · TODO JUNTO
   ---------------------------------------------------------------------
   La consulta de una vista puede tener JOIN, GROUP BY y subconsultas,
   y la vista se puede agrupar y filtrar como cualquier tabla.
   COALESCE(valor, 0) devuelve 0 cuando el valor es NULL; sirve, por
   ejemplo, cuando un SUM no encuentra filas.
   ===================================================================== */

-- EJEMPLO  Un reporte de cursos guardado como vista.
CREATE VIEW reporte_cursos AS
SELECT c.nombre AS curso,
       COALESCE(p.nombre, 'Sin profesor') AS profesor,
       COALESCE(SUM(pg.valor), 0) AS recaudado
FROM cursos c
LEFT JOIN profesores p ON p.id_profesor = c.id_profesor
LEFT JOIN pagos pg     ON pg.id_curso = c.id_curso
GROUP BY c.id_curso, c.nombre, p.nombre;

SELECT * FROM reporte_cursos ORDER BY recaudado DESC;
-- 11 filas: de Guitarra Acústica (5460000) a Violín Inicial (0: tiene
-- un inscrito, Tomás, pero ningún pago).

-- La vista se puede agrupar como una tabla: lo recaudado por profesor.
SELECT profesor, SUM(recaudado) AS total
FROM reporte_cursos
GROUP BY profesor
ORDER BY total DESC;
-- 8 filas: Valentina Ríos 11435000 encabeza la lista.


-- 5.1  Crear la vista estudiantes_sin_matricula (nombre y ciudad) con
--      NOT EXISTS. Consultarla.
--      PREGUNTA: Tomás Navarro no tenía matrícula al empezar. ¿Por qué
--      ya no aparece?


-- 5.2  Más trabajable. Crear la vista reporte_estudiantes con el nombre
--      y la ciudad de cada estudiante y su cantidad de cursos, con LEFT
--      JOIN y GROUP BY. Deben salir todos los estudiantes. Con la vista,
--      responder:
--        a) ¿Quiénes están matriculados en más cursos?
--        b) ¿Cuántos estudiantes tienen 0, 1, 2 y 3 cursos?
