/* =====================================================================
   LABORATORIO 02 · EJERCICIOS — Lenguaje SQL
   ---------------------------------------------------------------------
   Requisito: base gimnasio recién cargada con 00_preparacion.
   Cada estudiante escribe su solución debajo del enunciado y la ejecuta.
   ===================================================================== */

USE gimnasio;
SET SQL_SAFE_UPDATES = 0;


/* EJERCICIO 1 · CREATE TABLE con restricciones
   El gimnasio necesita registrar sus maquinas. El estudiante crea la
   tabla con: id_maquina (clave primaria autoincremental), nombre
   (obligatorio), precio_compra (dinero, debe ser mayor que cero),
   fecha_compra (fecha), estado (solo puede ser 'Activa', 'En reparación'
   o 'Retirada'; por defecto 'Activa') y id_entrenador_responsable
   (clave foránea hacia entrenadores).
*/
-- Solución:



/* EJERCICIO 2 · INSERT
   El estudiante inserta cinco máquinas. Al menos una sin indicar el
   estado, para comprobar el valor por defecto.
*/
-- Solución:



/* EJERCICIO 3 · Probar las restricciones
   El estudiante escribe TRES instrucciones que deban fallar sobre
   maquinas (una por CHECK de precio, una por el estado no permitido y
   una por la clave foránea) y anota el código de error de cada una.
*/
-- Solución:



/* EJERCICIO 4 · UPDATE
   a) Subir 5 % el precio de todas las clases de Carlos Rojas (id 1).
   b) Pasar a 'En reparación' las máquinas compradas antes de 2025.
   Antes de cada UPDATE, el estudiante ejecuta un SELECT con el mismo
   WHERE para verificar las filas afectadas.
*/
-- Solución:



/* EJERCICIO 5 · DELETE con integridad referencial
   El estudiante intenta borrar la clase Spinning (id 3), explica el
   error y luego la borra correctamente eliminando primero lo necesario.
*/
-- Solución:



/* EJERCICIO 6 · ALTER TABLE
   a) Agregar a clientes la columna fecha_nacimiento (fecha).
   b) Cambiar la clave foránea de clases para que, si se elimina un
      entrenador, sus clases queden sin entrenador (ON DELETE SET NULL).
      Pista: primero ALTER TABLE ... DROP FOREIGN KEY fk_clase_entrenador.
*/
-- Solución:



/* EJERCICIO 7 · Operadores
   a) Clientes registrados en el segundo trimestre de 2026.
   b) Clases que cuestan entre 50.000 y 60.000.
   c) Clientes cuyo nombre contiene la letra "a" en la segunda posición.
   d) Clientes sin teléfono o sin correo.
   e) Clientes que NO viven en Aguachica.
*/
-- Solución:

