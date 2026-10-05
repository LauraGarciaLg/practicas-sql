/* =====================================================================
   LABORATORIO 02 · LENGUAJE SQL
   Tipos de datos, restricciones, CREATE, INSERT, UPDATE, DELETE y
   operadores de filtro.
   ---------------------------------------------------------------------
   Objetivo: construir en MySQL la base del gimnasio a partir del
   esquema normalizado y comprobar cómo el SGBD protege los datos.

   IMPORTANTE: varios bloques producen ERRORES A PROPÓSITO. El error
   es parte de la práctica: se lee el mensaje en "Output" y se responde
   la pregunta. Por eso se ejecuta un bloque a la vez.
   ===================================================================== */


/* ---------------------------------------------------------------------
   PASO 1 · CREAR LA BASE Y LAS TABLAS (DDL)
   Esquema en 3FN: entrenadores, clientes, clases, inscripciones, pagos.
   Decisión de diseño: además del documento, cada cliente tiene un
   id_cliente numérico como clave (clave sustituta). El documento sigue
   siendo único gracias a UNIQUE.
   --------------------------------------------------------------------- */

DROP DATABASE IF EXISTS gimnasio;
CREATE DATABASE gimnasio CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE gimnasio;

CREATE TABLE entrenadores (
    id_entrenador  INT          PRIMARY KEY AUTO_INCREMENT,
    nombre         VARCHAR(80)  NOT NULL,
    especialidad   VARCHAR(50)  NOT NULL
);

CREATE TABLE clientes (
    id_cliente        INT            PRIMARY KEY AUTO_INCREMENT,
    documento         VARCHAR(15)    NOT NULL UNIQUE,
    nombre            VARCHAR(100)   NOT NULL,
    email             VARCHAR(100),
    telefono          VARCHAR(15),
    direccion_calle   VARCHAR(60),
    direccion_barrio  VARCHAR(40),
    direccion_ciudad  VARCHAR(40),
    fecha_registro    DATE           NOT NULL DEFAULT (CURRENT_DATE),
    saldo             DECIMAL(10,2)  NOT NULL DEFAULT 0,
    CONSTRAINT chk_saldo CHECK (saldo >= 0)
);

CREATE TABLE clases (
    id_clase       INT            PRIMARY KEY AUTO_INCREMENT,
    nombre         VARCHAR(50)    NOT NULL,
    cupo_maximo    INT            NOT NULL,
    precio         DECIMAL(10,2)  NOT NULL,
    id_entrenador  INT,
    CONSTRAINT chk_cupo   CHECK (cupo_maximo > 0),
    CONSTRAINT chk_precio CHECK (precio > 0),
    CONSTRAINT fk_clase_entrenador FOREIGN KEY (id_entrenador)
        REFERENCES entrenadores(id_entrenador)
);

CREATE TABLE inscripciones (
    id_cliente         INT,
    id_clase           INT,
    fecha_inscripcion  DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (id_cliente, id_clase),
    CONSTRAINT fk_insc_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_insc_clase   FOREIGN KEY (id_clase)   REFERENCES clases(id_clase)
);

CREATE TABLE pagos (
    id_pago     INT            PRIMARY KEY AUTO_INCREMENT,
    id_cliente  INT            NOT NULL,
    valor       DECIMAL(10,2)  NOT NULL,
    concepto    VARCHAR(100),
    fecha_pago  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_valor CHECK (valor > 0),
    CONSTRAINT fk_pago_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

SHOW TABLES;
DESCRIBE clases;
SHOW CREATE TABLE clases;

-- PREGUNTA 1.1: En DESCRIBE clases, ¿qué indican las columnas Null, Key
--               y Default?
-- PREGUNTA 1.2: ¿Por qué inscripciones tiene una clave primaria de dos
--               columnas?
-- PREGUNTA 1.3: ¿En qué orden deben crearse las tablas y por qué
--               entrenadores va antes que clases?


/* ---------------------------------------------------------------------
   PASO 2 · TIPOS DE DATOS: EL SGBD VALIDA LO QUE SE GUARDA
   --------------------------------------------------------------------- */

CREATE TABLE prueba_tipos (
    texto_corto  VARCHAR(5),
    fecha        DATE,
    dinero       DECIMAL(10,2),
    aproximado   FLOAT
);

-- 2a. Texto más largo de lo permitido  → ERROR esperado
INSERT INTO prueba_tipos (texto_corto) VALUES ('Aguachica');

-- 2b. Una fecha que no existe          → ERROR esperado
INSERT INTO prueba_tipos (fecha) VALUES ('2026-02-30');

-- 2c. DECIMAL vs FLOAT
INSERT INTO prueba_tipos (dinero, aproximado) VALUES (0.10, 0.10);
SELECT dinero * 3 AS con_decimal, aproximado * 3 AS con_float FROM prueba_tipos;

DROP TABLE prueba_tipos;

-- PREGUNTA 2.1: ¿Qué mensajes de error mostraron 2a y 2b?
-- PREGUNTA 2.2: ¿Qué columna dio exactamente 0.30? ¿Qué tipo debe usarse
--               para precios y saldos?
-- PREGUNTA 2.3: ¿Por qué telefono y documento se definieron como
--               VARCHAR y no como INT?


/* ---------------------------------------------------------------------
   PASO 3 · INSERT: LLENAR LAS TABLAS
   --------------------------------------------------------------------- */

INSERT INTO entrenadores (nombre, especialidad) VALUES
    ('Carlos Rojas', 'Funcional'), ('Diana Pérez', 'Yoga'),
    ('Andrés Quintero', 'Spinning'), ('Marcela Ortiz', 'Pilates'),
    ('Sergio Díaz', 'Boxeo');

INSERT INTO clases (nombre, cupo_maximo, precio, id_entrenador) VALUES
    ('Funcional AM', 3, 60000, 1), ('Yoga', 4, 50000, 2),
    ('Spinning', 2, 70000, 3), ('Pilates', 5, 55000, 4),
    ('Crossfit', 3, 80000, 1);

-- Insertar indicando solo algunas columnas: las demás toman su DEFAULT o NULL
INSERT INTO clientes (documento, nombre, email, direccion_ciudad, saldo)
VALUES ('1065001', 'Juan Martínez', 'juan@mail.com', 'Aguachica', 200000);

SELECT * FROM clientes;

-- PREGUNTA 3.1: ¿Qué valor quedó en fecha_registro sin haberlo escrito?
-- PREGUNTA 3.2: ¿Qué id_cliente asignó MySQL? ¿Quién lo generó?


/* ---------------------------------------------------------------------
   PASO 4 · RESTRICCIONES EN ACCIÓN
   Cada instrucción intenta violar una regla. Antes de ejecutarla, el
   estudiante predice si pasa o falla y por qué.
   --------------------------------------------------------------------- */

-- 4a. Clave primaria repetida
INSERT INTO clases VALUES (1, 'Boxeo', 10, 65000, 5);

-- 4b. CHECK: cupo en cero
INSERT INTO clases (nombre, cupo_maximo, precio, id_entrenador) VALUES ('Zumba', 0, 40000, 2);

-- 4c. FOREIGN KEY: entrenador que no existe
INSERT INTO clases (nombre, cupo_maximo, precio, id_entrenador) VALUES ('Boxeo', 8, 65000, 99);

-- 4d. UNIQUE: documento repetido
INSERT INTO clientes (documento, nombre) VALUES ('1065001', 'Otro Juan');

-- 4e. NOT NULL: cliente sin nombre
INSERT INTO clientes (documento) VALUES ('1065099');

-- 4f. CHECK: saldo negativo
UPDATE clientes SET saldo = -5000 WHERE id_cliente = 1;

-- PREGUNTA 4.1: Completar en el cuaderno: instrucción | ¿pasó? | restricción | código de error.
-- PREGUNTA 4.2: ¿Por qué es mejor que estas reglas estén en la base de
--               datos y no solo en la aplicación?


/* ---------------------------------------------------------------------
   PASO 5 · UPDATE Y EL MODO SEGURO DE WORKBENCH
   --------------------------------------------------------------------- */

-- Workbench trae activado el "modo de actualizaciones seguras".
SET SQL_SAFE_UPDATES = 1;

-- 5a. UPDATE filtrando por una columna que no es clave → ERROR 1175 esperado
UPDATE clases SET precio = precio * 1.10 WHERE nombre = 'Spinning';

-- Buena práctica: revisar primero QUÉ filas se van a modificar
SELECT * FROM clases WHERE nombre = 'Spinning';

-- 5b. Desactivar el modo seguro para esta sesión y repetir
SET SQL_SAFE_UPDATES = 0;
UPDATE clases SET precio = precio * 1.10 WHERE nombre = 'Spinning';
SELECT * FROM clases WHERE nombre = 'Spinning';

-- PREGUNTA 5.1: ¿Qué protege el modo seguro? ¿Qué pasaría con un UPDATE
--               sin WHERE si el modo seguro estuviera desactivado?


/* ---------------------------------------------------------------------
   PASO 6 · DELETE Y LA INTEGRIDAD REFERENCIAL
   --------------------------------------------------------------------- */

-- 6a. Borrar un entrenador que tiene clases  → ERROR 1451 esperado
DELETE FROM entrenadores WHERE id_entrenador = 1;

-- 6b. Borrar un entrenador sin clases        → funciona
DELETE FROM entrenadores WHERE id_entrenador = 5;
SELECT * FROM entrenadores;

-- PREGUNTA 6.1: ¿Por qué falló 6a y no 6b?
-- PREGUNTA 6.2: Si el gimnasio realmente quiere retirar a Carlos Rojas,
--               ¿qué habría que hacer antes con sus clases?


/* ---------------------------------------------------------------------
   PASO 7 · OPERADORES DE FILTRO
   Primero se cargan los datos completos del gimnasio.
   --------------------------------------------------------------------- */

-- Recargar los datos: abrir y ejecutar ../00_preparacion/01_esquema.sql
-- y ../00_preparacion/02_datos.sql. Luego continuar aquí.
USE gimnasio;

SELECT nombre, precio FROM clases WHERE precio > 60000;                         -- comparación
SELECT nombre FROM clases WHERE nombre <> 'Yoga';                               -- distinto
SELECT nombre, saldo FROM clientes
WHERE direccion_ciudad = 'Aguachica' AND saldo > 0;                             -- AND
SELECT nombre, direccion_ciudad FROM clientes
WHERE direccion_ciudad = 'Ocaña' OR direccion_ciudad = 'Bucaramanga';           -- OR
SELECT nombre, fecha_registro FROM clientes
WHERE fecha_registro BETWEEN '2026-01-01' AND '2026-03-31';                     -- BETWEEN
SELECT nombre FROM clases WHERE nombre IN ('Yoga', 'Pilates');                  -- IN
SELECT nombre FROM clientes WHERE nombre LIKE 'M%';                             -- empieza por M
SELECT nombre FROM clientes WHERE nombre LIKE '%ez';                            -- termina en ez
SELECT nombre FROM clientes WHERE email IS NULL;                                -- sin correo

-- La trampa del NULL
SELECT nombre FROM clientes WHERE email = NULL;

-- PREGUNTA 7.1: ¿Cuántas filas devolvió cada consulta?
-- PREGUNTA 7.2: ¿Por qué "email = NULL" no devuelve a Pedro Gómez, si
--               él no tiene correo?
-- PREGUNTA 7.3: ¿BETWEEN incluye o excluye los extremos? Comprobarlo.
