/* =====================================================================
   LABORATORIO 07 · TCL — TRANSACCIONES
   START TRANSACTION · COMMIT · ROLLBACK · SAVEPOINT · bloqueos
   ---------------------------------------------------------------------
   Objetivo: agrupar varias instrucciones DML en una unidad que se
   aplica completa o no se aplica, y observar qué pasa cuando dos
   sesiones modifican los mismos datos al mismo tiempo.

   Requisito: base tienda recién cargada con 00_preparacion.

   Cómo trabajar: UNA instrucción o bloque pequeño a la vez, en el orden
   escrito. En este laboratorio el orden lo es todo: si algo sale
   distinto a lo descrito, ejecutar ROLLBACK, recargar 00_preparacion y
   repetir el paso.

   Los PASOS 1 a 8 usan una sola conexión. El PASO 9 usa dos, con los
   archivos sesion_A.sql y sesion_B.sql.

   Nota para DBeaver: la conexión debe estar en modo "Auto-Commit" (es
   el modo por defecto). Las transacciones se abren y cierran aquí con
   instrucciones SQL, no con los botones de la barra.
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;
SET SQL_SAFE_UPDATES = 0;


/* ---------------------------------------------------------------------
   PASO 1 · AUTOCOMMIT: CADA INSTRUCCIÓN ES UNA TRANSACCIÓN
   --------------------------------------------------------------------- */

SELECT @@autocommit;              -- 1 = activado

UPDATE clientes SET telefono = '3000000000' WHERE id_cliente = 1;
ROLLBACK;                         -- no hay nada que deshacer…
SELECT id_cliente, nombre, telefono FROM clientes WHERE id_cliente = 1;

-- Se deja como estaba
UPDATE clientes SET telefono = '3105550101' WHERE id_cliente = 1;

-- PREGUNTA 1.1: ¿Por qué el ROLLBACK no recuperó el teléfono original?
-- PREGUNTA 1.2: Con autocommit activado, ¿en qué momento queda
--               confirmado cada INSERT, UPDATE o DELETE?


/* ---------------------------------------------------------------------
   PASO 2 · START TRANSACTION … ROLLBACK
   --------------------------------------------------------------------- */

SELECT COUNT(*) FROM pagos;                   -- 164

START TRANSACTION;

    DELETE FROM pagos;                        -- sin WHERE: se borra TODO
    SELECT COUNT(*) FROM pagos;               -- 0: así lo ve esta sesión

ROLLBACK;

SELECT COUNT(*) FROM pagos;                   -- ¿cuántos hay ahora?

-- PREGUNTA 2.1: ¿Qué habría pasado con los 164 pagos si en lugar de
--               ROLLBACK se hubiera ejecutado COMMIT?
-- PREGUNTA 2.2: Entre el DELETE y el ROLLBACK, ¿qué veía OTRA sesión
--               conectada a la misma base: 0 o 164? Anotar la
--               predicción; se comprueba en el PASO 9.


/* ---------------------------------------------------------------------
   PASO 3 · START TRANSACTION … COMMIT
   --------------------------------------------------------------------- */

START TRANSACTION;

    UPDATE productos SET precio = precio + 10000 WHERE id_producto = 31;
    UPDATE productos SET precio = precio + 10000 WHERE id_producto = 33;

COMMIT;

ROLLBACK;                                     -- demasiado tarde
SELECT id_producto, nombre, precio FROM productos WHERE id_producto IN (31, 33);

-- PREGUNTA 3.1: ¿Se puede deshacer una transacción después del COMMIT?
--               ¿Cómo se "corrige" entonces un cambio ya confirmado?


/* ---------------------------------------------------------------------
   PASO 4 · UNA VENTA ES UNA TRANSACCIÓN
   Registrar una venta toca cuatro tablas. Si solo se aplica una parte,
   la base queda inconsistente: un pedido sin productos, un stock que no
   se descontó, un pago sin pedido…

   Venta: Álvaro Jiménez (cliente 22) compra 2 unidades del producto 23
   y 1 del producto 27 en la sucursal 1, con la vendedora 5. Paga en
   efectivo.
   --------------------------------------------------------------------- */

SELECT id_producto, nombre, precio, stock FROM productos WHERE id_producto IN (23, 27);

START TRANSACTION;

    -- 1. El encabezado del pedido
    INSERT INTO pedidos (id_cliente, id_empleado, id_sucursal, estado)
    VALUES (22, 5, 1, 'Pagado');

    SET @pedido = LAST_INSERT_ID();           -- el número que recibió el pedido

    -- 2. Las líneas, con el precio de lista de este momento
    INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
    SELECT @pedido, id_producto, 2, precio FROM productos WHERE id_producto = 23;

    INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
    SELECT @pedido, id_producto, 1, precio FROM productos WHERE id_producto = 27;

    -- 3. El inventario
    UPDATE productos SET stock = stock - 2 WHERE id_producto = 23;
    UPDATE productos SET stock = stock - 1 WHERE id_producto = 27;

    -- 4. El pago, por el total del pedido
    INSERT INTO pagos (id_pedido, valor, metodo)
    SELECT @pedido, SUM(cantidad * precio_unitario * (1 - descuento)), 'Efectivo'
    FROM detalle_pedido
    WHERE id_pedido = @pedido;

    -- Revisión ANTES de confirmar
    SELECT * FROM pedidos        WHERE id_pedido = @pedido;
    SELECT * FROM detalle_pedido WHERE id_pedido = @pedido;
    SELECT * FROM pagos          WHERE id_pedido = @pedido;

COMMIT;

SELECT id_producto, nombre, stock FROM productos WHERE id_producto IN (23, 27);

-- PREGUNTA 4.1: ¿Qué número recibió el pedido? ¿De cuánto fue el pago?
-- PREGUNTA 4.2: Si el servidor se apaga justo después del paso 3 y
--               antes del COMMIT, ¿qué queda guardado al reiniciar?
--               ¿Qué propiedad ACID lo garantiza?


/* ---------------------------------------------------------------------
   PASO 5 · CUANDO ALGO FALLA A MITAD DE CAMINO
   Otra venta: el cliente 22 quiere 2 unidades del producto 8… que está
   agotado (stock 0). El CHECK de stock no permite valores negativos.
   --------------------------------------------------------------------- */

START TRANSACTION;

    INSERT INTO pedidos (id_cliente, id_empleado, id_sucursal, estado)
    VALUES (22, 5, 1, 'Pagado');

    SET @pedido = LAST_INSERT_ID();

    INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
    SELECT @pedido, id_producto, 2, precio FROM productos WHERE id_producto = 8;

    -- → ERROR 3819 esperado: el stock quedaría en -2
    UPDATE productos SET stock = stock - 2 WHERE id_producto = 8;

    -- La transacción SIGUE ABIERTA. El pedido y su línea están ahí:
    SELECT * FROM pedidos        WHERE id_pedido = @pedido;
    SELECT * FROM detalle_pedido WHERE id_pedido = @pedido;

-- La instrucción que falló no se aplicó, pero las anteriores sí están
-- pendientes. Quien decide qué hacer es quien controla la transacción:
ROLLBACK;

SELECT * FROM pedidos WHERE id_pedido = @pedido;          -- ya no existe

-- PREGUNTA 5.1: Después del error, ¿MySQL deshizo la transacción por su
--               cuenta? ¿Qué habría quedado en la base si se ejecuta
--               COMMIT en lugar de ROLLBACK?
-- PREGUNTA 5.2: En una aplicación real, ¿quién detecta el error y
--               ordena el ROLLBACK?
-- PREGUNTA 5.3: Consultar SELECT MAX(id_pedido) FROM pedidos e insertar
--               luego un pedido de prueba dentro de una transacción con
--               ROLLBACK. ¿El número "gastado" por el pedido deshecho se
--               reutiliza?


/* ---------------------------------------------------------------------
   PASO 6 · SAVEPOINT: DESHACER SOLO UNA PARTE
   --------------------------------------------------------------------- */

SELECT id_producto, nombre, precio FROM productos WHERE id_categoria = 13;

START TRANSACTION;

    UPDATE productos SET precio = precio * 1.10 WHERE id_categoria = 13;     -- monitores +10 %
    SAVEPOINT monitores_listos;

    UPDATE productos SET precio = precio * 2 WHERE id_categoria = 12;        -- ¡error de digitación!
    SELECT id_producto, nombre, precio FROM productos WHERE id_categoria IN (12, 13);

    ROLLBACK TO SAVEPOINT monitores_listos;                                  -- solo se deshace lo último
    SELECT id_producto, nombre, precio FROM productos WHERE id_categoria IN (12, 13);

    UPDATE productos SET precio = precio * 1.02 WHERE id_categoria = 12;     -- lo que se quería hacer

COMMIT;

SELECT id_producto, nombre, precio FROM productos WHERE id_categoria IN (12, 13);

-- 6a. Fuera de una transacción el punto de guardado ya no existe
--     → ERROR 1305 esperado
ROLLBACK TO SAVEPOINT monitores_listos;

-- PREGUNTA 6.1: Después de ROLLBACK TO SAVEPOINT, ¿la transacción quedó
--               cerrada o sigue abierta? ¿Cómo se sabe?
-- PREGUNTA 6.2: ¿Qué cambios quedaron confirmados al final y cuál no?


/* ---------------------------------------------------------------------
   PASO 7 · EL DDL CONFIRMA SIN PREGUNTAR (COMMIT IMPLÍCITO)
   --------------------------------------------------------------------- */

-- 7a. Un DDL en medio de una transacción
START TRANSACTION;

    UPDATE clientes SET ciudad = 'CIUDAD EQUIVOCADA' WHERE id_cliente = 2;

    CREATE TABLE tabla_cualquiera (id INT);       -- DDL

ROLLBACK;

SELECT id_cliente, nombre, ciudad FROM clientes WHERE id_cliente = 2;      -- ¿se deshizo?

UPDATE clientes SET ciudad = 'Aguachica' WHERE id_cliente = 2;              -- reparación manual
DROP TABLE tabla_cualquiera;

-- 7b. La predicción de los laboratorios 01 y 02: DELETE, TRUNCATE y DROP
CREATE TABLE envios_copia AS SELECT * FROM envios;

START TRANSACTION;
    DELETE FROM envios_copia;
ROLLBACK;
SELECT COUNT(*) FROM envios_copia;            -- DELETE: ¿volvieron las filas?

START TRANSACTION;
    TRUNCATE TABLE envios_copia;
ROLLBACK;
SELECT COUNT(*) FROM envios_copia;            -- TRUNCATE: ¿volvieron?

START TRANSACTION;
    DROP TABLE envios_copia;
ROLLBACK;
SELECT COUNT(*) FROM envios_copia;            -- DROP: ERROR 1146 esperado

-- PREGUNTA 7.1: En 7a, ¿en qué instrucción exacta quedó confirmado el
--               UPDATE?
-- PREGUNTA 7.2: Completar la tabla del laboratorio 02 (PASO 9): ¿cuál
--               de las tres instrucciones se puede deshacer con
--               ROLLBACK? ¿Coincidió la predicción?
-- PREGUNTA 7.3: ¿Qué precaución hay que tener al mezclar ALTER TABLE o
--               CREATE TABLE con cambios de datos en un mismo script?


/* ---------------------------------------------------------------------
   PASO 8 · TRABAJAR SIN AUTOCOMMIT
   --------------------------------------------------------------------- */

SET autocommit = 0;               -- desde ahora, todo queda pendiente hasta el COMMIT

UPDATE productos SET stock = stock + 100 WHERE id_producto = 17;
SELECT id_producto, stock FROM productos WHERE id_producto = 17;      -- 220

ROLLBACK;                         -- no hubo START TRANSACTION, pero sí hay qué deshacer
SELECT id_producto, stock FROM productos WHERE id_producto = 17;      -- 120

SET autocommit = 1;               -- se vuelve al modo normal

-- PREGUNTA 8.1: Con autocommit = 0, ¿cuándo empieza una transacción?
-- PREGUNTA 8.2: Si con autocommit = 0 se hace un UPDATE y se cierra el
--               programa sin COMMIT, ¿qué pasa con el cambio? ¿Por qué
--               ese modo es peligroso para quien no lo conoce?


/* ---------------------------------------------------------------------
   PASO 9 · DOS SESIONES AL MISMO TIEMPO
   ---------------------------------------------------------------------
   Antes de seguir: recargar 00_preparacion.

   Se abren DOS conexiones al servidor (el README del caso explica cómo
   en cada cliente). En la primera se abre sesion_A.sql y en la segunda
   sesion_B.sql. Se ejecuta UN paso a la vez, alternando entre las dos
   ventanas en el orden de las etiquetas:

     Parte 1 · aislamiento y bloqueos     A1 → B1 → B2 → A2 → B3
     Parte 2 · la última unidad           A3 → B4 → A4 → B5
     Parte 3 · lectura repetible          B6 → A5 → B7 → B8
     Parte 4 · interbloqueo (deadlock)    A6 → B9 → A7 → B10 → A8

   Las preguntas están dentro de cada archivo.
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   PASO 10 · CIERRE: ACID
   Completar en el cuaderno, citando el paso de esta guía donde se
   observó cada propiedad:

   | Propiedad     | Qué garantiza | Paso donde se vio |
   |---------------|---------------|-------------------|
   | Atomicidad    |               |                   |
   | Consistencia  |               |                   |
   | Aislamiento   |               |                   |
   | Durabilidad   |               |                   |
   --------------------------------------------------------------------- */
