/* =====================================================================
   CASO GIMNASIO · 03_laboratorio.sql
   LENGUAJES DDL, DML, DCL Y TCL
   ---------------------------------------------------------------------
   Objetivo: reconocer, ejecutándolas sobre la base del gimnasio, las
   cuatro familias de instrucciones de SQL y lo que cada una modifica.

   Requisito: haber ejecutado 01_esquema.sql y luego 02_datos.sql.

   Este archivo tiene dos partes:
     PARTE A · Práctica guiada   (PASOS 1 a 6)
     PARTE B · Ejercicios        (EJERCICIOS 1 a 7)

   Cómo trabajar en MySQL Workbench:
     - Ejecutar UN bloque a la vez: seleccionar el bloque y presionar
       Ctrl+Shift+Enter (o poner el cursor en una instrucción y Ctrl+Enter).
     - En la PARTE A, después de cada bloque, leer "OBSERVAR" y responder
       las "PREGUNTAS" en el cuaderno.
     - En la PARTE B, cada estudiante escribe su solución debajo del
       enunciado y la ejecuta para comprobarla.
     - Si algo se daña, se vuelven a ejecutar 01_esquema.sql y
       02_datos.sql y se retoma el paso.
   ===================================================================== */

SET NAMES utf8mb4;
USE gimnasio;

-- Workbench bloquea los UPDATE y DELETE que no filtran por una clave
-- (error 1175). Esta línea lo permite solo durante esta sesión.
SET SQL_SAFE_UPDATES = 0;


/* =====================================================================
   PARTE A · PRÁCTICA GUIADA
   ===================================================================== */


/* ---------------------------------------------------------------------
   PASO 1 · DDL: CONSTRUIR Y MODIFICAR LA ESTRUCTURA
   --------------------------------------------------------------------- */

SHOW TABLES;          -- las 5 tablas que creó 01_esquema.sql
DESCRIBE clases;      -- ¿qué columnas tiene clases?

-- El gimnasio quiere registrar sus salones: una tabla nueva
CREATE TABLE salones (
    id_salon  INT PRIMARY KEY,
    nombre    VARCHAR(30) NOT NULL
);

SHOW TABLES;          -- ahora son 6
DESCRIBE salones;

-- Modificar la estructura: agregar una columna
ALTER TABLE salones ADD COLUMN capacidad INT;
DESCRIBE salones;

-- OBSERVAR: el panel de resultados muestra la estructura, no datos.
-- PREGUNTA 1.1: ¿Cuántas filas de datos tiene salones en este momento?
-- PREGUNTA 1.2: ¿Qué cambió entre el primer DESCRIBE salones y el segundo?
-- PREGUNTA 1.3: En DESCRIBE clases, ¿qué columna es la clave primaria y
--               cuál apunta a otra tabla? ¿A cuál?


/* ---------------------------------------------------------------------
   PASO 2 · DML: TRABAJAR CON LOS DATOS
   --------------------------------------------------------------------- */

-- INSERT: agregar filas
INSERT INTO salones (id_salon, nombre, capacidad) VALUES
    (1, 'Salón A', 20),
    (2, 'Salón B', 15),
    (3, 'Sala de spinning', 12);

SELECT * FROM salones;

-- SELECT: consultar (no modifica nada)
SELECT * FROM clientes;
SELECT nombre, precio FROM clases;

-- UPDATE: cambiar valores de filas que ya existen
UPDATE salones SET capacidad = 25 WHERE id_salon = 1;
UPDATE clases  SET precio = 65000 WHERE id_clase = 1;      -- Funcional AM sube de precio

SELECT * FROM salones;
SELECT * FROM clases;

-- DELETE: eliminar filas
DELETE FROM salones WHERE id_salon = 3;
DELETE FROM inscripciones WHERE id_cliente = 3 AND id_clase = 1;      -- Pedro se retira de Funcional AM

SELECT * FROM salones;
SELECT * FROM inscripciones;

-- OBSERVAR: DESCRIBE salones seguiría mostrando lo mismo; solo
--           cambiaron las filas.
-- PREGUNTA 2.1: ¿Qué mensaje muestra Workbench en "Output" después de
--               cada INSERT, UPDATE y DELETE? ¿Qué significa
--               "rows affected"?
-- PREGUNTA 2.2: ¿Por qué SELECT no muestra "rows affected"?
-- PREGUNTA 2.3: ¿Cuántas inscripciones había antes del DELETE y cuántas
--               quedaron?


/* ---------------------------------------------------------------------
   PASO 3 · DCL: CONTROLAR QUIÉN PUEDE HACER QUÉ
   (requiere estar conectado como root o como usuario administrador)
   --------------------------------------------------------------------- */

DROP USER IF EXISTS 'gim_invitado'@'localhost';
CREATE USER 'gim_invitado'@'localhost' IDENTIFIED BY 'Gim*2026';

SHOW GRANTS FOR 'gim_invitado'@'localhost';     -- solo USAGE: no puede hacer nada

GRANT SELECT ON gimnasio.clases TO 'gim_invitado'@'localhost';
SHOW GRANTS FOR 'gim_invitado'@'localhost';     -- ahora puede leer clases

REVOKE SELECT ON gimnasio.clases FROM 'gim_invitado'@'localhost';
SHOW GRANTS FOR 'gim_invitado'@'localhost';     -- de nuevo sin permisos

-- OBSERVAR: ni la estructura ni los datos de clases cambiaron.
-- PREGUNTA 3.1: ¿Qué significa el permiso USAGE que aparece siempre?
-- PREGUNTA 3.2: ¿Sobre qué actúa el DCL, si no es sobre tablas ni filas?
-- PREGUNTA 3.3: Mientras tuvo el permiso, ¿el invitado podía ver los
--               saldos de los clientes? ¿Por qué?


/* ---------------------------------------------------------------------
   PASO 4 · TCL: CONFIRMAR O DESHACER CAMBIOS
   --------------------------------------------------------------------- */

SELECT COUNT(*) FROM pagos;       -- 8 pagos

START TRANSACTION;
    DELETE FROM pagos;            -- se borran TODOS los pagos…
    SELECT COUNT(*) FROM pagos;   -- …la tabla aparece vacía
ROLLBACK;                         -- se deshace el borrado

SELECT COUNT(*) FROM pagos;       -- los 8 pagos volvieron

-- PREGUNTA 4.1: ¿Qué habría pasado si en lugar de ROLLBACK se ejecuta COMMIT?
-- PREGUNTA 4.2: ¿Por qué es útil poder "ensayar" un cambio antes de
--               confirmarlo?


/* ---------------------------------------------------------------------
   PASO 5 · EXPERIMENTO: ¿TRUNCATE ES DML O DDL?
   --------------------------------------------------------------------- */

SELECT * FROM salones;            -- 2 filas

START TRANSACTION;
    TRUNCATE TABLE salones;
ROLLBACK;

SELECT * FROM salones;            -- ¿volvieron las filas esta vez?

-- OBSERVAR: TRUNCATE produce un COMMIT implícito, como las demás
--           instrucciones DDL, así que ROLLBACK no puede deshacerlo.
-- PREGUNTA 5.1: Con base en este resultado, ¿TRUNCATE se comporta como
--               DML o como DDL? Justificar.
-- PREGUNTA 5.2: ¿En qué se diferencian DELETE FROM salones, TRUNCATE
--               TABLE salones y DROP TABLE salones?


/* ---------------------------------------------------------------------
   PASO 6 · CIERRE: COMPLETAR EN EL CUADERNO
   ---------------------------------------------------------------------
   | Sublenguaje | Instrucciones usadas hoy | ¿Qué modifica? |
   |-------------|--------------------------|----------------|
   | DDL         |                          |                |
   | DML         |                          |                |
   | DCL         |                          |                |
   | TCL         |                          |                |

   PREGUNTA 6.1: Los archivos 01_esquema.sql y 02_datos.sql, ¿a qué
                 sublenguaje pertenece cada uno?
   --------------------------------------------------------------------- */

-- Limpieza de la parte A
DROP USER IF EXISTS 'gim_invitado'@'localhost';
DROP TABLE salones;

-- Antes de la PARTE B: volver a ejecutar 01_esquema.sql y 02_datos.sql
-- para recuperar los datos originales.



/* =====================================================================
   PARTE B · EJERCICIOS
   ---------------------------------------------------------------------
   Requisito: base gimnasio recién cargada (01_esquema.sql y
   02_datos.sql). Cada estudiante escribe su solución debajo de cada
   enunciado y la ejecuta para comprobarla.
   ===================================================================== */

USE gimnasio;
SET SQL_SAFE_UPDATES = 0;


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
   El gimnasio va a llevar el inventario de sus máquinas. El estudiante
   crea la tabla maquinas con: id_maquina (entero, clave primaria),
   nombre (texto obligatorio de hasta 40 caracteres) y estado (texto de
   hasta 20 caracteres). Luego agrega la columna fecha_compra de tipo
   fecha y verifica la estructura con DESCRIBE.
*/
-- Solución:



/* EJERCICIO 3 · DML sobre la tabla nueva
   El estudiante inserta cuatro máquinas (caminadora, bicicleta,
   elíptica y banco de pesas), cambia a 'En reparación' el estado de la
   bicicleta y elimina el banco de pesas. Después de cada paso consulta
   la tabla.
*/
-- Solución:



/* EJERCICIO 4 · DML sobre las tablas del gimnasio
   a) Consultar el nombre y el saldo de todos los clientes.
   b) Camilo Ruiz (cliente 6) recarga 50.000: aumentar su saldo.
   c) Sofía Herrera (cliente 5) se inscribe en Yoga (clase 2): insertar
      la inscripción.
   d) Laura Sánchez (cliente 4) se retira de Spinning (clase 3):
      eliminar esa inscripción.
   Después de cada cambio, consultar la tabla para verificarlo.
*/
-- Solución:



/* EJERCICIO 5 · TCL
   El estudiante inicia una transacción, pone en 1 el precio de TODAS
   las clases, verifica el cambio y luego lo deshace. Al final comprueba
   que los precios originales se conservaron.
*/
-- Solución:



/* EJERCICIO 6 · DCL
   El estudiante crea el usuario 'gim_recepcion'@'localhost', le otorga
   permiso para consultar y actualizar la tabla clientes, revisa sus
   permisos, le quita el permiso de actualizar y vuelve a revisarlos.
   Al terminar elimina el usuario.
*/
-- Solución:



/* EJERCICIO 7 · Reflexión (responder en el cuaderno)
   a) ¿Por qué en un sistema real el DDL y el DCL suelen estar
      reservados al administrador, mientras que el DML lo ejecutan las
      aplicaciones?
   b) En el ejercicio 4, ¿qué instrucción habría fallado si Sofía ya
      estuviera inscrita en Yoga? ¿Qué parte del esquema lo impide?
*/
