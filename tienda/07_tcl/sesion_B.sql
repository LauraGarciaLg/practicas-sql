/* =====================================================================
   LABORATORIO 07 · DOS SESIONES — SESIÓN B (vendedor de Ocaña)
   ---------------------------------------------------------------------
   Se abre en la SEGUNDA conexión. Las instrucciones de preparación y
   el orden completo de los pasos están en sesion_A.sql.
   ===================================================================== */

USE tienda;


/* ================= PARTE 1 · AISLAMIENTO Y BLOQUEOS ================= */

-- [B1] Mientras A tiene su transacción abierta, B consulta el mismo producto
SELECT id_producto, nombre, stock FROM productos WHERE id_producto = 1;
-- PREGUNTA B.1: ¿Qué stock ve B? ¿Coincide con el que ve A? ¿Por qué?
-- → Seguir con [B2]


-- [B2] B intenta vender 1 unidad del mismo producto
UPDATE productos SET stock = stock - 1 WHERE id_producto = 1;
-- La instrucción se queda "ejecutando": espera a que A libere la fila.
-- Sin cancelarla, → ir a [A2]
-- (Si pasan 50 segundos sin que A confirme: ERROR 1205, Lock wait timeout.)


-- [B3] Cuando A confirmó, el UPDATE de B terminó solo
SELECT id_producto, nombre, stock FROM productos WHERE id_producto = 1;
-- PREGUNTA B.2: El stock inicial era 12. ¿Cuánto quedó? ¿Se perdió
--               alguna de las dos ventas?
-- PREGUNTA B.3: ¿Las lecturas (SELECT) de B tuvieron que esperar? ¿Y las
--               escrituras (UPDATE)?
-- → Ir a [A3]


/* ================= PARTE 2 · LA ÚLTIMA UNIDAD ======================= */

-- [B4] B también quiere leer el stock para decidir
START TRANSACTION;
SELECT id_producto, nombre, stock FROM productos WHERE id_producto = 9 FOR UPDATE;
-- Se queda esperando: A bloqueó la fila con su FOR UPDATE.   → Ir a [A4]


-- [B5] Cuando A confirmó, B recibe por fin la respuesta
-- (el resultado del SELECT de [B4] ya está en pantalla)
-- Stock 0: no hay nada que vender. B cancela su intento.
ROLLBACK;
-- PREGUNTA B.4: ¿Qué stock recibió B en su SELECT … FOR UPDATE?
-- PREGUNTA B.5: Si A y B hubieran usado un SELECT normal (sin FOR
--               UPDATE), ¿qué stock habría leído cada una? ¿Qué habría
--               pasado después con los dos UPDATE? (Pista: el CHECK
--               detendría al segundo, pero ese cliente ya habría pagado.)
-- → Seguir con [B6]


/* ================= PARTE 3 · LECTURA REPETIBLE ====================== */

-- [B6] B abre una transacción y consulta un precio
START TRANSACTION;
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 33;
-- Anotar el precio.   → Ir a [A5]


-- [B7] A ya cambió y CONFIRMÓ el precio. B repite la misma consulta
--      dentro de su transacción:
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 33;
-- PREGUNTA B.6: ¿B ve el precio nuevo o el viejo?
-- → Seguir con [B8]


-- [B8] B cierra su transacción y consulta otra vez
COMMIT;
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 33;
SELECT @@transaction_isolation;
-- PREGUNTA B.7: ¿Y ahora? El nivel de aislamiento por defecto de MySQL
--               es REPEATABLE READ: explicar con este experimento qué
--               significa "lectura repetible".
-- PREGUNTA B.8: ¿Para qué tipo de tarea es útil que todas las consultas
--               de una transacción vean los datos "congelados"?
-- → Ir a [A6]


/* ================= PARTE 4 · INTERBLOQUEO (DEADLOCK) ================ */

-- [B9] La sesión B bloquea el producto 2
START TRANSACTION;
UPDATE productos SET stock = stock + 1 WHERE id_producto = 2;
-- → Ir a [A7]


-- [B10] La sesión B necesita ahora el producto 1 (que tiene A)
UPDATE productos SET stock = stock + 1 WHERE id_producto = 1;
-- A espera a B y B espera a A: ninguna puede avanzar. MySQL lo detecta
-- y sacrifica una de las dos transacciones con
-- ERROR 1213: Deadlock found when trying to get lock.
-- Mirar las dos ventanas.   → Ir a [A8]

-- Si esta sesión NO recibió el error, cerrar su transacción:
COMMIT;
