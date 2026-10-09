/* =====================================================================
   LABORATORIO 07 · DOS SESIONES — SESIÓN A (vendedora de Aguachica)
   ---------------------------------------------------------------------
   Preparación:
     1. Recargar la base con 00_preparacion (datos originales).
     2. Abrir DOS conexiones al servidor. En la primera se abre este
        archivo y en la segunda, sesion_B.sql.
     3. Ejecutar UN paso a la vez, siguiendo el orden de las etiquetas:
          Parte 1:  A1 → B1 → B2 → A2 → B3
          Parte 2:  A3 → B4 → A4 → B5
          Parte 3:  B6 → A5 → B7 → B8
          Parte 4:  A6 → B9 → A7 → B10 → A8
   ===================================================================== */

USE tienda;


/* ================= PARTE 1 · AISLAMIENTO Y BLOQUEOS ================= */

-- [A1] Iniciar una transacción y vender 2 unidades del producto 1
START TRANSACTION;
UPDATE productos SET stock = stock - 2 WHERE id_producto = 1;
SELECT id_producto, nombre, stock FROM productos WHERE id_producto = 1;
-- Anotar el stock que ve la sesión A.   → Ir a [B1]


-- [A2] Confirmar
COMMIT;
-- Mirar de inmediato la ventana de la sesión B.   → Ir a [B3]


/* ================= PARTE 2 · LA ÚLTIMA UNIDAD ======================= */
-- El producto 9 (Torre gamer) tiene UNA unidad. Dos clientes la quieren
-- al mismo tiempo, cada uno en una sucursal.

-- [A3] Leer el stock BLOQUEANDO la fila: "voy a decidir con este dato"
START TRANSACTION;
SELECT id_producto, nombre, stock FROM productos WHERE id_producto = 9 FOR UPDATE;
-- Hay 1 unidad: la sesión A decide vender.   → Ir a [B4]


-- [A4] Vender y confirmar
UPDATE productos SET stock = stock - 1 WHERE id_producto = 9;
COMMIT;
-- → Ir a [B5]


/* ================= PARTE 3 · LECTURA REPETIBLE ====================== */
-- Empieza la sesión B: ir a [B6] y volver.

-- [A5] Cambiar un precio y confirmarlo (autocommit: queda confirmado ya)
UPDATE productos SET precio = 99000 WHERE id_producto = 33;
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 33;
-- → Ir a [B7]


/* ================= PARTE 4 · INTERBLOQUEO (DEADLOCK) ================ */

-- [A6] La sesión A bloquea el producto 1
START TRANSACTION;
UPDATE productos SET stock = stock + 1 WHERE id_producto = 1;
-- → Ir a [B9]


-- [A7] La sesión A necesita ahora el producto 2 (que tiene B)
UPDATE productos SET stock = stock + 1 WHERE id_producto = 2;
-- Se queda esperando.   → Ir a [B10] sin esperar a que termine


-- [A8] Cerrar la transacción de A
COMMIT;
SELECT id_producto, stock FROM productos WHERE id_producto IN (1, 2);

-- PREGUNTA A.1: Después de [B10], ¿cuál de las dos sesiones recibió el
--               error 1213 y cuál pudo continuar?
-- PREGUNTA A.2: ¿Qué cambios de stock quedaron al final? ¿Qué pasó con
--               los de la sesión que recibió el error?
-- PREGUNTA A.3: Si las dos sesiones hubieran actualizado los productos
--               en el MISMO orden (primero el 1 y después el 2), ¿habría
--               ocurrido el interbloqueo? ¿Qué regla de programación
--               sale de ahí?
