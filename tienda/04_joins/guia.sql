/* =====================================================================
   LABORATORIO 04 · COMBINAR TABLAS
   INNER JOIN · LEFT / RIGHT JOIN · autocombinación · CROSS JOIN · UNION
   ---------------------------------------------------------------------
   Objetivo: reunir en una consulta los datos que la normalización
   repartió en varias tablas, y aprender a elegir el tipo de JOIN según
   la pregunta: "los que tienen" o "todos, tengan o no".

   Requisito: base tienda recién cargada con 00_preparacion.
   Esta guía solo consulta: no modifica ningún dato.

   Antes de empezar: tener a la vista el diagrama de la base (README del
   caso). Cada JOIN recorre una de sus flechas.
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;


/* ---------------------------------------------------------------------
   PASO 1 · EL PROBLEMA: LOS DATOS ESTÁN REPARTIDOS
   --------------------------------------------------------------------- */

-- Un producto solo conoce el NÚMERO de su categoría y de su proveedor
SELECT id_producto, nombre, id_categoria, id_proveedor FROM productos LIMIT 5;

-- 1a. Dos tablas en el FROM, sin condición: producto cartesiano
SELECT p.nombre, c.nombre
FROM productos p, categorias c;

-- 1b. INNER JOIN: cada producto con SU categoría
SELECT p.nombre, c.nombre
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria;

-- PREGUNTA 1.1: ¿Cuántas filas devolvió 1a? ¿De dónde sale ese número?
--               (productos tiene 40 filas y categorias 15.)
-- PREGUNTA 1.2: ¿Cuántas devolvió 1b? ¿Qué hace la condición ON?


/* ---------------------------------------------------------------------
   PASO 2 · INNER JOIN: SINTAXIS Y ALIAS DE TABLA
   --------------------------------------------------------------------- */

-- 2a. Dos tablas tienen una columna "nombre" → ERROR 1052 esperado
SELECT nombre, precio
FROM productos
JOIN categorias ON categorias.id_categoria = productos.id_categoria;

-- 2b. Solución: calificar cada columna con su tabla (o su alias) y
--     darle un alias de columna al resultado
SELECT p.nombre AS producto,
       c.nombre AS categoria,
       p.precio
FROM productos p
JOIN categorias c ON c.id_categoria = p.id_categoria          -- JOIN = INNER JOIN
ORDER BY c.nombre, p.nombre;

-- 2c. USING: forma corta cuando la columna se llama igual en las dos tablas
SELECT p.nombre AS producto, c.nombre AS categoria
FROM productos p
JOIN categorias c USING (id_categoria);

-- 2d. El JOIN se combina con todo lo del laboratorio 03
SELECT p.nombre AS producto, c.nombre AS categoria, p.precio
FROM productos p
JOIN categorias c ON c.id_categoria = p.id_categoria
WHERE c.nombre IN ('Monitores', 'Portátiles') AND p.precio > 1000000
ORDER BY p.precio DESC
LIMIT 5;

-- PREGUNTA 2.1: ¿Qué significa "ambiguous" en el mensaje de 2a?
-- PREGUNTA 2.2: En la condición ON, ¿qué papel cumple cada columna
--               (clave primaria o clave foránea)?


/* ---------------------------------------------------------------------
   PASO 3 · MÁS DE DOS TABLAS
   Cada JOIN agrega una tabla y necesita su propia condición ON.
   --------------------------------------------------------------------- */

-- 3a. Tres tablas: producto, categoría y proveedor
SELECT p.nombre  AS producto,
       c.nombre  AS categoria,
       pr.nombre AS proveedor,
       pr.ciudad AS ciudad_proveedor
FROM productos p
JOIN categorias  c  ON c.id_categoria  = p.id_categoria
JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor;

-- 3b. Cuatro tablas: el encabezado de cada pedido "en palabras"
SELECT pe.id_pedido,
       pe.fecha_pedido,
       c.nombre  AS cliente,
       e.nombre  AS vendedor,
       s.nombre  AS sucursal,
       pe.estado
FROM pedidos pe
JOIN clientes   c ON c.id_cliente  = pe.id_cliente
JOIN empleados  e ON e.id_empleado = pe.id_empleado
JOIN sucursales s ON s.id_sucursal = pe.id_sucursal
ORDER BY pe.fecha_pedido DESC
LIMIT 10;

-- 3c. Cinco tablas: la factura completa del pedido 2
SELECT pe.id_pedido,
       c.nombre                                               AS cliente,
       p.nombre                                               AS producto,
       cat.nombre                                             AS categoria,
       d.cantidad,
       d.precio_unitario,
       d.descuento,
       ROUND(d.cantidad * d.precio_unitario * (1 - d.descuento)) AS subtotal
FROM pedidos pe
JOIN clientes       c   ON c.id_cliente     = pe.id_cliente
JOIN detalle_pedido d   ON d.id_pedido      = pe.id_pedido
JOIN productos      p   ON p.id_producto    = d.id_producto
JOIN categorias     cat ON cat.id_categoria = p.id_categoria
WHERE pe.id_pedido = 2;

-- PREGUNTA 3.1: 3a devuelve 39 filas, pero hay 40 productos. ¿Cuál
--               falta y por qué? (Se resuelve en el PASO 4.)
-- PREGUNTA 3.2: Para unir N tablas, ¿cuántas condiciones ON hacen
--               falta como mínimo?
-- PREGUNTA 3.3: En 3c, ¿qué tabla "hace de puente" entre pedidos y
--               productos? ¿Qué tipo de relación resuelve?


/* ---------------------------------------------------------------------
   PASO 4 · LEFT JOIN: TODOS, TENGAN O NO PAREJA
   INNER JOIN solo devuelve las filas que encuentran pareja. LEFT JOIN
   conserva TODAS las filas de la tabla de la izquierda y rellena con
   NULL cuando no hay pareja a la derecha.
   --------------------------------------------------------------------- */

-- 4a. INNER: solo productos con proveedor (39)
SELECT p.nombre AS producto, pr.nombre AS proveedor
FROM productos p
JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor;

-- 4b. LEFT: todos los productos (40); el que no tiene proveedor muestra NULL
SELECT p.nombre AS producto, pr.nombre AS proveedor
FROM productos p
LEFT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
ORDER BY pr.nombre;

-- 4c. El orden de las tablas importa: ahora "todos" son los proveedores
SELECT pr.nombre AS proveedor, p.nombre AS producto
FROM proveedores pr
LEFT JOIN productos p ON p.id_proveedor = pr.id_proveedor
ORDER BY pr.nombre;

-- 4d. Todos los pedidos con su envío, si lo tienen
SELECT pe.id_pedido, pe.estado, e.transportadora, e.fecha_envio, e.fecha_entrega
FROM pedidos pe
LEFT JOIN envios e ON e.id_pedido = pe.id_pedido
ORDER BY pe.id_pedido DESC
LIMIT 15;

-- PREGUNTA 4.1: ¿Qué producto aparece en 4b y no en 4a?
-- PREGUNTA 4.2: ¿Qué proveedor aparece en 4c con el producto en NULL?
--               ¿Cuántas filas tiene 4c y por qué no son 8?
-- PREGUNTA 4.3: En 4d, un NULL en transportadora y un NULL en
--               fecha_entrega no significan lo mismo. Explicar cada uno.


/* ---------------------------------------------------------------------
   PASO 5 · BUSCAR LO QUE FALTA: LEFT JOIN + IS NULL
   "¿Quiénes NO tienen…?" se responde conservando a todos y quedándose
   con los que salieron sin pareja.
   --------------------------------------------------------------------- */

-- 5a. Clientes que nunca han hecho un pedido
SELECT c.id_cliente, c.nombre, c.fecha_registro
FROM clientes c
LEFT JOIN pedidos pe ON pe.id_cliente = c.id_cliente
WHERE pe.id_pedido IS NULL;

-- 5b. Productos que nunca se han vendido
SELECT p.id_producto, p.nombre, p.stock
FROM productos p
LEFT JOIN detalle_pedido d ON d.id_producto = p.id_producto
WHERE d.id_pedido IS NULL;

-- 5c. Sucursales sin empleados
SELECT s.nombre
FROM sucursales s
LEFT JOIN empleados e ON e.id_sucursal = s.id_sucursal
WHERE e.id_empleado IS NULL;

-- 5d. Pedidos entregados que no pasaron por una transportadora
--     (el cliente los recogió en la sucursal)
SELECT pe.id_pedido, pe.fecha_pedido
FROM pedidos pe
LEFT JOIN envios e ON e.id_pedido = pe.id_pedido
WHERE pe.estado = 'Entregado' AND e.id_envio IS NULL;

-- PREGUNTA 5.1: ¿Cuántas filas devolvió cada consulta?
-- PREGUNTA 5.2: En el IS NULL se usa la clave primaria de la tabla
--               derecha (pe.id_pedido, e.id_empleado…). ¿Por qué es más
--               seguro que usar cualquier otra columna?


/* ---------------------------------------------------------------------
   PASO 6 · LA TRAMPA: FILTRAR LA TABLA DERECHA EN ON O EN WHERE
   Pregunta: "todos los clientes de Aguachica, con sus pedidos
   CANCELADOS si los tienen".
   --------------------------------------------------------------------- */

-- 6a. El filtro en WHERE
SELECT c.nombre, pe.id_pedido, pe.estado
FROM clientes c
LEFT JOIN pedidos pe ON pe.id_cliente = c.id_cliente
WHERE c.ciudad = 'Aguachica' AND pe.estado = 'Cancelado';

-- 6b. El filtro en ON
SELECT c.nombre, pe.id_pedido, pe.estado
FROM clientes c
LEFT JOIN pedidos pe ON pe.id_cliente = c.id_cliente AND pe.estado = 'Cancelado'
WHERE c.ciudad = 'Aguachica';

-- OBSERVAR: Aguachica tiene 9 clientes.
-- PREGUNTA 6.1: ¿Cuántos clientes distintos aparecen en 6a y cuántos en
--               6b? ¿Cuál responde a la pregunta?
-- PREGUNTA 6.2: Explicar por qué una condición sobre la tabla derecha
--               puesta en WHERE convierte el LEFT JOIN en INNER JOIN.
--               (Pista: ¿cuánto vale pe.estado en las filas sin pareja?)


/* ---------------------------------------------------------------------
   PASO 7 · RIGHT JOIN Y "FULL JOIN"
   --------------------------------------------------------------------- */

-- 7a. RIGHT JOIN conserva todas las filas de la tabla DERECHA.
--     Es el LEFT JOIN de 4c con las tablas en otro orden.
SELECT pr.nombre AS proveedor, p.nombre AS producto
FROM productos p
RIGHT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
ORDER BY pr.nombre;

-- 7b. MySQL no tiene FULL OUTER JOIN → ERROR 1064 esperado
SELECT p.nombre AS producto, pr.nombre AS proveedor
FROM productos p
FULL OUTER JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor;

-- 7c. Se construye con UNION: productos sin proveedor Y proveedores
--     sin producto, en un solo resultado
SELECT p.nombre AS producto, pr.nombre AS proveedor
FROM productos p
LEFT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
UNION
SELECT p.nombre, pr.nombre
FROM productos p
RIGHT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor;

-- PREGUNTA 7.1: ¿Cuántas filas tiene 7c? ¿Cuáles tienen NULL a la
--               izquierda y cuáles a la derecha?
-- PREGUNTA 7.2: ¿Por qué casi nadie usa RIGHT JOIN?


/* ---------------------------------------------------------------------
   PASO 8 · AUTOCOMBINACIÓN: UNA TABLA UNIDA CONSIGO MISMA
   La misma tabla aparece dos veces, con dos alias y dos papeles.
   --------------------------------------------------------------------- */

-- 8a. Cada empleado con el nombre de su jefe
SELECT e.nombre AS empleado, e.cargo, j.nombre AS jefe, j.cargo AS cargo_jefe
FROM empleados e
JOIN empleados j ON j.id_empleado = e.id_jefe;

-- 8b. Con LEFT JOIN aparece también quien no tiene jefe
SELECT e.nombre AS empleado, e.cargo, IFNULL(j.nombre, '— sin jefe —') AS jefe
FROM empleados e
LEFT JOIN empleados j ON j.id_empleado = e.id_jefe
ORDER BY j.nombre, e.nombre;

-- 8c. Cada subcategoría con su categoría principal
SELECT hija.nombre AS subcategoria, madre.nombre AS categoria
FROM categorias hija
JOIN categorias madre ON madre.id_categoria = hija.id_categoria_padre
ORDER BY madre.nombre, hija.nombre;

-- 8d. Tres niveles: producto → subcategoría → categoría principal
SELECT p.nombre AS producto, hija.nombre AS subcategoria, madre.nombre AS categoria
FROM productos p
JOIN categorias hija  ON hija.id_categoria  = p.id_categoria
JOIN categorias madre ON madre.id_categoria = hija.id_categoria_padre
ORDER BY madre.nombre, hija.nombre, p.nombre;

-- 8e. Parejas de filas de la misma tabla: clientes de la misma ciudad.
--     La condición "<" evita emparejar a alguien consigo mismo y
--     repetir la pareja al revés.
SELECT a.nombre AS cliente_1, b.nombre AS cliente_2, a.ciudad
FROM clientes a
JOIN clientes b ON b.ciudad = a.ciudad AND a.id_cliente < b.id_cliente
WHERE a.ciudad = 'Gamarra';

-- PREGUNTA 8.1: ¿Cuántas filas devuelve 8a y cuántas 8b? ¿Quién marca
--               la diferencia?
-- PREGUNTA 8.2: En 8e, cambiar "<" por "<>" y luego quitar esa
--               condición. ¿Cuántas filas salen en cada caso y por qué?


/* ---------------------------------------------------------------------
   PASO 9 · JOIN CON CONDICIONES QUE NO SON IGUALDADES, Y CROSS JOIN
   --------------------------------------------------------------------- */

-- 9a. Una tabla de rangos creada solo para esta sesión
CREATE TEMPORARY TABLE gamas (
    gama    VARCHAR(20),
    minimo  DECIMAL(12,2),
    maximo  DECIMAL(12,2)
);
INSERT INTO gamas VALUES
    ('Económico',       0,   499999.99),
    ('Gama media', 500000,  1999999.99),
    ('Gama alta', 2000000, 99999999.99);

-- El ON usa BETWEEN: cada producto cae en el rango que le corresponde
SELECT p.nombre, p.precio, g.gama
FROM productos p
JOIN gamas g ON p.precio BETWEEN g.minimo AND g.maximo
ORDER BY p.precio DESC;

-- 9b. CROSS JOIN: todas las combinaciones, a propósito.
--     Una fila por cada sucursal y cada categoría principal (4 × 5).
SELECT s.nombre AS sucursal, c.nombre AS categoria
FROM sucursales s
CROSS JOIN categorias c
WHERE c.id_categoria_padre IS NULL
ORDER BY s.nombre, c.nombre;

DROP TEMPORARY TABLE gamas;

-- PREGUNTA 9.1: ¿Para qué podría servir en un informe la "plantilla" de
--               combinaciones que produce 9b?


/* ---------------------------------------------------------------------
   PASO 10 · UNION: APILAR RESULTADOS
   JOIN pega tablas "de lado" (más columnas); UNION las apila (más filas).
   --------------------------------------------------------------------- */

-- 10a. Un directorio único de contactos
SELECT 'Cliente'   AS tipo, nombre, ciudad, telefono FROM clientes
UNION ALL
SELECT 'Proveedor',         nombre, ciudad, telefono FROM proveedores
UNION ALL
SELECT 'Sucursal',          nombre, ciudad, NULL     FROM sucursales
ORDER BY ciudad, tipo, nombre;

-- 10b. UNION elimina repetidos; UNION ALL los conserva
SELECT ciudad FROM clientes
UNION
SELECT ciudad FROM proveedores;

SELECT ciudad FROM clientes
UNION ALL
SELECT ciudad FROM proveedores;

-- 10c. Distinto número de columnas → ERROR 1222 esperado
SELECT nombre, ciudad FROM clientes
UNION
SELECT nombre FROM proveedores;

-- PREGUNTA 10.1: ¿Cuántas filas devuelve cada consulta de 10b?
-- PREGUNTA 10.2: ¿Qué dos condiciones deben cumplir las consultas que
--                se unen con UNION?
-- PREGUNTA 10.3: ¿En qué ciudades hay a la vez clientes y proveedores?
--                Escribir la consulta (pista: JOIN o IN).
