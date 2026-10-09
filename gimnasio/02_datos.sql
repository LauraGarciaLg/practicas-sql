/* =====================================================================
   CASO GIMNASIO · 02_datos.sql — LOS DATOS DE PRUEBA
   ---------------------------------------------------------------------
   Carga los datos del gimnasio. Todo este archivo es DML: llena las
   tablas que creó 01_esquema.sql, sin cambiar su estructura.

   Se ejecuta COMPLETO, justo después de 01_esquema.sql, y deja la base
   en un estado conocido: 5 entrenadores, 6 clientes, 5 clases,
   8 inscripciones y 8 pagos.
   ===================================================================== */

SET NAMES utf8mb4;   -- tildes y ñ correctas también desde la consola

USE gimnasio;

INSERT INTO entrenadores (id_entrenador, nombre, especialidad) VALUES
    (1, 'Carlos Rojas',    'Funcional'),
    (2, 'Diana Pérez',     'Yoga'),
    (3, 'Andrés Quintero', 'Spinning'),
    (4, 'Marcela Ortiz',   'Pilates'),
    (5, 'Sergio Díaz',     'Boxeo');          -- sin clases asignadas

INSERT INTO clientes (id_cliente, documento, nombre, email, telefono,
                      direccion_calle, direccion_barrio, direccion_ciudad,
                      fecha_registro, saldo) VALUES
    (1, '1065001', 'Juan Martínez', 'juan@mail.com',   '3001112233', 'Cra 5 #10-20', 'Centro',     'Aguachica',   '2026-01-15', 200000),
    (2, '1065002', 'María López',   'maria@mail.com',  '3002223344', 'Cl 8 #3-15',   'Villa Paz',  'Aguachica',   '2026-02-03', 150000),
    (3, '1065003', 'Pedro Gómez',   NULL,              '3003334455', 'Cra 12 #4-8',  'San Martín', 'Aguachica',   '2026-03-20',  50000),
    (4, '1065004', 'Laura Sánchez', 'laura@mail.com',  NULL,         'Cl 20 #7-30',  'El Carmen',  'Bucaramanga', '2026-04-11', 300000),
    (5, '1065005', 'Sofía Herrera', 'sofia@mail.com',  '3005556677', 'Cra 3 #2-1',   'Centro',     'Aguachica',   '2026-05-02',      0),
    (6, '1065006', 'Camilo Ruiz',   'camilo@mail.com', '3006667788', 'Cl 5 #9-12',   'La Ondina',  'Ocaña',       '2026-06-10',  80000);

INSERT INTO clases (id_clase, nombre, cupo_maximo, precio, id_entrenador) VALUES
    (1, 'Funcional AM', 3, 60000, 1),
    (2, 'Yoga',         4, 50000, 2),
    (3, 'Spinning',     2, 70000, 3),
    (4, 'Pilates',      5, 55000, 4),
    (5, 'Crossfit',     3, 80000, 1);          -- sin inscritos

INSERT INTO inscripciones (id_cliente, id_clase, fecha_inscripcion) VALUES
    (1, 1, '2026-02-01'), (1, 3, '2026-02-01'),
    (2, 2, '2026-02-10'), (2, 4, '2026-03-01'),
    (3, 1, '2026-03-25'),
    (4, 2, '2026-04-15'), (4, 3, '2026-04-15'), (4, 4, '2026-04-20');

INSERT INTO pagos (id_cliente, valor, concepto, fecha_pago) VALUES
    (1, 60000, 'Funcional AM', '2026-02-01 08:00:00'),
    (1, 70000, 'Spinning',     '2026-02-01 08:05:00'),
    (2, 50000, 'Yoga',         '2026-02-10 17:30:00'),
    (2, 55000, 'Pilates',      '2026-03-01 18:00:00'),
    (3, 60000, 'Funcional AM', '2026-03-25 07:10:00'),
    (4, 50000, 'Yoga',         '2026-04-15 16:00:00'),
    (4, 70000, 'Spinning',     '2026-04-15 16:05:00'),
    (4, 55000, 'Pilates',      '2026-04-20 16:10:00');

-- Verificación: cantidad de filas por tabla
SELECT 'entrenadores' AS tabla, COUNT(*) AS filas FROM entrenadores
UNION ALL SELECT 'clientes',      COUNT(*) FROM clientes
UNION ALL SELECT 'clases',        COUNT(*) FROM clases
UNION ALL SELECT 'inscripciones', COUNT(*) FROM inscripciones
UNION ALL SELECT 'pagos',         COUNT(*) FROM pagos;
-- Resultado esperado: 5, 6, 5, 8, 8
