/* =====================================================================
   CASO BIBLIOTECA · 02_subconsultas.sql
   SUBCONSULTAS
   ---------------------------------------------------------------------
   Requisito: haber ejecutado 01_base_datos.sql.

     PARTE 1 · Subconsulta que devuelve un solo valor   (1.1 a 1.3)
     PARTE 2 · IN y NOT IN                              (2.1 a 2.3)
     PARTE 3 · EXISTS y NOT EXISTS                      (3.1 a 3.3)
     PARTE 4 · Subconsulta en el SELECT                 (4.1 y 4.2)
     PARTE 5 · Subconsulta en el FROM                   (5.1 y 5.2)
     PARTE 6 · Todo junto                               (6.1)

   Cómo trabajar:
     - Cada parte empieza con un recuadro que explica la instrucción.
       Leerlo antes de empezar los ejercicios.
     - En cada parte, los primeros ejercicios son sencillos y el último
       es más elaborado.
     - Escribir la solución debajo de cada enunciado y ejecutarla sola.
     - Las PREGUNTAS se responden con un comentario (-- …) debajo de la
       solución.
     - Este archivo solo consulta: no cambia la base.

   Entrega: este mismo archivo con las soluciones y las respuestas.
   Tablas: autores, libros, socios, prestamos, multas.
   ===================================================================== */

SET NAMES utf8mb4;
USE biblioteca;



/* =====================================================================
   ¿QUÉ ES UNA SUBCONSULTA?
   ---------------------------------------------------------------------
   Una subconsulta es un SELECT escrito dentro de otra consulta, entre
   paréntesis. Sirve para resolver en un solo paso preguntas que
   necesitan un dato que primero hay que calcular. Por ejemplo, "¿qué
   cursos cuestan más que el promedio?" necesita calcular el promedio
   antes de comparar.

   Según lo que devuelve, la subconsulta se usa de forma distinta:
     - Un solo valor (una fila, una columna):  se compara con =, >, <…
     - Una lista de valores (una columna):     se usa con IN / NOT IN.
     - Filas o ninguna:                        se usa con EXISTS.
     - Una tabla completa:                     se usa en el FROM.

   Y según dónde se escribe:
     - En el WHERE o el HAVING: para filtrar.
     - En el SELECT: para calcular una columna.
     - En el FROM: como si fuera una tabla.
   ===================================================================== */



/* =====================================================================
   PARTE 1 · SUBCONSULTA QUE DEVUELVE UN SOLO VALOR
   ---------------------------------------------------------------------
   Es la más sencilla: devuelve un solo dato, casi siempre el resultado
   de AVG, MIN, MAX, SUM o COUNT. MySQL la ejecuta primero y usa ese
   valor en el WHERE como si fuera un número escrito a mano.
   Ejemplo:  SELECT nombre, precio FROM cursos
             WHERE precio > (SELECT AVG(precio) FROM cursos);
   Si la subconsulta devuelve más de una fila, sale el error 1242
   (Subquery returns more than 1 row).
   ===================================================================== */

-- 1.1  Mostrar el título y los ejemplares de los libros que tienen más
--      ejemplares que el promedio de todos los libros.
--      PREGUNTA: ¿por qué es mejor usar la subconsulta que calcular el
--      promedio aparte y escribir el número en el WHERE?


-- 1.2  Mostrar el título y el año del libro más antiguo, usando una
--      subconsulta con MIN.
--      PREGUNTA: probar WHERE anio_publicacion = MIN(anio_publicacion),
--      sin subconsulta. ¿Qué error sale y por qué?


-- 1.3  Mostrar las multas cuyo valor supera el promedio de las multas,
--      con el nombre del socio, el título del libro, el motivo y el
--      valor, de la más alta a la más baja.
--      (Las multas llegan a socios y libros a través de prestamos).



/* =====================================================================
   PARTE 2 · IN Y NOT IN
   ---------------------------------------------------------------------
   Cuando la subconsulta devuelve una LISTA de valores (una columna con
   varias filas), no se puede comparar con =. Se usa:
     IN       el valor está en la lista.
     NOT IN   el valor no está en la lista.
   Ejemplo:  SELECT nombre FROM estudiantes
             WHERE id_estudiante IN (SELECT id_estudiante FROM matriculas);
   Muchas consultas con IN también se pueden resolver con JOIN; IN se
   lee más fácil cuando solo se necesita filtrar.
   ===================================================================== */

-- 2.1  Mostrar los títulos de los libros de autores colombianos.


-- 2.2  Mostrar los libros que nunca se han prestado.


-- 2.3  Mostrar los autores que no tienen ningún libro, con NOT IN.
--      PREGUNTA: Rosa Montero no tiene libros, pero la consulta no la
--      muestra. ¿Por qué? (Pista: revisar la columna id_autor de los
--      libros). Corregir la consulta para que funcione.



/* =====================================================================
   PARTE 3 · EXISTS Y NOT EXISTS
   ---------------------------------------------------------------------
   EXISTS (subconsulta)       verdadero si la subconsulta devuelve al
                              menos una fila.
   NOT EXISTS (subconsulta)   verdadero si no devuelve ninguna.
   No importa qué columnas devuelva; por eso se escribe SELECT 1.

   La subconsulta usa una columna de la consulta de afuera (por ejemplo
   c.id_curso), así que se evalúa una vez por cada fila. Esto se llama
   subconsulta CORRELACIONADA.
   Ejemplo:  SELECT c.nombre FROM cursos c
             WHERE EXISTS (SELECT 1 FROM matriculas m
                           WHERE m.id_curso = c.id_curso);
             -- los cursos que tienen al menos un matriculado
   ===================================================================== */

-- 3.1  Mostrar el nombre y el teléfono de los socios que tienen algún
--      préstamo sin devolver, para llamarlos.


-- 3.2  Resolver otra vez el 2.3 (autores sin libros), ahora con
--      NOT EXISTS.
--      PREGUNTA: ¿por qué NOT EXISTS sí funciona sin corregir nada?


-- 3.3  Mostrar los socios que tienen un préstamo sin devolver Y además
--      tienen alguna multa.



/* =====================================================================
   PARTE 4 · SUBCONSULTA EN EL SELECT
   ---------------------------------------------------------------------
   Una subconsulta que devuelve un solo valor también puede ir como una
   columna del SELECT. Se calcula una vez por cada fila del resultado,
   normalmente correlacionada con la consulta de afuera.
   Ejemplo:  SELECT c.nombre,
                    (SELECT COUNT(*) FROM matriculas m
                     WHERE m.id_curso = c.id_curso) AS inscritos
             FROM cursos c;
   Ventaja: aparecen todas las filas de afuera, aunque no tengan datos
   relacionados (su conteo sale en 0).
   ===================================================================== */

-- 4.1  Mostrar cada autor con la cantidad de libros que tiene, del que
--      más al que menos.
--      PREGUNTA: ¿cuántos autores salen? Resolverlo también con JOIN y
--      GROUP BY. ¿Cuántos salen ahora y por qué?


-- 4.2  Para cada libro: título, ejemplares, cuántos están prestados
--      ahora mismo (sin devolver) y cuántos quedan disponibles.



/* =====================================================================
   PARTE 5 · SUBCONSULTA EN EL FROM
   ---------------------------------------------------------------------
   El resultado de una subconsulta se puede usar como si fuera una
   tabla, en el FROM. A esa tabla temporal se le llama TABLA DERIVADA y
   siempre debe llevar un nombre (alias).
   Sirve para hacer un cálculo sobre un resultado que ya está agrupado,
   por ejemplo, el promedio de unos conteos.
   Ejemplo:  SELECT MAX(total)
             FROM (SELECT id_curso, COUNT(*) AS total
                   FROM matriculas GROUP BY id_curso) AS por_curso;
             -- cuántos matriculados tiene el curso más lleno
   ===================================================================== */

-- 5.1  ¿Cuántos préstamos hace en promedio cada socio? Contar primero
--      los préstamos de cada socio y luego promediar esos conteos.
--      PREGUNTA: ¿qué error sale si se quita el alias? ¿Y si se
--      escribe AVG(COUNT(*)) directamente?


-- 5.2  Mostrar los socios que han hecho más préstamos que el promedio
--      del ejercicio 5.1, con su cantidad de préstamos.
--      (Pista: GROUP BY y HAVING, con la consulta del 5.1 dentro).



/* =====================================================================
   PARTE 6 · TODO JUNTO
   ===================================================================== */

-- 6.1  ¿Qué libros se han prestado más veces que el promedio de
--      préstamos por libro? Mostrar el título, el nombre del autor y
--      cuántas veces se prestó, del más prestado al menos.
