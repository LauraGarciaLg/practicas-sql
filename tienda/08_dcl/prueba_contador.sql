/* =====================================================================
   LABORATORIO 08 · PRUEBAS CON EL USUARIO tienda_contador
   ---------------------------------------------------------------------
   Se ejecuta en una conexión con:
     Usuario: tienda_contador      Clave: Conta*2026
   Cada instrucción se ejecuta por separado. Antes de ejecutarla, el
   estudiante predice si funcionará o si será rechazada.
   ===================================================================== */

USE tienda;


/* ---------------- PARTE 1 (después del PASO 4 de guia_admin) ---------- */

SHOW GRANTS;
SHOW TABLES;                                   -- ¿cuántos objetos ve?

SELECT nombre, costo, precio FROM productos LIMIT 5;          -- permitido
SELECT nombre, cargo, salario FROM empleados;                 -- permitido

-- Un informe: recaudo por método de pago
SELECT metodo, COUNT(*) AS pagos, SUM(valor) AS total
FROM pagos
GROUP BY metodo;                                              -- permitido

INSERT INTO pagos (id_pedido, valor, metodo)
VALUES (159, 1701000, 'Transferencia');                       -- permitido

UPDATE pagos SET metodo = 'Tarjeta'
WHERE id_pedido = 159;                                        -- permitido

DELETE FROM pagos WHERE id_pedido = 159;                      -- ERROR 1142 esperado
UPDATE pedidos SET estado = 'Pagado' WHERE id_pedido = 159;   -- ERROR 1142 esperado
UPDATE empleados SET salario = salario * 2
WHERE id_empleado = 12;                                       -- ERROR 1142 esperado
CREATE TABLE informes (texto VARCHAR(50));                    -- ERROR 1142 esperado
CREATE USER 'amigo'@'localhost' IDENTIFIED BY 'x';            -- ERROR 1227 esperado

-- PREGUNTA P1.1: ¿Qué diferencia hay entre lo que ve la contadora y lo
--                que ve el vendedor con SHOW TABLES?
-- PREGUNTA P1.2: La contadora registró el pago del pedido 159, pero no
--                pudo cambiar su estado a 'Pagado'. ¿Qué opciones tiene
--                el administrador para resolverlo sin darle permiso de
--                UPDATE sobre toda la tabla pedidos? (Pista: PASO 3b.)
-- PREGUNTA P1.3: ¿Por qué es importante que quien registra los pagos no
--                pueda borrarlos?


/* ---------------- PARTE 2 (después del PASO 7 de guia_admin) ---------- */

-- La contadora comparte su permiso sobre envios con el vendedor
GRANT SELECT ON tienda.envios TO 'tienda_vendedor'@'localhost';              -- permitido

-- Pero no puede compartir lo que recibió SIN "WITH GRANT OPTION"
GRANT SELECT ON tienda.pagos TO 'tienda_vendedor'@'localhost';               -- ERROR 1142 esperado

-- Ni otorgar más de lo que tiene
GRANT DELETE ON tienda.envios TO 'tienda_vendedor'@'localhost';              -- ERROR 1142 esperado

-- PREGUNTA P2.1: ¿Qué permisos puede repartir la contadora y cuáles no?
