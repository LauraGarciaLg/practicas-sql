/* =====================================================================
   LABORATORIO 01 · EJERCICIOS — DDL, DML, DCL y TCL
   ---------------------------------------------------------------------
   Cada estudiante resuelve los ejercicios debajo de cada enunciado y
   ejecuta su solución para comprobarla.
   ===================================================================== */

DROP DATABASE IF EXISTS lab01_ejercicios;
CREATE DATABASE lab01_ejercicios;
USE lab01_ejercicios;


/* EJERCICIO 1 · Clasificación
   El estudiante escribe al lado de cada instrucción si es DDL, DML,
   DCL o TCL. No es necesario ejecutarlas.

   a) CREATE TABLE maquinas (…)                  → ______
   b) INSERT INTO maquinas VALUES (…)            → ______
   c) GRANT SELECT ON maquinas TO recepcion      → ______
   d) ALTER TABLE maquinas DROP COLUMN marca     → ______
   e) UPDATE maquinas SET estado = 'Dañada' …    → ______
   f) COMMIT                                      → ______
   g) TRUNCATE TABLE maquinas                     → ______
   h) SELECT * FROM maquinas                      → ______
   i) REVOKE INSERT ON maquinas FROM recepcion   → ______
   j) DROP TABLE maquinas                         → ______
*/


/* EJERCICIO 2 · DDL
   El estudiante crea la tabla maquinas con: id_maquina (entero, clave
   primaria), nombre (texto obligatorio de hasta 40 caracteres) y
   estado (texto de hasta 20 caracteres). Luego agrega la columna
   fecha_compra de tipo fecha y verifica la estructura con DESCRIBE.
*/
-- Solución:



/* EJERCICIO 3 · DML
   El estudiante inserta cuatro máquinas (caminadora, bicicleta,
   elíptica y banco de pesas), cambia a 'En reparación' el estado de la
   bicicleta y elimina el banco de pesas. Después de cada paso consulta
   la tabla.
*/
-- Solución:



/* EJERCICIO 4 · TCL
   El estudiante inicia una transacción, cambia el estado de TODAS las
   máquinas a 'Fuera de servicio', verifica el cambio y luego lo deshace.
   Al final comprueba que los estados originales se conservaron.
*/
-- Solución:



/* EJERCICIO 5 · DCL
   El estudiante crea el usuario 'lab01_tecnico'@'localhost', le
   otorga permiso para consultar y actualizar maquinas, revisa sus
   permisos, le quita el permiso de actualizar y vuelve a revisarlos.
   Al terminar elimina el usuario.
*/
-- Solución:



/* EJERCICIO 6 · Reflexión (responder en el cuaderno)
   ¿Por qué en un sistema real el DDL y el DCL suelen estar reservados
   al administrador, mientras que el DML lo ejecutan las aplicaciones?
*/
