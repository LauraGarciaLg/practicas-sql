/* =====================================================================
   CASO ACADEMIA · 02_datos.sql — LOS DATOS DE PRUEBA
   ---------------------------------------------------------------------
   Carga los datos de la academia. Todo este archivo es DML: llena las
   tablas que creó 01_esquema.sql, sin cambiar su estructura.

   Se ejecuta COMPLETO, justo después de 01_esquema.sql, y deja la base
   en un estado conocido: 6 profesores, 12 estudiantes, 8 cursos,
   17 matrículas y 34 pagos.

   Casos especiales, pensados para las consultas:
     - Felipe Arango (profesor 6) no tiene cursos.
     - Teoría Musical (curso 8) no tiene profesor asignado.
     - Violín Inicial (curso 6) no tiene estudiantes matriculados.
     - Tomás Navarro (11) no tiene matrículas ni pagos.
     - Isabel Romero (12) pagó la cuota de ingreso pero no se ha
       matriculado en ningún curso.
   ===================================================================== */

SET NAMES utf8mb4;   -- tildes y ñ correctas también desde la consola

USE academia;

INSERT INTO profesores (id_profesor, nombre, instrumento, email, fecha_ingreso) VALUES
    (1, 'Valentina Ríos',  'Piano',    'vrios@academia.co',     '2022-01-10'),
    (2, 'Jorge Castillo',  'Guitarra', 'jcastillo@academia.co', '2021-07-05'),
    (3, 'Natalia Vargas',  'Canto',    'nvargas@academia.co',   '2023-02-01'),
    (4, 'Ricardo Mendoza', 'Violín',   'rmendoza@academia.co',  '2024-08-15'),
    (5, 'Paola Jiménez',   'Batería',  'pjimenez@academia.co',  '2025-01-20'),
    (6, 'Felipe Arango',   'Saxofón',  NULL,                    '2026-06-01');   -- sin cursos

INSERT INTO estudiantes (id_estudiante, documento, nombre, email, telefono,
                         ciudad, fecha_nacimiento, fecha_registro) VALUES
    ( 1, '1098001', 'Ana Beltrán',     'ana@mail.com',     '3101112233', 'Aguachica',   '2008-03-14', '2026-02-02'),
    ( 2, '1098002', 'Luis Carrillo',   'luis@mail.com',    '3102223344', 'Aguachica',   '2007-11-02', '2026-02-05'),
    ( 3, '1098003', 'Daniela Torres',  NULL,               '3103334455', 'Ocaña',       '2010-06-21', '2026-02-10'),
    ( 4, '1098004', 'Mateo Salazar',   'mateo@mail.com',   '3104445566', 'Bucaramanga', '2005-01-30', '2026-02-15'),
    ( 5, '1098005', 'Sara Pineda',     'sara@mail.com',    NULL,         'Aguachica',   '2009-09-09', '2026-03-01'),
    ( 6, '1098006', 'Nicolás Acosta',  'nico@mail.com',    '3106667788', 'Gamarra',     '2006-12-12', '2026-03-03'),
    ( 7, '1098007', 'Juliana Rueda',   'juliana@mail.com', '3107778899', 'Ocaña',       '2008-07-07', '2026-03-10'),
    ( 8, '1098008', 'Samuel Ortega',   'samuel@mail.com',  '3108889900', 'Aguachica',   '2004-04-18', '2026-04-01'),
    ( 9, '1098009', 'Valeria Quiroga', 'valeria@mail.com', '3109990011', 'Bucaramanga', '2011-02-25', '2026-04-05'),
    (10, '1098010', 'Andrés Cárdenas', NULL,               '3100001122', 'Aguachica',   '2007-05-15', '2026-04-20'),
    (11, '1098011', 'Tomás Navarro',   'tomas@mail.com',   '3111112233', 'Gamarra',     '2009-10-01', '2026-05-02'),   -- sin matrículas ni pagos
    (12, '1098012', 'Isabel Romero',   'isabel@mail.com',  '3112223344', 'Ocaña',       '2010-08-30', '2026-05-10');   -- solo pagó la matrícula

INSERT INTO cursos (id_curso, nombre, nivel, cupo_maximo, precio, id_profesor) VALUES
    (1, 'Piano Básico',       'Básico',      6, 180000, 1),
    (2, 'Piano Intermedio',   'Intermedio',  4, 220000, 1),
    (3, 'Guitarra Acústica',  'Básico',      8, 150000, 2),
    (4, 'Guitarra Eléctrica', 'Intermedio',  6, 170000, 2),
    (5, 'Técnica Vocal',      'Básico',     10, 140000, 3),
    (6, 'Violín Inicial',     'Básico',      5, 200000, 4),   -- sin matriculados
    (7, 'Batería Rock',       'Intermedio',  4, 190000, 5),
    (8, 'Teoría Musical',     'Básico',     15,  90000, NULL); -- sin profesor

INSERT INTO matriculas (id_estudiante, id_curso, fecha_matricula) VALUES
    ( 1, 1, '2026-02-02'), ( 1, 8, '2026-02-02'),
    ( 2, 3, '2026-02-05'), ( 2, 5, '2026-02-05'),
    ( 3, 1, '2026-02-10'),
    ( 4, 4, '2026-02-15'), ( 4, 8, '2026-02-15'),
    ( 5, 5, '2026-03-01'),
    ( 6, 2, '2026-03-03'), ( 6, 8, '2026-03-03'),
    ( 7, 3, '2026-03-10'), ( 7, 7, '2026-03-12'),
    ( 8, 7, '2026-04-01'),
    ( 9, 5, '2026-04-05'), ( 9, 8, '2026-04-05'),
    (10, 3, '2026-04-20'), (10, 4, '2026-04-20');

INSERT INTO pagos (id_estudiante, id_curso, valor, concepto, fecha_pago) VALUES
    -- Cuota de ingreso a la academia: no corresponde a un curso
    ( 1, NULL, 40000, 'Matrícula', '2026-02-02 09:00:00'),
    ( 2, NULL, 40000, 'Matrícula', '2026-02-05 10:00:00'),
    ( 3, NULL, 40000, 'Matrícula', '2026-02-10 15:00:00'),
    ( 4, NULL, 40000, 'Matrícula', '2026-02-15 11:00:00'),
    ( 5, NULL, 40000, 'Matrícula', '2026-03-01 08:30:00'),
    ( 6, NULL, 40000, 'Matrícula', '2026-03-03 16:00:00'),
    ( 7, NULL, 40000, 'Matrícula', '2026-03-10 17:00:00'),
    ( 8, NULL, 40000, 'Matrícula', '2026-04-01 09:15:00'),
    ( 9, NULL, 40000, 'Matrícula', '2026-04-05 14:00:00'),
    (10, NULL, 40000, 'Matrícula', '2026-04-20 10:30:00'),
    (12, NULL, 40000, 'Matrícula', '2026-05-10 12:00:00'),
    -- Primera mensualidad de cada curso matriculado (valor = precio del curso)
    ( 1, 1, 180000, 'Mensualidad', '2026-02-02 09:05:00'),
    ( 1, 8,  90000, 'Mensualidad', '2026-02-02 09:06:00'),
    ( 2, 3, 150000, 'Mensualidad', '2026-02-05 10:05:00'),
    ( 2, 5, 140000, 'Mensualidad', '2026-02-05 10:06:00'),
    ( 3, 1, 180000, 'Mensualidad', '2026-02-10 15:05:00'),
    ( 4, 4, 170000, 'Mensualidad', '2026-02-15 11:05:00'),
    ( 4, 8,  90000, 'Mensualidad', '2026-02-15 11:06:00'),
    ( 5, 5, 140000, 'Mensualidad', '2026-03-01 08:35:00'),
    ( 6, 2, 220000, 'Mensualidad', '2026-03-03 16:05:00'),
    ( 6, 8,  90000, 'Mensualidad', '2026-03-03 16:06:00'),
    ( 7, 3, 150000, 'Mensualidad', '2026-03-10 17:05:00'),
    ( 7, 7, 190000, 'Mensualidad', '2026-03-12 18:00:00'),
    ( 8, 7, 190000, 'Mensualidad', '2026-04-01 09:20:00'),
    ( 9, 5, 140000, 'Mensualidad', '2026-04-05 14:05:00'),
    ( 9, 8,  90000, 'Mensualidad', '2026-04-05 14:06:00'),
    (10, 3, 150000, 'Mensualidad', '2026-04-20 10:35:00'),
    (10, 4, 170000, 'Mensualidad', '2026-04-20 10:36:00'),
    -- Segunda mensualidad
    ( 1, 1, 180000, 'Mensualidad', '2026-03-02 09:00:00'),
    ( 2, 3, 150000, 'Mensualidad', '2026-03-05 10:00:00'),
    ( 4, 4, 170000, 'Mensualidad', '2026-03-15 11:00:00'),
    -- Material de estudio
    ( 1, 1,  35000, 'Material',    '2026-02-02 09:10:00'),
    ( 7, 7,  60000, 'Material',    '2026-03-12 18:05:00'),
    ( 9, 5,  25000, 'Material',    '2026-04-05 14:10:00');

-- Verificación: cantidad de filas por tabla
SELECT 'profesores' AS tabla, COUNT(*) AS filas FROM profesores
UNION ALL SELECT 'estudiantes', COUNT(*) FROM estudiantes
UNION ALL SELECT 'cursos',      COUNT(*) FROM cursos
UNION ALL SELECT 'matriculas',  COUNT(*) FROM matriculas
UNION ALL SELECT 'pagos',       COUNT(*) FROM pagos;
-- Resultado esperado: 6, 12, 8, 17, 34
