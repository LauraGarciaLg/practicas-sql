/* =====================================================================
   LABORATORIO 08 · PRUEBAS CON EL USUARIO tienda_vendedor
   ---------------------------------------------------------------------
   Se ejecuta en una conexión con:
     Usuario: tienda_vendedor      Clave: Vende*2026
   Cada instrucción se ejecuta por separado. Antes de ejecutarla, el
   estudiante predice si funcionará o si será rechazada.
   ===================================================================== */


/* ---------------- PARTE 1 (después del PASO 2 de guia_admin) ---------- */

SELECT CURRENT_USER();
SHOW GRANTS;
SHOW DATABASES;                                -- ¿aparece tienda?

USE tienda;                                    -- ERROR 1044 esperado: sin acceso a la base

-- PREGUNTA P1.1: ¿Qué bases de datos ve esta cuenta?
-- PREGUNTA P1.2: ¿Qué diferencia hay entre "poder conectarse" y "poder
--                usar una base"?


/* ---------------- PARTE 2 (después del PASO 3 de guia_admin) ---------- */

USE tienda;
SHOW TABLES;                                   -- ¿qué objetos ve ahora?

SELECT * FROM v_catalogo LIMIT 5;              -- permitido (vista)
SELECT * FROM productos;                       -- ERROR 1142 esperado: sin acceso a la tabla
SELECT costo FROM v_catalogo;                  -- ERROR 1054 esperado: la vista no tiene esa columna
SELECT * FROM empleados;                       -- ERROR 1142 esperado
SELECT * FROM pagos;                           -- ERROR 1142 esperado

SELECT id_cliente, nombre, telefono FROM clientes WHERE id_cliente = 6;      -- permitido

UPDATE clientes SET telefono = '3155550106' WHERE id_cliente = 6;            -- permitido (columna autorizada)
UPDATE clientes SET nombre = 'Otro nombre'  WHERE id_cliente = 6;            -- ERROR 1143 esperado: columna no autorizada
DELETE FROM clientes WHERE id_cliente = 6;                                   -- ERROR 1142 esperado

INSERT INTO clientes (documento, nombre, ciudad)
VALUES ('1065900301', 'Cliente de mostrador', 'Aguachica');                  -- permitido

INSERT INTO pedidos (id_cliente, id_empleado, id_sucursal) VALUES (1, 5, 1); -- permitido
UPDATE pedidos SET estado = 'Cancelado' WHERE id_pedido = 1;                 -- ERROR 1142 esperado

UPDATE v_catalogo SET precio = 1000 WHERE id_producto = 1;                   -- ERROR 1142 esperado
DROP TABLE pedidos;                                                          -- ERROR 1142 esperado
CREATE TABLE notas (texto VARCHAR(50));                                      -- ERROR 1142 esperado

-- PREGUNTA P2.1: ¿Qué muestra SHOW TABLES? ¿Aparecen productos,
--                empleados y pagos?
-- PREGUNTA P2.2: Completar en el cuaderno: instrucción | ¿pasó? |
--                código de error.
-- PREGUNTA P2.3: ¿Qué diferencia hay entre el error 1142 y el 1143?
-- PREGUNTA P2.4: El vendedor puede insertar pedidos pero no
--                cancelarlos. ¿Es un problema o una decisión de diseño?
--                ¿Quién debería poder cancelar?


/* ---------------- PARTE 3 (después del PASO 5 de guia_admin) ---------- */

INSERT INTO clientes (documento, nombre, ciudad)
VALUES ('1065900302', 'Otro cliente de mostrador', 'Aguachica');             -- ERROR 1142 esperado

SELECT id_cliente, nombre FROM clientes ORDER BY id_cliente DESC LIMIT 3;    -- permitido
UPDATE clientes SET ciudad = 'Gamarra' WHERE documento = '1065900301';       -- permitido

SHOW GRANTS;

-- PREGUNTA P3.1: ¿Qué permiso perdió la cuenta y cuáles conserva sobre
--                clientes?
-- PREGUNTA P3.2: El cliente que el vendedor insertó en la PARTE 2,
--                ¿desapareció al retirarle el permiso?
