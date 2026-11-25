/* =====================================================================
   CASO ACADEMIA · 06_subconsultas.sql
   SUBCONSULTAS, PASO A PASO CON LA PRESENTACIÓN
   ---------------------------------------------------------------------
   Requisito: haber ejecutado 01_esquema.sql y luego 02_datos.sql.

   Este archivo acompaña las diapositivas de Subconsultas y vistas. Las
   partes van en el mismo orden de la presentación:

     PARTE 1 · Subconsulta que devuelve un solo valor   (1.1 a 1.8)
     PARTE 2 · IN y NOT IN                              (2.1 a 2.5)
     PARTE 3 · NOT EXISTS                               (3.1 a 3.4)
     PARTE 4 · Subconsultas anidadas                    (4.1 a 4.3)

   Cómo trabajar:
     - Cada parte empieza con un EJEMPLO ya resuelto: es el mismo de la
       diapositiva. Ejecutarlo primero y comparar con el resultado que
       aparece en el comentario.
     - Después vienen los ejercicios, de los más sencillos a los más
       trabajables.
     - Escribir la solución debajo de cada enunciado y ejecutarla sola.
     - Las PREGUNTAS se responden con un comentario (-- …) debajo de la
       solución.
     - La parte 1 termina con UPDATE que CAMBIAN DATOS. Al final de esa
       parte vienen las líneas para dejarlos como estaban: ejecutarlas
       antes de seguir. El resto del archivo solo consulta.

   Tablas: profesores, estudiantes, cursos, matriculas, pagos.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;



/* =====================================================================
   ¿QUÉ ES UNA SUBCONSULTA?
   ---------------------------------------------------------------------
   Es un SELECT escrito dentro de otra consulta, entre paréntesis. Sirve
   para preguntas que necesitan un dato que primero hay que calcular,
   como "¿qué cursos cuestan más que el promedio?".

   Según lo que devuelve, se usa de forma distinta:
     - Un solo valor (una fila, una columna):  se compara con =, >, <…
     - Una lista de valores (una columna):     se usa con IN / NOT IN.
     - Filas o ninguna:                        se usa con NOT EXISTS.
   ===================================================================== */



/* =====================================================================
   PARTE 1 · SUBCONSULTA QUE DEVUELVE UN SOLO VALOR
   ---------------------------------------------------------------------
   Devuelve un solo dato, casi siempre el resultado de AVG, MIN, MAX,
   SUM o COUNT. MySQL la resuelve primero y usa ese valor como si fuera
   un número escrito a mano.
   Si la subconsulta devuelve más de una fila, sale el error 1242
   (Subquery returns more than 1 row).

   La subconsulta también sirve para CAMBIAR datos con UPDATE: en el
   WHERE (para elegir qué filas cambian) o en el SET (para calcular el
   valor nuevo). Se ve en el paso 2.
   ===================================================================== */

-- ---------------------------------------------------------------------
-- PASO 1 · UNA SUBCONSULTA EN UN SELECT
-- ---------------------------------------------------------------------

-- EJEMPLO  Paso 1: calcular el precio promedio de los cursos.
SELECT AVG(precio) FROM cursos;
-- 170909.09

-- EJEMPLO  Paso 2: usar ese valor en el WHERE, sin escribirlo a mano.
SELECT nombre, precio
FROM cursos
WHERE precio > (SELECT AVG(precio) FROM cursos);
-- 5 filas: Piano Básico, Piano Intermedio, Violín Inicial, Batería Rock
-- y Piano Avanzado.


-- 1.1  Mostrar el nombre de los cursos que dicta Valentina Ríos, sin
--      escribir su id a mano: buscarlo con una subconsulta en la tabla
--      profesores.


-- 1.2  Mostrar el nombre y la fecha de ingreso de los profesores que
--      entraron a la academia antes que Natalia Vargas.


-- 1.3  Mostrar el nombre y el cupo máximo de los cursos que tienen un
--      cupo mayor que el promedio de cupos, del más grande al más
--      pequeño.


-- 1.4  Mostrar el nombre y el precio del curso más caro, usando una
--      subconsulta con MAX.
--      PREGUNTA: probar WHERE precio = MAX(precio), sin subconsulta.
--      ¿Qué error sale y por qué?


-- 1.5  Mostrar, en orden alfabético, los estudiantes que viven en la
--      misma ciudad que Ana Beltrán, sin incluirla a ella.
--      PREGUNTA: cambiar la subconsulta para buscar la ciudad de los
--      estudiantes cuyo nombre empieza por 'Daniela'. ¿Qué error sale
--      y por qué?


-- 1.6  Más trabajable. Mostrar los pagos de Material que superan el
--      promedio de los pagos de Material, con el nombre del estudiante,
--      el nombre del curso y el valor, del más alto al más bajo.
--      (Pista: el promedio también se filtra por concepto).


-- ---------------------------------------------------------------------
-- PASO 2 · UNA SUBCONSULTA EN UN UPDATE
-- ---------------------------------------------------------------------
--   UPDATE tabla SET columna = (SELECT …) WHERE …;
--   UPDATE tabla SET columna = valor WHERE columna > (SELECT …);
--
-- Buena costumbre: antes del UPDATE, ejecutar un SELECT con el mismo
-- WHERE para ver qué filas van a cambiar.
--
-- En MySQL, la subconsulta no puede leer la misma tabla que se está
-- cambiando: sale el error 1093 (You can't specify target table … for
-- update in FROM clause). Se corrige envolviendo la subconsulta en otra
-- con un alias, como en el ejemplo: así MySQL calcula primero el valor
-- y ya no la ve como la misma tabla. Basta con copiar ese molde.

-- Workbench bloquea los UPDATE que no filtran por una clave (error
-- 1175). Esta línea lo permite solo durante esta sesión.
SET SQL_SAFE_UPDATES = 0;

-- EJEMPLO  Felipe Arango va a dictar Teoría Musical. Su id se busca con
-- una subconsulta en el SET, sin escribirlo a mano.
UPDATE cursos
SET id_profesor = (SELECT id_profesor FROM profesores
                   WHERE nombre = 'Felipe Arango')
WHERE nombre = 'Teoría Musical';
-- 1 fila cambiada: Teoría Musical queda con id_profesor 6.

-- EJEMPLO  Error 1093: subir 2 cupos a los cursos con cupo menor que el
-- promedio.
-- Paso 1: ver qué filas van a cambiar.
SELECT nombre, cupo_maximo
FROM cursos
WHERE cupo_maximo < (SELECT AVG(cupo_maximo) FROM cursos);
-- 7 filas (el promedio es 7.18).

-- Paso 2: el UPDATE con el mismo WHERE.
UPDATE cursos
SET cupo_maximo = cupo_maximo + 2
WHERE cupo_maximo < (SELECT AVG(cupo_maximo) FROM cursos);
-- Error 1093: la subconsulta lee cursos, la misma tabla que se cambia.

-- Corrección: el promedio se calcula dentro de otra subconsulta.
UPDATE cursos
SET cupo_maximo = cupo_maximo + 2
WHERE cupo_maximo < (SELECT promedio
                     FROM (SELECT AVG(cupo_maximo) AS promedio
                           FROM cursos) AS t);
-- 7 filas cambiadas: por ejemplo, Piano Avanzado pasa de 3 a 5 y Piano
-- Intermedio de 4 a 6.


-- 1.7  El cupo máximo de Teoría Musical (curso 8) pasa a ser igual a la
--      cantidad de estudiantes matriculados en él. Hacerlo con una
--      subconsulta con COUNT en el SET, sin escribir el número.
--      PREGUNTA: ¿qué cupo tenía antes y cuál tiene ahora? ¿Por qué aquí
--      no sale el error 1093?


-- 1.8  Más trabajable. Violín Inicial pasa a costar lo mismo que Piano
--      Básico. Hacerlo con una subconsulta en el SET, sin escribir el
--      precio.
--      PREGUNTA: ¿qué error sale la primera vez? Corregirlo como en el
--      ejemplo. ¿Qué precio queda?


-- ---------------------------------------------------------------------
-- AL TERMINAR LA PARTE 1: dejar los cursos como estaban
-- ---------------------------------------------------------------------
-- Los UPDATE de este paso cambiaron cupos, un precio y un profesor. Las
-- partes que siguen esperan los datos originales: ejecutar estas líneas.
UPDATE cursos SET cupo_maximo = 6 WHERE id_curso = 1;
UPDATE cursos SET cupo_maximo = 4 WHERE id_curso = 2;
UPDATE cursos SET cupo_maximo = 6 WHERE id_curso = 4;
UPDATE cursos SET cupo_maximo = 5, precio = 200000 WHERE id_curso = 6;
UPDATE cursos SET cupo_maximo = 4 WHERE id_curso = 7;
UPDATE cursos SET cupo_maximo = 15, id_profesor = NULL WHERE id_curso = 8;
UPDATE cursos SET cupo_maximo = 3 WHERE id_curso = 9;
UPDATE cursos SET cupo_maximo = 6 WHERE id_curso = 10;
-- (Si algo salió mal, también se puede recargar la base con
-- 01_esquema.sql y 02_datos.sql).



/* =====================================================================
   PARTE 2 · IN Y NOT IN
   ---------------------------------------------------------------------
   IN y NOT IN comparan un valor con una LISTA de valores:
     IN       el valor está en la lista.
     NOT IN   el valor no está en la lista.

   Primero se ven con una lista escrita a mano, entre paréntesis y
   separada por comas. Después, con una subconsulta que arma la lista.
   ===================================================================== */

-- ---------------------------------------------------------------------
-- PASO 1 · IN Y NOT IN CON UNA LISTA ESCRITA A MANO
-- ---------------------------------------------------------------------

-- EJEMPLO  Estudiantes de Ocaña o de Gamarra.
SELECT nombre, ciudad
FROM estudiantes
WHERE ciudad IN ('Ocaña', 'Gamarra')
ORDER BY ciudad, nombre;
-- 11 filas: 4 de Gamarra y 7 de Ocaña.
-- Es lo mismo que WHERE ciudad = 'Ocaña' OR ciudad = 'Gamarra', pero
-- más corto: con IN se agregan más valores sin repetir "ciudad =".

-- EJEMPLO  Cursos que no son de nivel Básico ni Intermedio.
SELECT nombre, nivel
FROM cursos
WHERE nivel NOT IN ('Básico', 'Intermedio');
-- 2 filas: Piano Avanzado y Ensamble Musical.
-- Es lo mismo que WHERE nivel <> 'Básico' AND nivel <> 'Intermedio'.


-- 2.1  Mostrar, en orden alfabético, el nombre y el instrumento de los
--      profesores de Piano, Canto o Flauta, usando IN.
--      PREGUNTA: ¿cómo se escribiría la misma consulta con OR?


-- 2.2  Mostrar el nombre y la ciudad de los estudiantes que NO son de
--      Aguachica, Ocaña ni Bucaramanga, ordenados por ciudad y nombre,
--      usando NOT IN.
--      PREGUNTA: ¿cuántos son y de qué ciudades?


-- ---------------------------------------------------------------------
-- PASO 2 · IN Y NOT IN CON UNA SUBCONSULTA
-- ---------------------------------------------------------------------
-- En lugar de escribir la lista a mano, una subconsulta la arma. Debe
-- devolver UNA sola columna; puede tener varias filas. (Con = no se
-- podría: = solo compara con un valor).

-- EJEMPLO  Estudiantes que tienen al menos una matrícula.
SELECT nombre
FROM estudiantes
WHERE id_estudiante IN (SELECT id_estudiante FROM matriculas);
-- 28 filas. La subconsulta trae 49 valores (uno por matrícula, con
-- repetidos); IN solo pregunta si el id está en esa lista.

-- EJEMPLO  Estudiantes sin ninguna matrícula.
SELECT nombre
FROM estudiantes
WHERE id_estudiante NOT IN (SELECT id_estudiante FROM matriculas);
-- 2 filas: Tomás Navarro e Isabel Romero.


-- 2.3  Mostrar, en orden alfabético, los estudiantes matriculados en el
--      curso 1 (Piano Básico), sin usar JOIN.


-- 2.4  Mostrar los cursos que dicta algún profesor de Piano o de
--      Guitarra (columna instrumento de profesores).


-- 2.5  Más trabajable. Mostrar, en orden alfabético, los estudiantes de
--      Aguachica que NO están matriculados en Teoría Musical (curso 8).
--      PREGUNTA: ¿cuántos son? ¿Cuántos estudiantes tiene Aguachica?



/* =====================================================================
   PARTE 3 · NOT EXISTS
   ---------------------------------------------------------------------
   NOT EXISTS (subconsulta)   verdadero si la subconsulta NO devuelve
                              ninguna fila.
   Sirve para las preguntas de "los que no tienen…": estudiantes sin
   pagos, cursos sin matriculados, profesores sin cursos.
   No importa qué columnas devuelva la subconsulta; por eso se escribe
   SELECT 1.

   La subconsulta usa una columna de la consulta de afuera (por ejemplo
   p.id_profesor), así que se evalúa una vez por cada fila. Esto se
   llama subconsulta CORRELACIONADA.

   ¿Por qué no basta con NOT IN? Porque si la lista trae un NULL, NOT IN
   no devuelve nada. NOT EXISTS no tiene ese problema.
   (También existe EXISTS, sin el NOT, para "los que sí tienen…", pero
   eso casi siempre se resuelve con IN o con JOIN).
   ===================================================================== */

-- EJEMPLO  Profesores sin cursos, primero con NOT IN.
SELECT nombre
FROM profesores
WHERE id_profesor NOT IN (SELECT id_profesor FROM cursos);
-- 0 filas, aunque Felipe Arango no tiene cursos: la lista trae un NULL
-- (Teoría Musical no tiene profesor) y NOT IN no puede asegurar nada.

-- EJEMPLO  Lo mismo SIN subconsulta, con LEFT JOIN.
SELECT p.nombre
FROM profesores p
LEFT JOIN cursos c ON c.id_profesor = p.id_profesor
WHERE c.id_curso IS NULL;
-- 1 fila: Felipe Arango.
-- El LEFT JOIN conserva a todos los profesores; al que no tiene cursos
-- le pone NULL en las columnas de cursos, y el WHERE se queda solo con
-- ese. Se pregunta por c.id_curso porque es la clave de cursos: solo es
-- NULL cuando no hubo pareja. El NULL de Teoría Musical no le afecta.

-- EJEMPLO  Lo mismo con NOT EXISTS.
SELECT p.nombre
FROM profesores p
WHERE NOT EXISTS (SELECT 1 FROM cursos c
                  WHERE c.id_profesor = p.id_profesor);
-- 1 fila: Felipe Arango.
-- Se lee así: "profesores para los que NO EXISTE ningún curso con su
-- id_profesor".


-- 3.1  Mostrar los estudiantes que no han hecho ningún pago, con
--      NOT EXISTS.


-- 3.2  Mostrar los cursos que no tienen ningún estudiante de Aguachica
--      matriculado, con NOT EXISTS.
--      (Pista: dentro de la subconsulta, unir matriculas con
--      estudiantes).
--      PREGUNTA: uno de los cursos que salen no tiene a nadie
--      matriculado. ¿Cuál es? ¿Por qué también sale?


-- 3.3  Mostrar los estudiantes que han hecho algún pago pero no están
--      matriculados en ningún curso.
--      (Pista: un IN con pagos y un NOT EXISTS con matriculas, unidos
--      con AND).


-- 3.4  Más trabajable. Se quieren los cursos que no han recibido ningún
--      pago. Resolverlo primero con NOT IN sobre la columna id_curso de
--      pagos y después con NOT EXISTS.
--      PREGUNTA: ¿por qué NOT IN no devuelve nada? (Pista: revisar los
--      pagos de Matrícula). ¿Cómo se corrige sin cambiar a NOT EXISTS?



/* =====================================================================
   PARTE 4 · SUBCONSULTAS ANIDADAS
   ---------------------------------------------------------------------
   Una subconsulta también puede llevar otra subconsulta dentro. Sirve
   cuando el dato que se busca está a varias tablas de distancia: cada
   subconsulta da un paso y le pasa su resultado a la de afuera.

   MySQL las resuelve de ADENTRO hacia AFUERA. Para escribirlas, conviene
   hacer lo mismo: empezar por la más interna, ejecutarla sola y revisar
   qué devuelve antes de envolverla en la siguiente.

   Cada nivel usa = o IN según lo que devuelva el nivel de adentro:
     un solo valor      →  =
     una lista          →  IN
   (El molde del error 1093, en la parte 1, ya era una subconsulta
   anidada).
   ===================================================================== */

-- EJEMPLO  Estudiantes matriculados en algún curso de Valentina Ríos.
-- Paso 1 (la más interna): el id de Valentina. Un solo valor.
SELECT id_profesor FROM profesores WHERE nombre = 'Valentina Ríos';
-- 1

-- Paso 2: los cursos de ese profesor. Una lista.
SELECT id_curso FROM cursos
WHERE id_profesor = (SELECT id_profesor FROM profesores
                     WHERE nombre = 'Valentina Ríos');
-- 3 filas: 1, 2 y 9 (los tres cursos de piano).

-- Paso 3: los estudiantes matriculados en esos cursos.
SELECT nombre
FROM estudiantes
WHERE id_estudiante IN
      (SELECT id_estudiante FROM matriculas
       WHERE id_curso IN
             (SELECT id_curso FROM cursos
              WHERE id_profesor = (SELECT id_profesor FROM profesores
                                   WHERE nombre = 'Valentina Ríos')))
ORDER BY nombre;
-- 12 filas, de Ana Beltrán a Valeria Quiroga.
-- Se lee de adentro hacia afuera: el id de Valentina → sus cursos → las
-- matrículas de esos cursos → los nombres de esos estudiantes.


-- 4.1  Mostrar el nombre y el instrumento de los profesores que dictan
--      algún curso en el que está matriculada Ana Beltrán.
--      PREGUNTA: Ana está matriculada en dos cursos. ¿Por qué sale un
--      solo profesor?


-- 4.2  Mostrar, en orden alfabético, los cursos que tienen al menos un
--      estudiante de la misma ciudad que Mateo Salazar.
--      (Pista: la subconsulta más interna busca la ciudad de Mateo).


-- 4.3  Más trabajable. Mostrar, en orden alfabético, los estudiantes de
--      Aguachica matriculados en algún curso que dicta un profesor que
--      entró a la academia antes que Natalia Vargas. Armar la consulta
--      de adentro hacia afuera, ejecutando cada nivel por separado.
--      PREGUNTA: ¿en qué niveles se usa = y en cuáles IN? ¿Por qué?
