/* =====================================================================
   CASO ACADEMIA · 01_esquema.sql — DEL MODELO A LAS TABLAS
   ---------------------------------------------------------------------
   Crea (o reinicia) la base de datos de una academia de música con sus
   5 tablas. Todo este archivo es DDL: define la ESTRUCTURA, todavía sin
   datos.

   El negocio:
     - Los PROFESORES enseñan un instrumento.
     - Cada CURSO lo dicta un profesor (o ninguno, si aún no se asigna).
     - Un ESTUDIANTE se MATRICULA en varios cursos y un curso tiene
       varios estudiantes (relación muchos a muchos → tabla matriculas).
     - Los PAGOS los hace un estudiante. Los de 'Mensualidad' y
       'Material' corresponden a un curso; el de 'Matrícula' es la cuota
       de ingreso a la academia y no corresponde a ningún curso.

   Antes de ejecutarlo, ubicar en cada CREATE TABLE:
     - la clave primaria (PRIMARY KEY)
     - las claves foráneas (FOREIGN KEY … REFERENCES)
     - las reglas del negocio (NOT NULL, UNIQUE, CHECK, DEFAULT)

   Se ejecuta COMPLETO. Después de este archivo se ejecuta 02_datos.sql.

   ATENCIÓN: borra la base "academia" si ya existe.
   ===================================================================== */

SET NAMES utf8mb4;   -- tildes y ñ correctas también desde la consola

DROP DATABASE IF EXISTS academia;
CREATE DATABASE academia CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE academia;

CREATE TABLE profesores (
    id_profesor    INT           PRIMARY KEY AUTO_INCREMENT,
    nombre         VARCHAR(80)   NOT NULL,
    instrumento    VARCHAR(40)   NOT NULL,
    email          VARCHAR(100)  UNIQUE,
    fecha_ingreso  DATE          NOT NULL
);

CREATE TABLE estudiantes (
    id_estudiante     INT           PRIMARY KEY AUTO_INCREMENT,
    documento         VARCHAR(15)   NOT NULL UNIQUE,
    nombre            VARCHAR(100)  NOT NULL,
    email             VARCHAR(100),
    telefono          VARCHAR(15),
    ciudad            VARCHAR(40)   NOT NULL,
    fecha_nacimiento  DATE,
    fecha_registro    DATE          NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE cursos (
    id_curso     INT            PRIMARY KEY AUTO_INCREMENT,
    nombre       VARCHAR(50)    NOT NULL UNIQUE,
    nivel        VARCHAR(15)    NOT NULL DEFAULT 'Básico',
    cupo_maximo  INT            NOT NULL,
    precio       DECIMAL(10,2)  NOT NULL,          -- valor de la mensualidad
    id_profesor  INT,                              -- NULL: sin profesor asignado
    CONSTRAINT chk_nivel  CHECK (nivel IN ('Básico', 'Intermedio', 'Avanzado')),
    CONSTRAINT chk_cupo   CHECK (cupo_maximo > 0),
    CONSTRAINT chk_precio CHECK (precio > 0),
    CONSTRAINT fk_curso_profesor FOREIGN KEY (id_profesor)
        REFERENCES profesores(id_profesor)
);

CREATE TABLE matriculas (
    id_estudiante    INT,
    id_curso         INT,
    fecha_matricula  DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (id_estudiante, id_curso),
    CONSTRAINT fk_matr_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT fk_matr_curso      FOREIGN KEY (id_curso)      REFERENCES cursos(id_curso)
);

CREATE TABLE pagos (
    id_pago        INT            PRIMARY KEY AUTO_INCREMENT,
    id_estudiante  INT            NOT NULL,
    id_curso       INT,                            -- NULL en los pagos de 'Matrícula'
    valor          DECIMAL(10,2)  NOT NULL,
    concepto       VARCHAR(20)    NOT NULL,
    fecha_pago     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_valor    CHECK (valor > 0),
    CONSTRAINT chk_concepto CHECK (concepto IN ('Matrícula', 'Mensualidad', 'Material')),
    CONSTRAINT fk_pago_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT fk_pago_curso      FOREIGN KEY (id_curso)      REFERENCES cursos(id_curso)
);

SHOW TABLES;
