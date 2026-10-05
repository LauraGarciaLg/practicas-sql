/* =====================================================================
   00 · PREPARACIÓN — 01_esquema.sql
   ---------------------------------------------------------------------
   Crea (o reinicia) la base de datos del gimnasio con sus 5 tablas,
   tal como quedó el diseño normalizado en 3FN.

   Cuándo ejecutarlo:
     - Antes de los laboratorios 03 a 07.
     - Siempre que la base quede dañada o con datos modificados.
   Después de este archivo se ejecuta 02_datos.sql.

   ATENCIÓN: borra la base "gimnasio" si ya existe.
   ===================================================================== */

SET NAMES utf8mb4;   -- tildes y ñ correctas también desde la consola

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
