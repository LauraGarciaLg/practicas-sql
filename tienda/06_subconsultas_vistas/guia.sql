/* =====================================================================
   LABORATORIO 06 · CONSULTAS DENTRO DE CONSULTAS
   Subconsultas · EXISTS · tablas derivadas · CTE · funciones de
   ventana · vistas
   ---------------------------------------------------------------------
   Objetivo: resolver preguntas que necesitan más de un paso ("los que
   están por encima del promedio", "el mejor de cada grupo", "los que
   nunca…") y guardar las consultas útiles como vistas.

   Requisito: base tienda recién cargada con 00_preparacion.
   Solo el PASO 10 crea objetos (vistas), y los elimina al final.
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;


/* ---------------------------------------------------------------------
   PASO 1 · SUBCONSULTA ESCALAR: DEVUELVE UN SOLO VALOR
   --------------------------------------------------------------------- */

-- La pregunta en dos pasos: ¿qué productos cuestan más que el promedio?
SELECT AVG(precio) FROM productos;                         -- paso 1: el promedio

-- 1a. Los dos pasos en una sola consulta
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos)
ORDER BY precio;

-- 1b. El producto más caro (sin ORDER BY … LIMIT)
SELECT nombre, precio
FROM productos
WHERE precio = (SELECT MAX(precio) FROM productos);

-- 1c. En el SELECT: comparar cada fila contra un valor global
SELECT nombre,
       salario,
       (SELECT ROUND(AVG(salario)) FROM empleados)             AS promedio_general,
       salario - (SELECT ROUND(AVG(salario)) FROM empleados)   AS diferencia
FROM empleados
ORDER BY diferencia DESC;

-- 1d. Una subconsulta "escalar" que devuelve varias filas
--     → ERROR 1242 esperado
SELECT nombre, precio
FROM productos
WHERE precio = (SELECT precio FROM productos WHERE id_categoria = 6);

-- PREGUNTA 1.1: ¿Por qué no se puede escribir
--               WHERE precio > AVG(precio) directamente?
-- PREGUNTA 1.2: ¿Cuántos productos están por encima del precio
--               promedio? ¿Por qué son menos de la mitad?
-- PREGUNTA 1.3: ¿Qué operador habría que usar en 1d en lugar de "="?


/* ---------------------------------------------------------------------
   PASO 2 · SUBCONSULTAS QUE DEVUELVEN UNA LISTA: IN, ANY, ALL
   --------------------------------------------------------------------- */

-- 2a. Clientes que tienen algún pedido cancelado
SELECT nombre, ciudad
FROM clientes
WHERE id_cliente IN (SELECT id_cliente FROM pedidos WHERE estado = 'Cancelado');

-- 2b. Productos de los proveedores de Bogotá
SELECT nombre, precio
FROM productos
WHERE id_proveedor IN (SELECT id_proveedor FROM proveedores WHERE ciudad = 'Bogotá');

-- 2c. Subconsultas encadenadas: clientes que han comprado algún portátil
SELECT nombre
FROM clientes
WHERE id_cliente IN (
    SELECT id_cliente
    FROM pedidos
    WHERE id_pedido IN (
        SELECT id_pedido
        FROM detalle_pedido
        WHERE id_producto IN (SELECT id_producto FROM productos WHERE id_categoria = 6)
    )
);

-- 2d. ALL: productos más caros que TODOS los smartphones (categoría 8)
SELECT nombre, precio
FROM productos
WHERE precio > ALL (SELECT precio FROM productos WHERE id_categoria = 8);

-- 2e. ANY: empleados que ganan más que ALGÚN administrador
SELECT nombre, cargo, salario
FROM empleados
WHERE salario > ANY (SELECT salario FROM empleados WHERE cargo = 'Administrador')
  AND cargo <> 'Administrador';

-- PREGUNTA 2.1: Reescribir 2a con JOIN. ¿Qué hay que agregar para que
--               un cliente con tres cancelaciones no salga tres veces?
-- PREGUNTA 2.2: "> ALL (lista)" equivale a "mayor que el ___ de la
--               lista"; "> ANY (lista)" equivale a "mayor que el ___".
--               Completar con máximo o mínimo.


/* ---------------------------------------------------------------------
   PASO 3 · NOT IN Y LA TRAMPA DEL NULL
   --------------------------------------------------------------------- */

-- 3a. Clientes sin pedidos (el LEFT JOIN … IS NULL del laboratorio 04)
SELECT nombre
FROM clientes
WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);

-- 3b. Proveedores que no surten ningún producto… ¿ninguno?
SELECT nombre
FROM proveedores
WHERE id_proveedor NOT IN (SELECT id_proveedor FROM productos);

-- 3c. La causa: la lista contiene un NULL (el producto sin proveedor)
SELECT DISTINCT id_proveedor FROM productos ORDER BY id_proveedor;

-- 3d. Solución 1: quitar los NULL de la lista
SELECT nombre
FROM proveedores
WHERE id_proveedor NOT IN (SELECT id_proveedor FROM productos WHERE id_proveedor IS NOT NULL);

-- PREGUNTA 3.1: 3b debería devolver un proveedor y no devuelve ninguno.
--               Explicarlo recordando el PASO 4c del laboratorio 03.
-- PREGUNTA 3.2: ¿Por qué 3a sí funciona? (Revisar la definición de
--               pedidos.id_cliente.)


/* ---------------------------------------------------------------------
   PASO 4 · SUBCONSULTAS CORRELACIONADAS Y EXISTS
   Una subconsulta correlacionada usa un valor de la fila de AFUERA: se
   evalúa una vez por cada fila de la consulta principal.
   --------------------------------------------------------------------- */

-- 4a. Solución 2 al PASO 3: NOT EXISTS no se confunde con los NULL
SELECT pr.nombre
FROM proveedores pr
WHERE NOT EXISTS (SELECT 1 FROM productos p WHERE p.id_proveedor = pr.id_proveedor);

-- 4b. EXISTS: sucursales que tienen al menos un pedido
SELECT s.nombre
FROM sucursales s
WHERE EXISTS (SELECT 1 FROM pedidos pe WHERE pe.id_sucursal = s.id_sucursal);

-- 4c. Correlacionada en el SELECT: un conteo por cada fila
SELECT c.nombre,
       (SELECT COUNT(*)            FROM pedidos pe WHERE pe.id_cliente = c.id_cliente) AS pedidos,
       (SELECT MAX(pe.fecha_pedido) FROM pedidos pe WHERE pe.id_cliente = c.id_cliente) AS ultima_compra
FROM clientes c
ORDER BY pedidos DESC;

-- 4d. Correlacionada en el WHERE: productos más caros que el promedio
--     DE SU PROPIA categoría
SELECT p.nombre, p.id_categoria, p.precio
FROM productos p
WHERE p.precio > (SELECT AVG(p2.precio)
                  FROM productos p2
                  WHERE p2.id_categoria = p.id_categoria)
ORDER BY p.id_categoria, p.precio DESC;

-- 4e. Empleados que ganan más que su jefe… ¿existen?
SELECT e.nombre, e.salario
FROM empleados e
WHERE e.salario > (SELECT j.salario FROM empleados j WHERE j.id_empleado = e.id_jefe);

-- 4f. Clientes que compraron en 2025 pero NO han vuelto en 2026
SELECT c.nombre
FROM clientes c
WHERE EXISTS     (SELECT 1 FROM pedidos pe WHERE pe.id_cliente = c.id_cliente AND YEAR(pe.fecha_pedido) = 2025)
  AND NOT EXISTS (SELECT 1 FROM pedidos pe WHERE pe.id_cliente = c.id_cliente AND YEAR(pe.fecha_pedido) = 2026);

-- PREGUNTA 4.1: En 4c aparecen los 30 clientes, incluso los que no
--               tienen pedidos, y sin usar LEFT JOIN. ¿Por qué?
-- PREGUNTA 4.2: En 4a, ¿qué importancia tiene el "1" de SELECT 1?
--               Cambiarlo por * o por 'hola' y comparar.
-- PREGUNTA 4.3: ¿Qué diferencia hay entre 1a (promedio general) y 4d
--               (promedio de su categoría)? ¿Cuántas veces se calcula
--               el promedio en cada una?


/* ---------------------------------------------------------------------
   PASO 5 · TABLAS DERIVADAS: SUBCONSULTAS EN EL FROM
   El resultado de una consulta se usa como si fuera una tabla. Permite
   "agregar sobre un agregado".
   --------------------------------------------------------------------- */

-- 5a. El total de cada pedido es un GROUP BY; el promedio de esos
--     totales es un agregado sobre el resultado
SELECT COUNT(*)            AS pedidos,
       ROUND(AVG(total))   AS pedido_promedio,
       MAX(total)          AS pedido_mayor
FROM (SELECT id_pedido,
             ROUND(SUM(cantidad * precio_unitario * (1 - descuento))) AS total
      FROM detalle_pedido
      GROUP BY id_pedido) AS totales;

-- 5b. Una tabla derivada sin alias → ERROR 1248 esperado
SELECT AVG(total)
FROM (SELECT id_pedido, SUM(cantidad * precio_unitario) AS total
      FROM detalle_pedido
      GROUP BY id_pedido);

-- 5c. Unir una tabla real con una derivada: cada cliente con lo que ha comprado
SELECT c.nombre, c.tipo, v.pedidos, v.total_comprado
FROM clientes c
JOIN (SELECT pe.id_cliente,
             COUNT(DISTINCT pe.id_pedido)                                    AS pedidos,
             ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS total_comprado
      FROM pedidos pe
      JOIN detalle_pedido d ON d.id_pedido = pe.id_pedido
      WHERE pe.estado <> 'Cancelado'
      GROUP BY pe.id_cliente) AS v ON v.id_cliente = c.id_cliente
ORDER BY v.total_comprado DESC
LIMIT 10;

-- PREGUNTA 5.1: ¿Por qué no se puede escribir AVG(SUM(…)) directamente?
-- PREGUNTA 5.2: 5c usa JOIN. ¿Qué clientes quedan por fuera? ¿Qué habría
--               que cambiar para que aparecieran con total 0?


/* ---------------------------------------------------------------------
   PASO 6 · CTE (WITH): PONERLE NOMBRE A CADA PASO
   Una expresión de tabla común es una tabla derivada que se define
   ANTES de la consulta y se puede usar varias veces.
   --------------------------------------------------------------------- */

-- 6a. La consulta 5a reescrita
WITH totales AS (
    SELECT id_pedido,
           ROUND(SUM(cantidad * precio_unitario * (1 - descuento))) AS total
    FROM detalle_pedido
    GROUP BY id_pedido
)
SELECT COUNT(*) AS pedidos, ROUND(AVG(total)) AS pedido_promedio, MAX(total) AS pedido_mayor
FROM totales;

-- 6b. La misma CTE usada dos veces: pedidos por encima del promedio
WITH totales AS (
    SELECT id_pedido,
           ROUND(SUM(cantidad * precio_unitario * (1 - descuento))) AS total
    FROM detalle_pedido
    GROUP BY id_pedido
)
SELECT id_pedido, total
FROM totales
WHERE total > (SELECT AVG(total) FROM totales)
ORDER BY total DESC;

-- 6c. Varias CTE encadenadas: saldo pendiente de cada pedido abierto
WITH totales AS (
    SELECT id_pedido,
           ROUND(SUM(cantidad * precio_unitario * (1 - descuento))) AS total
    FROM detalle_pedido
    GROUP BY id_pedido
),
abonos AS (
    SELECT id_pedido, SUM(valor) AS pagado
    FROM pagos
    GROUP BY id_pedido
)
SELECT pe.id_pedido, c.nombre AS cliente, pe.estado,
       t.total, COALESCE(a.pagado, 0) AS pagado,
       t.total - COALESCE(a.pagado, 0) AS saldo
FROM pedidos pe
JOIN clientes c    ON c.id_cliente = pe.id_cliente
JOIN totales t     ON t.id_pedido  = pe.id_pedido
LEFT JOIN abonos a ON a.id_pedido  = pe.id_pedido
WHERE pe.estado = 'Pendiente'
ORDER BY saldo DESC;

-- PREGUNTA 6.1: Comparar 5a y 6a. ¿Cuál se lee mejor? ¿En qué orden se
--               lee cada una?
-- PREGUNTA 6.2: ¿Qué ventaja muestra 6b frente a una tabla derivada?


/* ---------------------------------------------------------------------
   PASO 7 · CTE RECURSIVA: RECORRER UNA JERARQUÍA
   --------------------------------------------------------------------- */

-- 7a. El organigrama completo, con el nivel de cada empleado
WITH RECURSIVE organigrama AS (
    -- punto de partida: quien no tiene jefe
    SELECT id_empleado, nombre, cargo, id_jefe, 1 AS nivel,
           CAST(nombre AS CHAR(300)) AS ruta
    FROM empleados
    WHERE id_jefe IS NULL

    UNION ALL

    -- paso recursivo: los subordinados de quienes ya están en la lista
    SELECT e.id_empleado, e.nombre, e.cargo, e.id_jefe, o.nivel + 1,
           CONCAT(o.ruta, ' > ', e.nombre)
    FROM empleados e
    JOIN organigrama o ON o.id_empleado = e.id_jefe
)
SELECT nivel, CONCAT(REPEAT('    ', nivel - 1), nombre) AS empleado, cargo, ruta
FROM organigrama
ORDER BY ruta;

-- 7b. Generar una serie: los 12 meses de 2026, tengan o no ventas
WITH RECURSIVE meses AS (
    SELECT 1 AS mes
    UNION ALL
    SELECT mes + 1 FROM meses WHERE mes < 12
)
SELECT m.mes, COUNT(pe.id_pedido) AS pedidos
FROM meses m
LEFT JOIN pedidos pe ON MONTH(pe.fecha_pedido) = m.mes AND YEAR(pe.fecha_pedido) = 2026
GROUP BY m.mes
ORDER BY m.mes;

-- PREGUNTA 7.1: En 7a, ¿cuántos niveles tiene el organigrama? ¿Qué
--               pasaría si se contratara un auxiliar a cargo de un
--               vendedor: habría que cambiar la consulta?
-- PREGUNTA 7.2: ¿Por qué en 7b aparecen los meses 10, 11 y 12 con cero
--               pedidos, cosa que un GROUP BY sobre pedidos no mostraría?


/* ---------------------------------------------------------------------
   PASO 8 · FUNCIONES DE VENTANA: CALCULAR SIN AGRUPAR
   GROUP BY reduce cada grupo a UNA fila. Una función de ventana (OVER)
   calcula sobre el grupo pero conserva TODAS las filas.
   --------------------------------------------------------------------- */

-- 8a. Cada empleado junto al promedio de su cargo
SELECT nombre, cargo, salario,
       ROUND(AVG(salario) OVER (PARTITION BY cargo))  AS promedio_del_cargo,
       ROUND(AVG(salario) OVER ())                    AS promedio_general
FROM empleados
ORDER BY cargo, salario DESC;

-- 8b. Numerar y clasificar: tres formas de hacer un ranking
SELECT nombre, precio,
       ROW_NUMBER() OVER (ORDER BY precio DESC) AS fila,
       RANK()       OVER (ORDER BY precio DESC) AS puesto,
       DENSE_RANK() OVER (ORDER BY precio DESC) AS puesto_denso
FROM productos
WHERE id_categoria IN (9, 12)
ORDER BY precio DESC;

-- 8c. Ranking dentro de cada grupo: posición de cada producto en su categoría
SELECT c.nombre AS categoria, p.nombre AS producto, p.precio,
       RANK() OVER (PARTITION BY p.id_categoria ORDER BY p.precio DESC) AS puesto
FROM productos p
JOIN categorias c ON c.id_categoria = p.id_categoria
ORDER BY c.nombre, puesto;

-- 8d. "El mejor de cada grupo": el producto más caro de cada categoría.
--     La función de ventana no se puede usar en WHERE: se calcula en
--     una CTE y se filtra afuera.
WITH ranking AS (
    SELECT c.nombre AS categoria, p.nombre AS producto, p.precio,
           ROW_NUMBER() OVER (PARTITION BY p.id_categoria ORDER BY p.precio DESC) AS fila
    FROM productos p
    JOIN categorias c ON c.id_categoria = p.id_categoria
)
SELECT categoria, producto, precio
FROM ranking
WHERE fila = 1;

-- 8e. Acumulados y comparación con la fila anterior: ventas mensuales
WITH ventas_mes AS (
    SELECT DATE_FORMAT(pe.fecha_pedido, '%Y-%m')                           AS periodo,
           ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS ventas
    FROM pedidos pe
    JOIN detalle_pedido d ON d.id_pedido = pe.id_pedido
    WHERE pe.estado <> 'Cancelado'
    GROUP BY periodo
)
SELECT periodo,
       ventas,
       SUM(ventas) OVER (ORDER BY periodo)                              AS acumulado,
       LAG(ventas) OVER (ORDER BY periodo)                              AS mes_anterior,
       ventas - LAG(ventas) OVER (ORDER BY periodo)                     AS variacion,
       ROUND(ventas / SUM(ventas) OVER () * 100, 1)                     AS pct_del_total
FROM ventas_mes
ORDER BY periodo;

-- PREGUNTA 8.1: En 8a, ¿cuántas filas hay en el resultado? ¿Cuántas
--               habría con GROUP BY cargo?
-- PREGUNTA 8.2: En 8b hay productos con el mismo precio. ¿Qué número
--               reciben con ROW_NUMBER, con RANK y con DENSE_RANK?
-- PREGUNTA 8.3: En 8e, ¿qué valor tiene mes_anterior en la primera
--               fila y por qué?
-- PREGUNTA 8.4: Resolver 8d sin funciones de ventana, con una
--               subconsulta correlacionada (como 4d). ¿Cuál se entiende
--               mejor?


/* ---------------------------------------------------------------------
   PASO 9 · TRES FORMAS DE RESPONDER LO MISMO
   Pregunta: ¿qué productos nunca se han vendido?
   --------------------------------------------------------------------- */

-- 9a. LEFT JOIN … IS NULL
SELECT p.nombre
FROM productos p
LEFT JOIN detalle_pedido d ON d.id_producto = p.id_producto
WHERE d.id_producto IS NULL;

-- 9b. NOT IN
SELECT nombre
FROM productos
WHERE id_producto NOT IN (SELECT id_producto FROM detalle_pedido);

-- 9c. NOT EXISTS
SELECT p.nombre
FROM productos p
WHERE NOT EXISTS (SELECT 1 FROM detalle_pedido d WHERE d.id_producto = p.id_producto);

-- El plan de ejecución de cada una
EXPLAIN SELECT p.nombre FROM productos p
LEFT JOIN detalle_pedido d ON d.id_producto = p.id_producto WHERE d.id_producto IS NULL;

EXPLAIN SELECT p.nombre FROM productos p
WHERE NOT EXISTS (SELECT 1 FROM detalle_pedido d WHERE d.id_producto = p.id_producto);

-- PREGUNTA 9.1: ¿Las tres devuelven lo mismo? ¿Cuál de las tres dejaría
--               de funcionar si la columna comparada admitiera NULL?
-- PREGUNTA 9.2: ¿Los dos EXPLAIN muestran planes muy distintos? ¿Qué
--               dice eso sobre "la forma más rápida" de escribirla?


/* ---------------------------------------------------------------------
   PASO 10 · VISTAS: GUARDAR UNA CONSULTA CON NOMBRE
   Una vista no guarda datos: guarda la consulta. Cada vez que se
   consulta la vista, el SGBD la vuelve a ejecutar.
   --------------------------------------------------------------------- */

-- 10a. El total de cada pedido, que ya se escribió demasiadas veces
CREATE OR REPLACE VIEW v_pedidos_totales AS
SELECT pe.id_pedido,
       pe.fecha_pedido,
       pe.estado,
       pe.id_cliente,
       c.nombre   AS cliente,
       e.nombre   AS vendedor,
       s.nombre   AS sucursal,
       COUNT(*)                                                        AS lineas,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS total
FROM pedidos pe
JOIN clientes c       ON c.id_cliente  = pe.id_cliente
JOIN empleados e      ON e.id_empleado = pe.id_empleado
JOIN sucursales s     ON s.id_sucursal = pe.id_sucursal
JOIN detalle_pedido d ON d.id_pedido   = pe.id_pedido
GROUP BY pe.id_pedido, pe.fecha_pedido, pe.estado, pe.id_cliente, c.nombre, e.nombre, s.nombre;

-- 10b. La vista se usa como una tabla
SELECT * FROM v_pedidos_totales ORDER BY total DESC LIMIT 5;

SELECT sucursal, COUNT(*) AS pedidos, SUM(total) AS ventas
FROM v_pedidos_totales
WHERE estado <> 'Cancelado'
GROUP BY sucursal;

SHOW FULL TABLES;                         -- la columna Table_type distingue tablas de vistas
SHOW CREATE VIEW v_pedidos_totales;

-- 10c. Una vista sencilla: el catálogo que ve el público (sin costos,
--      sin productos inactivos)
CREATE OR REPLACE VIEW v_catalogo AS
SELECT p.id_producto, p.sku, p.nombre, c.nombre AS categoria, p.precio, p.stock
FROM productos p
JOIN categorias c ON c.id_categoria = p.id_categoria
WHERE p.activo;

SELECT * FROM v_catalogo WHERE categoria = 'Monitores';

-- 10d. La vista siempre muestra los datos actuales
UPDATE productos SET precio = precio + 1000 WHERE id_producto = 37;
SELECT * FROM v_catalogo WHERE id_producto = 37;
UPDATE productos SET precio = precio - 1000 WHERE id_producto = 37;      -- se deja como estaba

-- 10e. ¿Se puede modificar a través de una vista?
UPDATE v_catalogo SET precio = precio + 1000 WHERE id_producto = 37;     -- funciona
UPDATE v_catalogo SET precio = precio - 1000 WHERE id_producto = 37;

--      Una vista con GROUP BY no es actualizable → ERROR 1288 esperado
UPDATE v_pedidos_totales SET total = 0 WHERE id_pedido = 1;

-- 10f. Limpieza
DROP VIEW v_pedidos_totales, v_catalogo;

-- PREGUNTA 10.1: En 10d, ¿hubo que "actualizar" la vista después del
--                UPDATE para ver el precio nuevo? ¿Por qué?
-- PREGUNTA 10.2: ¿Por qué v_catalogo admite UPDATE y v_pedidos_totales
--                no? ¿A qué fila de qué tabla debería ir el cambio del
--                "total"?
-- PREGUNTA 10.3: Nombrar dos ventajas de las vistas: una para quien
--                escribe consultas y otra para la seguridad (se usará
--                en el laboratorio 08).
