/* =====================================================================
   CASO VETERINARIA · veterinaria.sql — EJERCICIO Y SOLUCIONES
   ---------------------------------------------------------------------
   La clínica Huellitas necesita una base de datos para su veterinaria.
   De cada veterinario se registra tarjeta profesional (requerida y
   única), nombre y especialidad (requeridos) y teléfono (opcional). De
   cada animal, nombre, especie, peso en kg con dos decimales y
   responsable, todos requeridos; además, cada animal tiene asignado un
   veterinario de cabecera.

   Cualquier veterinario puede atender a cualquier animal, muchas veces.
   De cada atención se registra fecha, motivo y valor (requeridos).

   1. Crear la base de datos con sus tablas, claves primarias, claves
      foráneas y las restricciones que piden las reglas. Luego insertar,
      con datos inventados que respeten las reglas, 3 veterinarios,
      3 animales y 6 atenciones repartidas entre varios veterinarios.
   2. Mostrar la fecha, el nombre del animal, el nombre del veterinario
      que lo atendió, el motivo y el valor de cada atención, de la más
      costosa a la más barata.
   3. Mostrar, por nombre de veterinario, cuántas atenciones hizo y
      cuánto facturó en total, del que más facturó al que menos.
   4. Agregar a los veterinarios un correo electrónico (opcional y
      único), registrar el de uno de ellos y mostrar el resultado.
   ===================================================================== */

/* =====================================================================
   SOLUCIONES
   ---------------------------------------------------------------------
   Modelo esperado, con 3 tablas:
     veterinarios 1 ── N animales       FK: veterinario de cabecera
     animales     N ── M veterinarios   tabla intermedia: atenciones

   Los datos son un ejemplo: si inventas los tuyos, los resultados de
   los ejercicios 2 a 4 cambian según esos datos. Este archivo se
   ejecuta completo.
   ===================================================================== */

SET NAMES utf8mb4;
SET SQL_SAFE_UPDATES = 0;


/* ---------- 1 · ESQUEMA Y DATOS ---------- */

DROP DATABASE IF EXISTS veterinaria;
CREATE DATABASE veterinaria CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE veterinaria;

CREATE TABLE veterinarios (
    id_veterinario       INT          PRIMARY KEY AUTO_INCREMENT,
    tarjeta_profesional  VARCHAR(20)  NOT NULL UNIQUE,
    nombre               VARCHAR(80)  NOT NULL,
    especialidad         VARCHAR(40)  NOT NULL,
    telefono             VARCHAR(15)                     -- opcional
);

-- 1:N — cada animal tiene un veterinario de cabecera.
CREATE TABLE animales (
    id_animal       INT           PRIMARY KEY AUTO_INCREMENT,
    nombre          VARCHAR(40)   NOT NULL,
    especie         VARCHAR(20)   NOT NULL,
    peso            DECIMAL(5,2)  NOT NULL,
    responsable     VARCHAR(100)  NOT NULL,
    id_veterinario  INT           NOT NULL,
    CONSTRAINT fk_animal_cabecera FOREIGN KEY (id_veterinario)
        REFERENCES veterinarios(id_veterinario)
);

-- N:M — un animal es atendido por muchos veterinarios y viceversa.
CREATE TABLE atenciones (
    id_atencion     INT            PRIMARY KEY AUTO_INCREMENT,
    id_animal       INT            NOT NULL,
    id_veterinario  INT            NOT NULL,
    fecha           DATE           NOT NULL,
    motivo          VARCHAR(30)    NOT NULL,
    valor           DECIMAL(10,2)  NOT NULL,
    CONSTRAINT fk_atencion_animal      FOREIGN KEY (id_animal)      REFERENCES animales(id_animal),
    CONSTRAINT fk_atencion_veterinario FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario)
);

INSERT INTO veterinarios (tarjeta_profesional, nombre, especialidad, telefono) VALUES
    ('TP-1001', 'Paula Castro', 'Medicina general', '3001112233'),
    ('TP-1002', 'Andrés Rojas', 'Cirugía',          NULL),
    ('TP-1003', 'Marta León',   'Dermatología',     '3205556677');

INSERT INTO animales (nombre, especie, peso, responsable, id_veterinario) VALUES
    ('Max',   'Perro', 30.50, 'Laura Gómez',  1),
    ('Luna',  'Gato',   4.20, 'Laura Gómez',  1),
    ('Rocky', 'Perro', 24.00, 'Carlos Pérez', 2);

-- Varios animales son atendidos por un veterinario distinto al de
-- cabecera: eso muestra la relación N:M.
INSERT INTO atenciones (id_animal, id_veterinario, fecha, motivo, valor) VALUES
    (1, 1, '2026-08-03', 'Vacunación',  60000),
    (2, 2, '2026-08-05', 'Control',     45000),
    (3, 2, '2026-08-10', 'Cirugía',    350000),
    (2, 1, '2026-08-18', 'Control',     50000),
    (3, 1, '2026-09-02', 'Vacunación',  65000),
    (1, 3, '2026-09-15', 'Urgencia',   120000);

-- Qué revisar:
--   - 3 tablas, aunque el enunciado no las nombra.
--   - PK en cada tabla; FK de animales a veterinarios (1:N) y la tabla
--     intermedia con FK a animales y a veterinarios (N:M).
--   - NOT NULL en los requeridos, UNIQUE en la tarjeta profesional,
--     teléfono sin NOT NULL, peso DECIMAL(…,2).
--   - 3 veterinarios, 3 animales y 6 atenciones bien relacionadas.


/* ---------- 2 · INNER JOIN Y ORDER BY ---------- */

SELECT a.fecha, an.nombre AS animal, v.nombre AS veterinario, a.motivo, a.valor
FROM atenciones a
INNER JOIN animales     an ON an.id_animal     = a.id_animal
INNER JOIN veterinarios v  ON v.id_veterinario = a.id_veterinario
ORDER BY a.valor DESC;
--  2026-08-10  Rocky  Andrés Rojas  Cirugía     350000.00
--  2026-09-15  Max    Marta León    Urgencia    120000.00
--  2026-09-02  Rocky  Paula Castro  Vacunación   65000.00
--  2026-08-03  Max    Paula Castro  Vacunación   60000.00
--  2026-08-18  Luna   Paula Castro  Control      50000.00
--  2026-08-05  Luna   Andrés Rojas  Control      45000.00


/* ---------- 3 · GROUP BY, COUNT Y SUM ---------- */

SELECT v.nombre AS veterinario, COUNT(*) AS atenciones, SUM(a.valor) AS total
FROM atenciones a
INNER JOIN veterinarios v ON v.id_veterinario = a.id_veterinario
GROUP BY v.nombre
ORDER BY total DESC;
--  Andrés Rojas  2  395000.00
--  Paula Castro  3  175000.00
--  Marta León    1  120000.00
--  Paula hizo más atenciones, pero Andrés facturó más.


/* ---------- 4 · ALTER ---------- */

ALTER TABLE veterinarios ADD COLUMN email VARCHAR(100) UNIQUE;
UPDATE veterinarios SET email = 'paula.castro@huellitas.com' WHERE tarjeta_profesional = 'TP-1001';
SELECT nombre, email FROM veterinarios;
--  Paula Castro  paula.castro@huellitas.com
--  Andrés Rojas  NULL
--  Marta León    NULL
