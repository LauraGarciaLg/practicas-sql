/* =====================================================================
   CASO ACADEMIA · 03_ejercicios.sql
   PRÁCTICA DE DDL, DML Y CONSULTAS
   ---------------------------------------------------------------------
   Requisito: haber ejecutado 01_esquema.sql y luego 02_datos.sql.

   El archivo tiene dos bloques:

   BLOQUE A · LO QUE YA VIMOS
     PARTE 1 · DDL                          (ejercicios 1.1 a 1.6)
     PARTE 2 · DML                          (ejercicios 2.1 a 2.11)
     PARTE 3 · INNER JOIN, COUNT y SUM      (ejercicios 3.1 a 3.8)
     PARTE 4 · LIMIT                        (ejercicios 4.1 y 4.2)

   BLOQUE B · TEMAS NUEVOS (para continuar, en este orden)
     PARTE 5 · LIKE                         (ejercicios 5.1 a 5.6)
     PARTE 6 · MIN, MAX, AVG y ROUND        (ejercicios 6.1 a 6.6)
     PARTE 7 · DISTINCT                     (ejercicios 7.1 a 7.5)
     PARTE 8 · HAVING                       (ejercicios 8.1 a 8.4)
     PARTE 9 · LEFT JOIN y RIGHT JOIN       (ejercicios 9.1 a 9.6)
     PARTE 10 · Todo junto                  (ejercicio 10.1)

   Cómo trabajar:
     - Cada parte empieza con un recuadro que explica para qué sirve
       cada instrucción. Leerlo antes de empezar los ejercicios.
     - Escribir la solución debajo de cada enunciado y ejecutarla sola
       (Ctrl+Enter en la instrucción, Alt+X / Ctrl+Shift+Enter un bloque).
     - Después de cada cambio, comprobarlo con DESCRIBE o SELECT.
     - Las partes 1 y 2 se hacen en orden: unas dependen de otras.
     - ANTES de la parte 3, recargar la base (01_esquema.sql y
       02_datos.sql) para trabajar con los datos originales. De la
       parte 3 en adelante solo se consulta: no hace falta recargar.

   Tablas: profesores, estudiantes, cursos, matriculas, pagos.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;

-- Workbench bloquea los UPDATE y DELETE que no filtran por una clave
-- (error 1175). Esta línea lo permite solo durante esta sesión.
SET SQL_SAFE_UPDATES = 0;

-- Para empezar: reconocer la estructura
SHOW TABLES;
DESCRIBE cursos;
DESCRIBE pagos;



/* =====================================================================
   BLOQUE A · LO QUE YA VIMOS
   CREATE, DROP, ALTER TABLE, INSERT, UPDATE, DELETE, SELECT,
   INNER JOIN, COUNT, SUM y LIMIT, con WHERE, IS NULL, ORDER BY y
   GROUP BY.
   ===================================================================== */

/* =====================================================================
   PARTE 1 · DDL — CAMBIAR LA ESTRUCTURA
   ---------------------------------------------------------------------
   CREATE TABLE   crea una tabla con sus columnas y restricciones.
   ALTER TABLE    cambia una tabla que ya existe: ADD COLUMN agrega
                  una columna, MODIFY la cambia y DROP COLUMN la quita.
   DROP TABLE     elimina la tabla completa, con todos sus datos.
   ===================================================================== */

-- 1.1  La academia quiere registrar sus salas. Crear la tabla "salas" con:
--      id_sala (clave primaria autoincremental), nombre (obligatorio y
--      sin repetirse) y capacidad (obligatoria y mayor que cero, con una
--      restricción llamada chk_capacidad).


-- 1.2  Cada curso se dicta en una sala. Agregar a "cursos" la columna
--      id_sala y la clave foránea fk_curso_sala hacia salas.


-- 1.3  Agregar a "estudiantes" la columna acudiente (texto de hasta 80
--      caracteres), ubicada justo después de nombre.


-- 1.4  Hay instrumentos con nombres largos. Ampliar la columna
--      instrumento de "profesores" a 60 caracteres sin perder el NOT NULL.


-- 1.5  Crear la tabla "asistencias": id_asistencia, id_estudiante,
--      id_curso, fecha y presente (BOOLEAN, por defecto TRUE).
--      Reglas: un estudiante no puede tener dos registros del mismo curso
--      el mismo día, y solo se registra asistencia de quien esté
--      MATRICULADO en ese curso.
--      Pista: la clave foránea apunta a la clave primaria de matriculas.


-- 1.6  Al final se decidió no guardar el acudiente: eliminar esa columna.



/* =====================================================================
   PARTE 2 · DML — CAMBIAR LOS DATOS
   ---------------------------------------------------------------------
   INSERT INTO    agrega filas nuevas a una tabla.
   UPDATE         cambia valores de filas que ya existen.
   DELETE FROM    borra filas.
   WHERE          elige A QUÉ filas se aplica. Sin WHERE, UPDATE y
                  DELETE afectan a TODA la tabla.
   IS NULL        en el WHERE, pregunta si un valor está vacío. Se
                  escribe IS NULL, no = NULL (= NULL nunca se cumple).
   ===================================================================== */

-- 2.1  Registrar tres salas: 'Sala Beethoven' (6 personas),
--      'Sala Mozart' (10) y 'Auditorio' (20).


-- 2.2  Asignar salas: los cursos de piano a la Sala Beethoven, Teoría
--      Musical al Auditorio y todos los demás a la Sala Mozart.
--      ¿Cuántas filas afectó cada UPDATE?


-- 2.3  Registrar a la estudiante Camila Duarte: documento 1098013,
--      camila@mail.com, 3113334455, Aguachica, nacida el 2009-01-19.
--      No indicar id ni fecha de registro.
--      PREGUNTA: ¿qué valores tomaron esas dos columnas y por qué?


-- 2.4  Tomás Navarro (id 11) se matricula hoy en Violín Inicial (id 6) y
--      paga la cuota de ingreso (40000) y la primera mensualidad del curso.


-- 2.5  Ejecutar las tres instrucciones y explicar cada error:
--      a) Matricular de nuevo a Tomás en Violín Inicial.
--      b) Registrar un pago de Tomás de 50000 con concepto 'Donación'.
--      c) Matricular al estudiante 99 en el curso 1.


-- 2.6  Subir 5 % el precio de los cursos de nivel Intermedio.


-- 2.7  Asignar a Felipe Arango (profesor 6) el curso Teoría Musical.


-- 2.8  Daniela Torres (id 3) actualiza sus datos: correo
--      daniela@mail.com y teléfono 3150009988 (en un solo UPDATE).


-- 2.9  Isabel Romero (id 12) se retira de la academia: eliminarla.
--      PREGUNTA: ¿por qué falla el primer intento? ¿Qué hay que borrar
--      antes?


-- 2.10 Andrés Cárdenas (id 10) cancela Guitarra Eléctrica (id 4):
--      eliminar SOLO esa matrícula.


-- 2.11 Dejar la estructura como al principio: eliminar asistencias, la
--      columna id_sala de cursos y la tabla salas.
--      PREGUNTA: ¿en qué orden hay que hacerlo y por qué?



/* =====================================================================
   PARTE 3 · CONSULTAS CON INNER JOIN, COUNT Y SUM
   ANTES: recargar la base con 01_esquema.sql y 02_datos.sql.
   ---------------------------------------------------------------------
   SELECT … FROM  muestra columnas de una tabla.
   INNER JOIN     une dos tablas por una columna en común (ON). Solo
                  trae las filas que tienen pareja en las dos.
   COUNT(*)       cuenta filas.
   SUM(columna)   suma los valores de una columna.
   GROUP BY       junta en un grupo las filas con el mismo valor en una
                  columna, para que COUNT, SUM… calculen un resultado POR
                  CADA GRUPO (una fila por grupo). Sin GROUP BY, calculan
                  un solo resultado para toda la tabla.
   ORDER BY       ordena el resultado: ASC (por defecto) o DESC.
   ===================================================================== */

-- 3.1  Listar cada profesor con sus cursos: profesor, curso, cupo máximo
--      y precio.
--      PREGUNTA: hay 8 cursos, ¿cuál falta y por qué?


-- 3.2  Listar los estudiantes con sus cursos matriculados: id y nombre
--      del estudiante, curso, precio, profesor y fecha de matrícula, de la
--      más reciente a la más antigua.
--      PREGUNTA: hay 17 matrículas, ¿por qué salen menos filas?


-- 3.3  COUNT. ¿Cuántos estudiantes hay? ¿Cuántos tienen correo y cuántos
--      teléfono? Resolverlo en una sola consulta.
--      PREGUNTA: ¿por qué COUNT(*) y COUNT(email) dan números distintos?


-- 3.4  SUM. ¿Cuánto ha recaudado la academia en total? ¿Cuánto ha pagado
--      Ana Beltrán (id 1)?


-- 3.5  Obtener el total pagado por concepto.


-- 3.6  Igual que 3.5, agregando cuántos pagos hay de cada concepto y
--      ordenando de mayor a menor total.


-- 3.7  Total recaudado por cada profesor (pagos de sus cursos), de mayor
--      a menor.


-- 3.8  Para cada matrícula, mostrar estudiante, curso, fecha de
--      matrícula y el total que ese estudiante ha pagado POR ESE CURSO.
--      Pista: el pago se relaciona con la matrícula por dos columnas.



/* =====================================================================
   PARTE 4 · LIMIT
   ---------------------------------------------------------------------
   LIMIT n            muestra solo las primeras n filas.
   LIMIT n OFFSET m   se salta m filas y luego muestra n.
   Va con ORDER BY: primero se ordena y luego se corta.
   ===================================================================== */

-- 4.1  Obtener los 3 mayores pagos: nombre del estudiante, concepto y
--      valor.


-- 4.2  LIMIT.
--      a) El curso con más matriculados.
--      b) Los 2 estudiantes que más han pagado.
--      c) Ordenando los cursos del más caro al más barato, mostrar los
--         puestos 4, 5 y 6 (LIMIT … OFFSET …).




/* =====================================================================
   BLOQUE B · TEMAS NUEVOS
   Para seguir avanzando, en este orden. Solo consultas: se trabaja
   con la base tal como quedó en la parte 4 (no hace falta recargar).

   Cada parte empieza con ejercicios cortos de un solo concepto y
   termina con los más completos, que lo combinan con lo anterior.
   ===================================================================== */

/* =====================================================================
   PARTE 5 · LIKE
   ---------------------------------------------------------------------
   LIKE       en el WHERE, busca textos que siguen un PATRÓN, en vez
              de un valor exacto como hace =. Dos comodines:
                %   cualquier cantidad de caracteres (incluso ninguno)
                _   exactamente un carácter
   Ejemplos:  'Piano%'  empieza por Piano    '%Rock'  termina en Rock
              '%ia%'    contiene ia          '_a%'    la 2.ª letra es a
   NOT LIKE   lo contrario: los textos que NO siguen el patrón.
   En esta base LIKE no distingue mayúsculas ni tildes.
   ===================================================================== */

-- 5.1  Mostrar los cursos cuyo nombre empieza por 'Piano'.


-- 5.2  Mostrar los cursos cuyo nombre termina en 'Básico'.
--      PREGUNTA: hay 5 cursos de nivel Básico, ¿por qué sale solo uno?


-- 5.3  Mostrar los estudiantes cuyo nombre contiene 'ia'.
--      Luego buscar '%andres%' (sin tilde y en minúscula).
--      PREGUNTA: ¿encuentra a Andrés Cárdenas? ¿Por qué?


-- 5.4  Con el comodín _ , mostrar los estudiantes cuyo documento es
--      '109800' seguido de UN solo carácter.
--      PREGUNTA: ¿por qué no sale el documento 1098010?


-- 5.5  NOT LIKE. Mostrar los cursos que NO son de guitarra (su nombre
--      no contiene 'Guitarra').


-- 5.6  Para los cursos de piano y de guitarra: nombre del curso, nombre
--      del profesor y total recaudado (pagos de ese curso), de mayor a
--      menor.



/* =====================================================================
   PARTE 6 · MIN, MAX, AVG Y ROUND
   ---------------------------------------------------------------------
   MIN(columna)   el valor más pequeño.
   MAX(columna)   el valor más grande.
   AVG(columna)   el promedio. No tiene en cuenta los NULL.
   ROUND(x, n)    redondea x a n decimales (sin n, a entero).
   Igual que COUNT y SUM, se usan solas o con GROUP BY.
   Ejemplo:  SELECT MIN(precio), MAX(precio) FROM cursos;
   ===================================================================== */

-- 6.1  MIN. ¿Cuál es el pago más pequeño que se ha registrado?


-- 6.2  MAX. ¿Cuál es el cupo máximo más grande entre todos los cursos?


-- 6.3  AVG y ROUND. ¿Cuál es el cupo promedio de los cursos? Mostrarlo
--      sin redondear y redondeado a un decimal.


-- 6.4  MIN y MAX. Precio del curso más barato y del más caro. Fecha del
--      primer y del último pago. Por último, aplicar MIN y MAX a nombre y
--      a fecha_nacimiento de estudiantes.
--      PREGUNTA: ¿qué significan MIN y MAX sobre un texto y sobre una
--      fecha? ¿Quién es el estudiante más joven?


-- 6.5  AVG. Precio promedio de los cursos, con y sin redondear (ROUND).
--      Valor promedio de los pagos de 'Mensualidad'.


-- 6.6  GROUP BY con varias funciones.
--      a) Por nivel de curso: cantidad de cursos, precio mínimo, máximo y
--         promedio (con 2 decimales).
--      b) Por estudiante: cantidad de pagos, total, pago menor, pago mayor
--         y promedio, del que más ha pagado al que menos.
--      PREGUNTA: ¿por qué Tomás Navarro no aparece en b)?



/* =====================================================================
   PARTE 7 · DISTINCT
   ---------------------------------------------------------------------
   DISTINCT              quita las filas repetidas del resultado.
                         Va justo después de SELECT.
   COUNT(DISTINCT col)   cuenta cuántos valores DISTINTOS hay.
   Ejemplo:  SELECT DISTINCT ciudad FROM estudiantes;
   ===================================================================== */

-- 7.1  Mostrar los niveles de curso que existen, sin repetir.


-- 7.2  Mostrar los conceptos de pago que existen, sin repetir.
--      PREGUNTA: ¿cuántas filas salen si se quita DISTINCT?


-- 7.3  ¿Cuántos estudiantes distintos han hecho al menos un pago?
--      PREGUNTA: ¿por qué COUNT(*) da otro número?


-- 7.4  DISTINCT.
--      a) Ciudades de donde vienen los estudiantes, sin repetir.
--      b) En matriculas: cuántas filas hay, cuántos estudiantes distintos
--         y cuántos cursos distintos (COUNT(DISTINCT …)).
--      c) Combinaciones distintas de concepto y valor en pagos.
--      PREGUNTA: en c), ¿DISTINCT se aplica a una columna o a la fila?


-- 7.5  DISTINCT vs GROUP BY.
--      a) Obtener las ciudades sin repetir usando GROUP BY en vez de
--         DISTINCT y comparar con 7.4 a).
--      b) Agregar cuántos estudiantes hay en cada ciudad.
--      PREGUNTA: ¿se puede resolver b) con DISTINCT? ¿Cuándo dan lo mismo
--      DISTINCT y GROUP BY y cuándo hace falta GROUP BY?



/* =====================================================================
   PARTE 8 · HAVING
   ---------------------------------------------------------------------
   HAVING   filtra GRUPOS después de GROUP BY, con funciones como
            COUNT o SUM. WHERE, en cambio, filtra FILAS antes de
            agrupar.
   Orden de las cláusulas:
     SELECT … FROM … WHERE … GROUP BY … HAVING … ORDER BY … LIMIT
   Ejemplo:  … GROUP BY ciudad HAVING COUNT(*) >= 2;
   ===================================================================== */

-- 8.1  Mostrar los niveles de curso que tienen más de 3 cursos.


-- 8.2  Mostrar los conceptos de pago cuyo total supera 1000000.


-- 8.3  Ciudades con 3 o más estudiantes y cuántos tiene cada una.


-- 8.4  HAVING.
--      a) Estudiantes que han pagado en total más de 400000.
--      b) Cursos de nivel Básico con 3 o más matriculados.
--      PREGUNTA: en b), ¿qué condición va en WHERE y cuál en HAVING? ¿Por
--      qué no se puede escribir WHERE COUNT(*) >= 3?



/* =====================================================================
   PARTE 9 · LEFT JOIN Y RIGHT JOIN
   ---------------------------------------------------------------------
   LEFT JOIN   trae TODAS las filas de la tabla de la izquierda (la
               del FROM), tengan o no pareja en la otra. Donde no hay
               pareja, las columnas de la otra tabla salen en NULL.
               INNER JOIN, en cambio, solo trae las que tienen pareja.
   RIGHT JOIN  lo mismo, pero conserva TODAS las filas de la tabla de
               la derecha (la que va después de JOIN). Todo RIGHT JOIN
               se puede escribir como LEFT JOIN cambiando el orden de
               las tablas; por eso en la práctica se usa más LEFT JOIN.
   Para quedarse solo con las filas SIN pareja: WHERE … IS NULL.
   ===================================================================== */

-- 9.1  Listar TODOS los profesores con el nombre de sus cursos, aunque
--      no dicten ninguno.
--      PREGUNTA: ¿qué aparece en la columna del curso de Felipe Arango?


-- 9.2  Repetir 3.1 de modo que aparezcan TODOS los cursos.


-- 9.3  Listar los estudiantes que no están matriculados en ningún curso.


-- 9.4  RIGHT JOIN. Resolver de nuevo 9.1, pero empezando el FROM por
--      cursos: SELECT … FROM cursos c RIGHT JOIN profesores p …
--      PREGUNTA: ¿sale lo mismo que en 9.1? ¿Por qué?


-- 9.5  Esta consulta usa RIGHT JOIN. Reescribirla con LEFT JOIN de modo
--      que dé el mismo resultado:
--        SELECT e.nombre, m.id_curso
--        FROM matriculas m
--        RIGHT JOIN estudiantes e
--        ON m.id_estudiante = e.id_estudiante;
--      PREGUNTA: ¿qué estudiantes salen con id_curso NULL?


-- 9.6  Para cada curso: cupo máximo, cantidad de matriculados y cupos
--      libres. Deben aparecer también los cursos sin estudiantes.



/* =====================================================================
   PARTE 10 · TODO JUNTO
   ---------------------------------------------------------------------
   DATE_FORMAT(fecha, '%Y-%m')   convierte una fecha en texto con el
                                 formato indicado (aquí, año-mes).
   Combina GROUP BY, COUNT, SUM, AVG, ROUND y HAVING.
   ===================================================================== */

-- 10.1 Todo junto. Por mes de pago (DATE_FORMAT(fecha_pago, '%Y-%m')):
--      cantidad de pagos, total y promedio redondeado, solo de los meses
--      que recaudaron 1000000 o más, ordenado por mes.
