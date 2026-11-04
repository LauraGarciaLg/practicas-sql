/* =====================================================================
   CASO ACADEMIA · 05_taller.sql
   TALLER DE CONSULTAS
   ---------------------------------------------------------------------
   Requisito: haber ejecutado 01_esquema.sql y luego 02_datos.sql.

   La academia necesita información para tomar decisiones. Cada
   ejercicio es un pedido de la dirección y se resuelve con una
   consulta sobre la base academia, con lo visto en 03_ejercicios.sql.
   No se crean tablas ni se cambian datos.

     BLOQUE 1 · Consultar una tabla           (1.1 a 1.4)
     BLOQUE 2 · Contar, sumar y agrupar       (2.1 a 2.3)
     BLOQUE 3 · Unir tablas                   (3.1 a 3.3)
     BLOQUE 4 · Reportes                      (4.1 a 4.3)

   Cómo trabajar:
     - En cada bloque, los primeros ejercicios son consultas sencillas
       y el último es más trabajable: combina varias cosas.
     - Escribir la consulta debajo de cada enunciado y ejecutarla sola.
     - Las PREGUNTAS se responden con un comentario (-- …) debajo de la
       consulta.

   Entrega: este mismo archivo con las consultas y las respuestas.
   Tablas: profesores, estudiantes, cursos, matriculas, pagos.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;



/* =====================================================================
   BLOQUE 1 · CONSULTAR UNA TABLA
   SELECT, WHERE (AND, OR, IS NULL), ORDER BY y LIMIT.
   ===================================================================== */

-- 1.1  La secretaría va a llamar a los estudiantes de Ocaña. Mostrar su
--      nombre y teléfono, en orden alfabético.


-- 1.2  Mostrar el nombre, el nivel y el precio de los cursos que NO son
--      de nivel Básico y cuestan menos de 200000, del más barato al más
--      caro.


-- 1.3  Hay que completar los datos de contacto. Mostrar el nombre, el
--      correo y el teléfono de los estudiantes a los que les falta el
--      correo o el teléfono.
--      PREGUNTA: ¿qué pasa si se escribe email = NULL? ¿Por qué?


-- 1.4  Más trabajable. Mostrar el nombre, la ciudad y la fecha de
--      nacimiento de los 5 estudiantes más jóvenes que se registraron
--      desde junio de 2026.



/* =====================================================================
   BLOQUE 2 · CONTAR, SUMAR Y AGRUPAR
   COUNT, SUM, AVG, MIN, MAX, ROUND y GROUP BY.
   ===================================================================== */

-- 2.1  ¿Cuántos estudiantes hay de cada ciudad? De la ciudad con más
--      estudiantes a la que tiene menos.


-- 2.2  ¿Cuántos pagos de Mensualidad se recibieron en septiembre de 2026
--      y cuánto sumaron?
--      PREGUNTA: ¿por qué conviene filtrar con fecha_pago < '2026-10-01'
--      en vez de fecha_pago <= '2026-09-30'?


-- 2.3  Más trabajable. Resumen de pagos por concepto: cantidad de pagos,
--      total, promedio (sin decimales), pago menor y pago mayor, del
--      concepto que más recaudó al que menos.



/* =====================================================================
   BLOQUE 3 · UNIR TABLAS
   INNER JOIN y LEFT JOIN.
   ===================================================================== */

-- 3.1  Mostrar cada curso con el nombre de su profesor y su precio, del
--      más caro al más barato.
--      PREGUNTA: hay 11 cursos, ¿cuál falta y por qué?


-- 3.2  Mostrar el nombre, la ciudad y la fecha de matrícula de los
--      estudiantes matriculados en Técnica Vocal, del primero que se
--      matriculó al último.


-- 3.3  Más trabajable. ¿Cuánto ha recaudado cada curso en mensualidades?
--      Mostrar el curso, su profesor y el total, de mayor a menor. Deben
--      aparecer TODOS los cursos, aunque no tengan profesor o pagos.
--      PREGUNTA: ¿qué muestran Teoría Musical y Violín Inicial y por qué?



/* =====================================================================
   BLOQUE 4 · REPORTES
   Todo junto: JOIN, GROUP BY, HAVING, COUNT(DISTINCT …), DATE_FORMAT
   y LIMIT.
   ===================================================================== */

-- 4.1  Mostrar los estudiantes matriculados en 2 o más cursos y en
--      cuántos está cada uno, del que tiene más al que tiene menos.


-- 4.2  ¿Cuáles son los 3 cursos que más han recaudado en mensualidades?


-- 4.3  Más trabajable. Reporte mensual de mensualidades: por cada mes
--      (DATE_FORMAT(fecha_pago, '%Y-%m')), cuántos pagos de Mensualidad
--      hubo, cuántos estudiantes distintos pagaron y cuánto se recaudó.
--      Solo los meses con más de 30 pagos, ordenados por mes.
--      PREGUNTAS: ¿por qué hay más pagos que estudiantes? ¿Qué condición
--      va en el WHERE y cuál en el HAVING?
