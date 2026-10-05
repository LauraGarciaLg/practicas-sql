/* =====================================================================
   LABORATORIO 01 · LENGUAJES DDL, DML Y DCL (y TCL)
   ---------------------------------------------------------------------
   Objetivo: reconocer, ejecutándolas, las cuatro familias de
   instrucciones de SQL y lo que cada una modifica.

   Base de datos: lab01_mapa (se crea y se borra en esta misma guía).
   No necesita la preparación 00.

   Cómo trabajar en MySQL Workbench:
     - Ejecutar UN bloque a la vez: seleccionar el bloque y presionar
       Ctrl+Shift+Enter (o poner el cursor en una instrucción y Ctrl+Enter).
     - Después de cada bloque, leer "OBSERVAR" y responder las
       "PREGUNTAS" en el cuaderno.
   ===================================================================== */

DROP DATABASE IF EXISTS lab01_mapa;
CREATE DATABASE lab01_mapa;
USE lab01_mapa;


/* ---------------------------------------------------------------------
   PASO 1 · DDL: CONSTRUIR LA ESTRUCTURA
   --------------------------------------------------------------------- */

CREATE TABLE salones (
    id_salon  INT PRIMARY KEY,
    nombre    VARCHAR(30) NOT NULL
);

SHOW TABLES;          -- ¿qué tablas existen?
DESCRIBE salones;     -- ¿qué columnas tiene?

-- Modificar la estructura: agregar una columna
ALTER TABLE salones ADD COLUMN capacidad INT;
DESCRIBE salones;

-- OBSERVAR: el panel de resultados muestra la estructura, no datos.
-- PREGUNTA 1.1: ¿Cuántas filas de datos tiene salones en este momento?
-- PREGUNTA 1.2: ¿Qué cambió entre el primer DESCRIBE y el segundo?


/* ---------------------------------------------------------------------
   PASO 2 · DML: TRABAJAR CON LOS DATOS
   --------------------------------------------------------------------- */

INSERT INTO salones (id_salon, nombre, capacidad) VALUES
    (1, 'Salón A', 20),
    (2, 'Salón B', 15),
    (3, 'Sala de spinning', 12);

SELECT * FROM salones;

UPDATE salones SET capacidad = 25 WHERE id_salon = 1;
SELECT * FROM salones;

DELETE FROM salones WHERE id_salon = 3;
SELECT * FROM salones;

-- OBSERVAR: DESCRIBE salones seguiría mostrando lo mismo; solo
--           cambiaron las filas.
-- PREGUNTA 2.1: ¿Qué mensaje muestra Workbench en "Output" después de
--               cada INSERT, UPDATE y DELETE? ¿Qué significa
--               "rows affected"?
-- PREGUNTA 2.2: ¿Por qué SELECT no muestra "rows affected"?


/* ---------------------------------------------------------------------
   PASO 3 · DCL: CONTROLAR QUIÉN PUEDE HACER QUÉ
   (requiere estar conectado como root o como usuario administrador)
   --------------------------------------------------------------------- */

DROP USER IF EXISTS 'lab01_invitado'@'localhost';
CREATE USER 'lab01_invitado'@'localhost' IDENTIFIED BY 'Lab01*2026';

SHOW GRANTS FOR 'lab01_invitado'@'localhost';     -- solo USAGE: no puede hacer nada

GRANT SELECT ON lab01_mapa.salones TO 'lab01_invitado'@'localhost';
SHOW GRANTS FOR 'lab01_invitado'@'localhost';     -- ahora puede leer salones

REVOKE SELECT ON lab01_mapa.salones FROM 'lab01_invitado'@'localhost';
SHOW GRANTS FOR 'lab01_invitado'@'localhost';     -- de nuevo sin permisos

-- OBSERVAR: ni la estructura ni los datos de salones cambiaron.
-- PREGUNTA 3.1: ¿Qué significa el permiso USAGE que aparece siempre?
-- PREGUNTA 3.2: ¿Sobre qué actúa el DCL, si no es sobre tablas ni filas?


/* ---------------------------------------------------------------------
   PASO 4 · TCL: CONFIRMAR O DESHACER CAMBIOS
   --------------------------------------------------------------------- */

START TRANSACTION;
    DELETE FROM salones;          -- se borran todas las filas…
    SELECT * FROM salones;        -- …la tabla aparece vacía
ROLLBACK;                         -- se deshace el borrado

SELECT * FROM salones;            -- las filas volvieron

-- PREGUNTA 4.1: ¿Qué habría pasado si en lugar de ROLLBACK se ejecuta COMMIT?


/* ---------------------------------------------------------------------
   PASO 5 · EXPERIMENTO: ¿TRUNCATE ES DML O DDL?
   --------------------------------------------------------------------- */

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
   --------------------------------------------------------------------- */

-- Limpieza final
DROP USER IF EXISTS 'lab01_invitado'@'localhost';
DROP DATABASE lab01_mapa;
