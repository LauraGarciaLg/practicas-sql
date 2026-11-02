/* =====================================================================
   CASO BIBLIOTECA · 03_vistas.sql
   VISTAS
   ---------------------------------------------------------------------
   Requisito: haber ejecutado 01_base_datos.sql y resuelto
   02_subconsultas.sql (algunas vistas usan subconsultas).

     PARTE 1 · Crear y consultar una vista                  (1.1 y 1.2)
     PARTE 2 · Las vistas muestran los datos actuales       (2.1 y 2.2)
     PARTE 3 · Modificar, revisar y eliminar una vista      (3.1 y 3.2)
     PARTE 4 · Guardar datos a través de una vista          (4.1 y 4.2)
     PARTE 5 · Todo junto                                   (5.1)

   Cómo trabajar:
     - Cada parte empieza con un recuadro que explica la instrucción.
       Leerlo antes de empezar los ejercicios.
     - Escribir la solución debajo de cada enunciado y ejecutarla sola.
     - Las PREGUNTAS se responden con un comentario (-- …) debajo de la
       solución.
     - Los ejercicios se hacen en orden: unos usan las vistas de otros.
     - Si algo sale mal, recargar la base con 01_base_datos.sql (también
       borra las vistas) y empezar este archivo de nuevo.

   Entrega: este mismo archivo con las soluciones y las respuestas.
   Tablas: autores, libros, socios, prestamos, multas.
   ===================================================================== */

SET NAMES utf8mb4;
USE biblioteca;

-- Workbench bloquea los UPDATE que no filtran por una clave (error
-- 1175). Esta línea lo permite solo durante esta sesión.
SET SQL_SAFE_UPDATES = 0;



/* =====================================================================
   ¿QUÉ ES UNA VISTA?
   ---------------------------------------------------------------------
   Una vista es una consulta guardada en la base de datos con un nombre.
   Se usa como si fuera una tabla (SELECT * FROM nombre_vista), pero NO
   guarda datos: cada vez que se consulta, MySQL ejecuta la consulta
   guardada sobre las tablas reales.

   Para qué sirve:
     - Simplificar: una consulta larga, con JOIN o subconsultas, se
       escribe una vez y después se consulta con un SELECT corto.
     - Mostrar solo una parte: una vista puede dejar fuera columnas o
       filas que no todos deben ver.
     - Reutilizar: varias personas o programas usan la misma consulta
       sin repetirla.
   ===================================================================== */



/* =====================================================================
   PARTE 1 · CREAR Y CONSULTAR UNA VISTA
   ---------------------------------------------------------------------
   CREATE VIEW nombre AS
   SELECT ...;                crea la vista con esa consulta.

   Después se consulta como una tabla, con WHERE, ORDER BY, etc.
   Ejemplo:  CREATE VIEW cursos_basicos AS
             SELECT nombre, precio FROM cursos WHERE nivel = 'Básico';

             SELECT * FROM cursos_basicos ORDER BY precio;
   ===================================================================== */

-- 1.1  Crear la vista contacto_socios con el nombre, el correo, el
--      teléfono y la ciudad de los socios. Consultarla completa y luego
--      solo el nombre y el teléfono de los socios de Valledupar.
--      PREGUNTA: ¿qué columnas de la tabla socios no se ven en la
--      vista? ¿Para qué puede servir eso?


-- 1.2  Crear la vista prestamos_pendientes con los préstamos sin
--      devolver: id del préstamo, nombre y teléfono del socio, título
--      del libro, fecha del préstamo y fecha límite (14 días después:
--      DATE_ADD(fecha_prestamo, INTERVAL 14 DAY)).
--      Consultarla completa y luego solo los préstamos con fecha límite
--      anterior al 2026-05-10.
--      PREGUNTA: ¿dónde están guardados los datos que muestra la vista?



/* =====================================================================
   PARTE 2 · LAS VISTAS MUESTRAN LOS DATOS ACTUALES
   ---------------------------------------------------------------------
   Como la vista ejecuta su consulta cada vez que se usa, cualquier
   cambio en las tablas (INSERT, UPDATE, DELETE) se ve de inmediato en
   la vista, sin tocarla.
   La consulta de una vista puede tener JOIN, GROUP BY y subconsultas.
   COALESCE(valor, 0) devuelve 0 cuando el valor es NULL; sirve, por
   ejemplo, cuando un SUM no encuentra filas.
   ===================================================================== */

-- 2.1  Kevin Arrieta devolvió "Cien años de soledad" (préstamo 22) el
--      2026-05-29. Registrarlo en la tabla prestamos y volver a
--      consultar la vista prestamos_pendientes.
--      PREGUNTA: ¿hubo que cambiar la vista para que se actualizara?
--      ¿Por qué?


-- 2.2  Crear la vista resumen_socios con el nombre y la ciudad de cada
--      socio, su cantidad de préstamos y el total que ha pagado en
--      multas (0 si no tiene). Usar subconsultas en el SELECT.
--      Consultar la vista para ver solo los socios con multas, del que
--      más pagó al que menos.
--      PREGUNTA: ¿qué ventaja tiene esta vista para quien solo necesita
--      consultar el reporte?



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
   ===================================================================== */

-- 3.1  Agregar el correo del socio a la vista prestamos_pendientes.
--      Probar primero con CREATE VIEW y después con CREATE OR REPLACE
--      VIEW. Luego ejecutar SHOW FULL TABLES y
--      SHOW CREATE VIEW prestamos_pendientes.
--      PREGUNTA: ¿qué pasó con CREATE VIEW? ¿Cómo distingue SHOW FULL
--      TABLES una tabla de una vista?


-- 3.2  Eliminar la vista contacto_socios y comprobar que la tabla
--      socios sigue con todos sus datos.
--      PREGUNTA: ¿qué borra DROP VIEW y qué no?



/* =====================================================================
   PARTE 4 · GUARDAR DATOS A TRAVÉS DE UNA VISTA
   ---------------------------------------------------------------------
   Si una vista toma columnas de una sola tabla, sin GROUP BY ni
   funciones de agregación, se puede hacer INSERT, UPDATE o DELETE
   sobre ella: el cambio se guarda en la tabla.
   WITH CHECK OPTION, escrito al final de la vista, impide guardar a
   través de ella filas que la vista no mostraría (que no cumplen su
   WHERE).
   Ejemplo:  CREATE VIEW cursos_basicos AS
             SELECT nombre, nivel, precio FROM cursos
             WHERE nivel = 'Básico'
             WITH CHECK OPTION;
   ===================================================================== */

-- 4.1  Crear la vista socios_valledupar (id, documento, nombre y ciudad
--      de los socios de Valledupar), SIN WITH CHECK OPTION. A través de
--      la vista, registrar a Carlos Pumarejo (1065011, Valledupar) y a
--      Laura Gutiérrez (1065012, Bosconia). Consultar la vista y luego
--      la tabla socios.
--      PREGUNTA: ¿dónde quedó guardada Laura? ¿Por qué no aparece en la
--      vista?


-- 4.2  Cambiar la vista socios_valledupar para que tenga WITH CHECK
--      OPTION y, a través de ella, intentar registrar a Andrés Oñate
--      (1065013, La Paz).
--      PREGUNTA: ¿qué error sale y qué problema del 4.1 evita?



/* =====================================================================
   PARTE 5 · TODO JUNTO
   ===================================================================== */

-- 5.1  Crear la vista reporte_libros con el título de cada libro, el
--      nombre del autor ('Sin autor' si no tiene), cuántas veces se ha
--      prestado y cuántos ejemplares quedan disponibles. Deben salir
--      los 12 libros.
--      Con la vista, responder:
--        a) ¿Cuáles son los 3 libros más prestados?
--        b) ¿Qué libros nunca se han prestado?
--        c) ¿Cuántas veces se ha prestado el libro sin autor?
