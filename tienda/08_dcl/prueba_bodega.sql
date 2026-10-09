/* =====================================================================
   LABORATORIO 08 · PRUEBAS CON EL USUARIO tienda_bodega
   ---------------------------------------------------------------------
   Se ejecuta en una conexión con:
     Usuario: tienda_bodega      Clave: Bodega*2026
   Cada instrucción se ejecuta por separado. Antes de ejecutarla, el
   estudiante predice si funcionará o si será rechazada.
   ===================================================================== */


/* ---------------- PARTE 1 (después de crear el usuario en el PASO 6) -- */

SELECT CURRENT_USER(), CURRENT_ROLE();         -- ¿qué rol está activo?
SHOW GRANTS;

SELECT nombre, stock FROM tienda.productos LIMIT 5;      -- ERROR 1142 esperado: el rol no está activo

-- El rol se puede activar a mano, solo para esta sesión
SET ROLE 'rol_bodega';
SELECT CURRENT_ROLE();
SELECT nombre, stock FROM tienda.productos LIMIT 5;      -- permitido

-- PREGUNTA P1.1: ¿Qué devolvió CURRENT_ROLE() antes y después de SET ROLE?
-- PREGUNTA P1.2: ¿Qué diferencia hay entre tener un rol ASIGNADO y
--                tenerlo ACTIVO?


/* ---------------- PARTE 2 (conexión NUEVA, después del PASO 6a) ------- */

SELECT CURRENT_ROLE();                         -- ahora se activa solo
USE tienda;

SELECT id_producto, nombre, stock, stock_minimo
FROM productos
WHERE stock < stock_minimo;                                              -- permitido

UPDATE productos SET stock = stock + 20 WHERE id_producto = 8;           -- permitido (columna autorizada)
UPDATE productos SET stock_minimo = 5   WHERE id_producto = 8;           -- permitido
UPDATE productos SET precio = 1         WHERE id_producto = 8;           -- ERROR 1143 esperado
UPDATE productos SET stock = -5         WHERE id_producto = 8;           -- ERROR 3819 esperado
DELETE FROM productos WHERE id_producto = 8;                             -- ERROR 1142 esperado
INSERT INTO proveedores (nit, nombre, ciudad) VALUES ('1', 'X', 'Y');    -- ERROR 1142 esperado
SELECT * FROM clientes;                                                  -- ERROR 1142 esperado

-- PREGUNTA P2.1: El penúltimo UPDATE usa una columna autorizada y aun
--                así falla. ¿Lo detuvo el sistema de permisos (DCL) o
--                una restricción (DDL)? ¿Qué enseña eso sobre las capas
--                de protección de una base de datos?
-- PREGUNTA P2.2: ¿Por qué bodega puede cambiar el stock pero no el
--                precio?
