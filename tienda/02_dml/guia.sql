/* =====================================================================
   LABORATORIO 02 · DML — INSERTAR, ACTUALIZAR Y ELIMINAR DATOS
   INSERT · UPDATE · DELETE (y por qué TRUNCATE no es DML)
   ---------------------------------------------------------------------
   Objetivo: modificar los datos de la tienda con todas las variantes
   de INSERT, UPDATE y DELETE, y comprobar cómo las restricciones
   definidas con DDL protegen la base de las operaciones incorrectas.

   Requisito: base tienda recién cargada con 00_preparacion.

   Cómo trabajar: un bloque a la vez. Las instrucciones marcadas
   "ERROR xxxx esperado" deben fallar.

   REGLA DEL LABORATORIO: antes de cada UPDATE o DELETE se ejecuta un
   SELECT con el mismo WHERE, para ver qué filas se van a tocar.
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;
SET SQL_SAFE_UPDATES = 0;     -- el PASO 5 explica qué es y lo vuelve a activar


/* ---------------------------------------------------------------------
   PASO 1 · INSERT: LAS FORMAS BÁSICAS
   --------------------------------------------------------------------- */

-- 1a. Con lista de columnas: las que no se nombran toman su DEFAULT o NULL
INSERT INTO clientes (documento, nombre, ciudad)
VALUES ('1065900201', 'Rosa Elena Vergel', 'Aguachica');

SELECT * FROM clientes WHERE documento = '1065900201';
SELECT LAST_INSERT_ID();          -- el id que generó AUTO_INCREMENT

-- 1b. Sin lista de columnas: hay que dar TODOS los valores, en el orden
--     de la tabla. NULL en la clave primaria pide el siguiente número.
INSERT INTO sucursales
VALUES (NULL, 'Cúcuta Centro', 'Cúcuta', 'Av 5 #11-20', '2026-10-01');

-- 1c. Varias filas en una sola instrucción
INSERT INTO proveedores (nit, nombre, ciudad, telefono, email) VALUES
    ('900123009-9', 'Gamer Zone Mayoristas',  'Medellín', '6045550109', 'ventas@gamerzone.example'),
    ('900123010-0', 'Impresión Total S.A.S.', 'Bogotá',   NULL,         NULL);

-- 1d. DEFAULT escrito de forma explícita
INSERT INTO clientes (documento, nombre, tipo, ciudad, fecha_registro)
VALUES ('900456007-6', 'Panadería La Espiga', 'Empresa', 'Ocaña', DEFAULT);

SELECT * FROM clientes ORDER BY id_cliente DESC LIMIT 2;
SELECT * FROM proveedores ORDER BY id_proveedor DESC LIMIT 2;

-- PREGUNTA 1.1: En 1a, ¿qué valores quedaron en tipo, email, telefono y
--               fecha_registro? ¿Cuáles vienen de un DEFAULT y cuáles
--               son NULL?
-- PREGUNTA 1.2: ¿Qué riesgo tiene la forma 1b si mañana alguien agrega
--               una columna a sucursales con ALTER TABLE?
-- PREGUNTA 1.3: ¿Qué ventaja tiene 1c frente a ejecutar dos INSERT
--               separados?


/* ---------------------------------------------------------------------
   PASO 2 · INSERT QUE LAS RESTRICCIONES RECHAZAN
   Antes de ejecutar cada una, predecir qué regla la detiene.
   --------------------------------------------------------------------- */

-- 2a. → ERROR 1062 esperado
INSERT INTO clientes (documento, nombre, ciudad)
VALUES ('1065900101', 'Otra Andrea', 'Aguachica');

-- 2b. → ERROR 1364 esperado
INSERT INTO clientes (documento, nombre) VALUES ('1065900999', 'Cliente sin ciudad');

-- 2c. → ERROR 1452 esperado
INSERT INTO productos (sku, nombre, id_categoria, costo, precio)
VALUES ('IMP-001', 'Impresora láser', 99, 400000, 590000);

-- 2d. → ERROR 3819 esperado
INSERT INTO productos (sku, nombre, id_categoria, costo, precio)
VALUES ('IMP-001', 'Impresora láser', 14, 400000, 350000);

-- 2e. → ERROR 1265 esperado
INSERT INTO pedidos (id_cliente, id_empleado, id_sucursal, estado)
VALUES (1, 5, 1, 'Devuelto');

-- 2f. → ERROR 1136 esperado
INSERT INTO categorias VALUES ('Tablets');

-- 2g. → ERROR 1062 esperado: clave primaria COMPUESTA repetida
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (1, 20, 1, 89000);

-- 2h. La versión correcta de 2c y 2d
INSERT INTO productos (sku, nombre, id_categoria, id_proveedor, costo, precio, stock, stock_minimo)
VALUES ('IMP-001', 'Impresora láser monocromática', 14, 10, 400000, 590000, 6, 2);

-- PREGUNTA 2.1: Completar en el cuaderno: instrucción | restricción
--               violada | código de error (de 2a a 2g).
-- PREGUNTA 2.2: En 2g, el pedido 1 ya existe y el producto 20 también.
--               ¿Por qué falla entonces?
-- PREGUNTA 2.3: Después de varios INSERT fallidos sobre clientes,
--               insertar un cliente nuevo y mirar su id. ¿Los intentos
--               fallidos "gastaron" números de AUTO_INCREMENT?


/* ---------------------------------------------------------------------
   PASO 3 · INSERT … SELECT: INSERTAR EL RESULTADO DE UNA CONSULTA
   --------------------------------------------------------------------- */

-- Una tabla de trabajo para la campaña de correo de fin de año
CREATE TABLE campana_correo (
    id_cliente  INT           PRIMARY KEY,
    nombre      VARCHAR(100)  NOT NULL,
    email       VARCHAR(100)  NOT NULL,
    ciudad      VARCHAR(40)   NOT NULL
);

-- Las filas no se escriben: salen de una consulta
INSERT INTO campana_correo (id_cliente, nombre, email, ciudad)
SELECT id_cliente, nombre, email, ciudad
FROM clientes
WHERE email IS NOT NULL AND tipo = 'Persona';

SELECT COUNT(*) FROM campana_correo;
SELECT * FROM campana_correo LIMIT 5;

-- OBSERVAR: el mensaje indica cuántas filas se insertaron de una vez.
-- PREGUNTA 3.1: ¿Cuántos clientes entraron a la campaña? ¿Cuántos
--               quedaron por fuera y por qué?
-- PREGUNTA 3.2: Si la consulta incluyera clientes con email en NULL,
--               ¿qué pasaría con el INSERT completo?


/* ---------------------------------------------------------------------
   PASO 4 · CUANDO LA FILA YA EXISTE: IGNORE, ON DUPLICATE KEY, REPLACE
   --------------------------------------------------------------------- */

-- 4a. Volver a cargar la campaña → ERROR 1062 esperado
INSERT INTO campana_correo (id_cliente, nombre, email, ciudad)
SELECT id_cliente, nombre, email, ciudad FROM clientes WHERE email IS NOT NULL;

-- 4b. INSERT IGNORE: salta las filas repetidas e inserta las demás
INSERT IGNORE INTO campana_correo (id_cliente, nombre, email, ciudad)
SELECT id_cliente, nombre, email, ciudad FROM clientes WHERE email IS NOT NULL;

SELECT COUNT(*) FROM campana_correo;

-- 4c. ON DUPLICATE KEY UPDATE: si existe, la actualiza ("upsert")
INSERT INTO campana_correo (id_cliente, nombre, email, ciudad)
VALUES (1, 'Andrea Quintero', 'andrea.nueva@correo.example', 'Aguachica')
ON DUPLICATE KEY UPDATE email = 'andrea.nueva@correo.example';

SELECT * FROM campana_correo WHERE id_cliente = 1;

-- 4d. REPLACE: si existe, BORRA la fila y la inserta de nuevo
REPLACE INTO campana_correo (id_cliente, nombre, email, ciudad)
VALUES (2, 'Luis F. Pérez', 'luisf.perez@correo.example', 'Gamarra');

SELECT * FROM campana_correo WHERE id_cliente = 2;

-- OBSERVAR: 4c informa "2 rows affected" aunque solo cambió una fila;
--           así distingue MySQL una actualización (2) de una inserción (1).
-- PREGUNTA 4.1: ¿Cuántas filas agregó 4b? ¿Qué clientes eran?
-- PREGUNTA 4.2: REPLACE borra y vuelve a insertar. ¿Qué podría pasar si
--               se usa sobre una tabla a la que otras apuntan con claves
--               foráneas?
-- PREGUNTA 4.3: INSERT IGNORE también convierte otros errores en
--               advertencias. ¿Por qué eso puede ser peligroso?


/* ---------------------------------------------------------------------
   PASO 5 · UPDATE: DE UNA FILA A MUCHAS
   --------------------------------------------------------------------- */

-- 5a. Una fila, una columna: siempre con la clave en el WHERE
SELECT id_cliente, nombre, telefono FROM clientes WHERE id_cliente = 6;
UPDATE clientes SET telefono = '3155550106' WHERE id_cliente = 6;

-- 5b. Una fila, varias columnas
UPDATE clientes
SET email = 'carmen.angarita@correo.example', ciudad = 'Aguachica'
WHERE id_cliente = 3;

-- 5c. El valor nuevo se calcula a partir del anterior: subir 8 % los
--     precios de los monitores (categoría 13)
SELECT id_producto, nombre, precio FROM productos WHERE id_categoria = 13;

UPDATE productos SET precio = ROUND(precio * 1.08, -3) WHERE id_categoria = 13;

SELECT id_producto, nombre, precio FROM productos WHERE id_categoria = 13;

-- 5d. El modo seguro. Algunos clientes (Workbench) lo traen activado.
SET SQL_SAFE_UPDATES = 1;

--     → ERROR 1175 esperado: el WHERE no usa una columna clave
UPDATE productos SET stock_minimo = 10 WHERE nombre LIKE 'Mouse%';

--     → ERROR 1175 esperado: no hay WHERE
UPDATE productos SET activo = FALSE;

SET SQL_SAFE_UPDATES = 0;

-- 5e. Una restricción detiene el UPDATE completo → ERROR 3819 esperado
--     (a mitad de precio, un producto quedaría por debajo de su costo)
UPDATE productos SET precio = precio * 0.50 WHERE id_categoria = 9;
SELECT id_producto, nombre, costo, precio FROM productos WHERE id_categoria = 9;

-- 5f. UPDATE sobre una clave foránea → ERROR 1452 esperado
UPDATE productos SET id_proveedor = 77 WHERE id_producto = 30;

-- OBSERVAR: en 5a y 5b el mensaje dice "Rows matched: 1  Changed: 1".
--           Si se repite 5a, dirá "Changed: 0".
-- PREGUNTA 5.1: ¿Qué diferencia hay entre "matched" y "changed"?
-- PREGUNTA 5.2: En 5c, ¿qué hace ROUND(…, -3)? ¿Por qué conviene aquí?
-- PREGUNTA 5.3: En 5e, la categoría 9 tiene seis productos y solo uno
--               violaba el CHECK. ¿Se actualizó alguno de los otros
--               cinco? ¿Qué dice eso sobre cómo ejecuta el SGBD una
--               instrucción?
-- PREGUNTA 5.4: ¿Qué habría pasado en la segunda instrucción de 5d con
--               el modo seguro desactivado?


/* ---------------------------------------------------------------------
   PASO 6 · UPDATE AVANZADO: CASE, JOIN, SUBCONSULTA, ORDER BY y LIMIT
   --------------------------------------------------------------------- */

-- 6a. CASE: un valor distinto según la fila. Aumento de salario por cargo.
SELECT nombre, cargo, salario FROM empleados ORDER BY cargo;

UPDATE empleados
SET salario = CASE cargo
                  WHEN 'Vendedor'  THEN salario * 1.10
                  WHEN 'Bodeguero' THEN salario * 1.08
                  ELSE salario * 1.05
              END;

SELECT nombre, cargo, salario FROM empleados ORDER BY cargo;

-- 6b. UPDATE con JOIN: el filtro está en OTRA tabla.
--     Bajar 5 % el costo de los productos del proveedor de Cali.
SELECT p.id_producto, p.nombre, p.costo, pr.nombre AS proveedor
FROM productos p
JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
WHERE pr.ciudad = 'Cali';

UPDATE productos p
JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
SET p.costo = p.costo * 0.95
WHERE pr.ciudad = 'Cali';

-- 6c. UPDATE con subconsulta: desactivar los productos que nunca se
--     han vendido
SELECT id_producto, nombre, activo
FROM productos
WHERE id_producto NOT IN (SELECT id_producto FROM detalle_pedido);

UPDATE productos
SET activo = FALSE
WHERE id_producto NOT IN (SELECT id_producto FROM detalle_pedido);

-- 6d. ORDER BY y LIMIT: reponer 20 unidades SOLO a los tres productos
--     activos con menos existencias
SELECT id_producto, nombre, stock FROM productos WHERE activo ORDER BY stock LIMIT 3;

UPDATE productos SET stock = stock + 20 WHERE activo ORDER BY stock LIMIT 3;

-- 6e. Una columna tomada de otra tabla: actualizar el precio de las
--     líneas del pedido 160 (aún pendiente) al precio de lista de hoy
UPDATE detalle_pedido d
JOIN productos p ON p.id_producto = d.id_producto
SET d.precio_unitario = p.precio
WHERE d.id_pedido = 160;

SELECT * FROM detalle_pedido WHERE id_pedido = 160;

-- PREGUNTA 6.1: En 6a no hay WHERE. ¿Por qué aquí es correcto?
-- PREGUNTA 6.2: ¿Cuántas filas cambió 6b? ¿Y 6c? Comparar con las que
--               mostró el SELECT previo. En los datos originales solo
--               tres productos no se habían vendido nunca: ¿de dónde
--               salió el cuarto?
-- PREGUNTA 6.3: En 6e, ¿qué línea del pedido cambió de precio y por qué
--               las demás no? (Pista: PASO 5c.)
-- PREGUNTA 6.4: ¿Por qué NO se debe ejecutar 6e sobre los pedidos ya
--               entregados?


/* ---------------------------------------------------------------------
   PASO 7 · DELETE Y LA INTEGRIDAD REFERENCIAL
   --------------------------------------------------------------------- */

-- 7a. Una fila que nadie referencia
SELECT * FROM clientes WHERE documento = '1065900201';
DELETE FROM clientes WHERE documento = '1065900201';

-- 7b. Un cliente con pedidos → ERROR 1451 esperado
DELETE FROM clientes WHERE id_cliente = 7;

-- 7c. Un producto vendido     → ERROR 1451 esperado
DELETE FROM productos WHERE id_producto = 17;

-- 7d. ON DELETE CASCADE: el pedido 151 está pendiente, no tiene pagos
--     ni envío, pero sí una línea en detalle_pedido
SELECT * FROM pedidos        WHERE id_pedido = 151;
SELECT * FROM detalle_pedido WHERE id_pedido = 151;

DELETE FROM pedidos WHERE id_pedido = 151;

SELECT * FROM detalle_pedido WHERE id_pedido = 151;      -- ¿qué pasó con la línea?

-- 7e. El pedido 146 también está pendiente, pero tiene un abono
--     → ERROR 1451 esperado
DELETE FROM pedidos WHERE id_pedido = 146;

--     Orden correcto: primero los hijos sin CASCADE, después el padre
DELETE FROM pagos   WHERE id_pedido = 146;
DELETE FROM pedidos WHERE id_pedido = 146;

-- PREGUNTA 7.1: ¿Por qué 7d funcionó "en cascada" y 7e no? Revisar las
--               claves foráneas en SHOW CREATE TABLE detalle_pedido y
--               SHOW CREATE TABLE pagos.
-- PREGUNTA 7.2: ¿Por qué el diseño usa CASCADE para el detalle pero no
--               para los pagos? ¿Qué podría salir mal con CASCADE en
--               pagos?
-- PREGUNTA 7.3: En un negocio real, ¿se borra el pago de un cliente
--               como se hizo en 7e? ¿Qué debería hacerse en su lugar?


/* ---------------------------------------------------------------------
   PASO 8 · DELETE AVANZADO: JOIN, SUBCONSULTA, ORDER BY y LIMIT
   --------------------------------------------------------------------- */

-- 8a. DELETE con subconsulta: quitar de la campaña a los clientes que
--     nunca han comprado
SELECT * FROM campana_correo
WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);

DELETE FROM campana_correo
WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);

-- 8b. DELETE con JOIN: quitar de la campaña a los clientes que tienen
--     algún pedido cancelado. Tras DELETE se indica de qué tabla se borra.
DELETE cc
FROM campana_correo cc
JOIN pedidos p ON p.id_cliente = cc.id_cliente
WHERE p.estado = 'Cancelado';

SELECT COUNT(*) FROM campana_correo;

-- 8c. ORDER BY y LIMIT: borrar solo las 2 últimas filas de la campaña
DELETE FROM campana_correo ORDER BY id_cliente DESC LIMIT 2;

-- 8d. Borrado lógico: el producto no se elimina, se marca
--     (ya se hizo en 6c con activo = FALSE)
SELECT id_producto, nombre, activo FROM productos WHERE NOT activo;

-- PREGUNTA 8.1: ¿Cuántas filas borró cada DELETE?
-- PREGUNTA 8.2: Un cliente con tres pedidos cancelados aparece tres
--               veces en el JOIN de 8b. ¿Cuántas filas suyas se borran?
-- PREGUNTA 8.3: ¿Por qué la tienda prefiere el borrado lógico (8d) para
--               los productos descontinuados?


/* ---------------------------------------------------------------------
   PASO 9 · DELETE SIN WHERE, TRUNCATE Y DROP
   --------------------------------------------------------------------- */

CREATE TABLE prueba_borrado (
    id     INT PRIMARY KEY AUTO_INCREMENT,
    texto  VARCHAR(20)
);

INSERT INTO prueba_borrado (texto) VALUES ('uno'), ('dos'), ('tres');

-- 9a. DELETE sin WHERE: borra todas las filas, una por una
DELETE FROM prueba_borrado;
INSERT INTO prueba_borrado (texto) VALUES ('cuatro');
SELECT * FROM prueba_borrado;             -- ¿qué id recibió 'cuatro'?

-- 9b. TRUNCATE: elimina y vuelve a crear la tabla vacía
TRUNCATE TABLE prueba_borrado;
INSERT INTO prueba_borrado (texto) VALUES ('cinco');
SELECT * FROM prueba_borrado;             -- ¿y 'cinco'?

-- 9c. TRUNCATE no acepta condiciones → ERROR 1064 esperado
TRUNCATE TABLE prueba_borrado WHERE id = 1;

-- 9d. TRUNCATE sobre una tabla referenciada → ERROR 1701 esperado
TRUNCATE TABLE clientes;

-- 9e. DROP: desaparecen las filas Y la tabla
DROP TABLE prueba_borrado;
DROP TABLE campana_correo;

SELECT * FROM prueba_borrado;             -- ERROR 1146 esperado

-- PREGUNTA 9.1: ¿Qué id recibió la fila insertada después del DELETE y
--               cuál la insertada después del TRUNCATE? ¿Por qué?
-- PREGUNTA 9.2: Completar en el cuaderno:
--               |                          | DELETE | TRUNCATE | DROP |
--               | Sublenguaje (DML o DDL)  |        |          |      |
--               | ¿Admite WHERE?           |        |          |      |
--               | ¿Reinicia AUTO_INCREMENT?|        |          |      |
--               | ¿Conserva la estructura? |        |          |      |
-- PREGUNTA 9.3: ¿Cuál de las tres se puede deshacer con ROLLBACK?
--               Anotar la predicción; se comprobará en el laboratorio 07.


/* ---------------------------------------------------------------------
   CIERRE
   La base quedó modificada. Antes de los ejercicios (y de cualquier
   otro laboratorio) se vuelve a ejecutar 00_preparacion.
   --------------------------------------------------------------------- */
