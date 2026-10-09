/* =====================================================================
   LABORATORIO 05 · RESUMIR DATOS
   Funciones de agregación · GROUP BY · HAVING · ROLLUP
   ---------------------------------------------------------------------
   Objetivo: pasar del detalle al resumen. Contar, sumar y promediar
   por grupos, filtrar los grupos y combinar todo con JOIN para
   responder preguntas de negocio: cuánto se vendió, quién, dónde,
   cuándo.

   Requisito: base tienda recién cargada con 00_preparacion.
   Esta guía solo consulta: no modifica ningún dato.

   Fórmula que se usa en toda la guía (valor de una línea de pedido):
       cantidad * precio_unitario * (1 - descuento)
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;


/* ---------------------------------------------------------------------
   PASO 1 · FUNCIONES DE AGREGACIÓN: MUCHAS FILAS → UN VALOR
   --------------------------------------------------------------------- */

SELECT COUNT(*) FROM productos;

SELECT COUNT(*)              AS productos,
       SUM(stock)            AS unidades_en_bodega,
       MIN(precio)           AS mas_barato,
       MAX(precio)           AS mas_caro,
       ROUND(AVG(precio))    AS precio_promedio,
       SUM(stock * costo)    AS valor_inventario
FROM productos;

-- Con WHERE: primero se filtran las filas, después se resume
SELECT COUNT(*) AS portatiles, ROUND(AVG(precio)) AS precio_promedio
FROM productos
WHERE id_categoria = 6;

-- MIN y MAX también sirven para fechas y textos
SELECT MIN(fecha_pedido) AS primer_pedido, MAX(fecha_pedido) AS ultimo_pedido FROM pedidos;
SELECT MIN(nombre), MAX(nombre) FROM clientes;

-- PREGUNTA 1.1: ¿Cuántas filas devuelve una consulta con funciones de
--               agregación y sin GROUP BY, sin importar el tamaño de la
--               tabla?


/* ---------------------------------------------------------------------
   PASO 2 · COUNT Y LOS NULL
   --------------------------------------------------------------------- */

SELECT COUNT(*)                AS filas,
       COUNT(email)            AS con_email,
       COUNT(telefono)         AS con_telefono,
       COUNT(DISTINCT ciudad)  AS ciudades_distintas
FROM clientes;

-- AVG también ignora los NULL: días promedio de entrega
SELECT COUNT(*)                                           AS envios,
       COUNT(fecha_entrega)                               AS entregados,
       AVG(DATEDIFF(fecha_entrega, fecha_envio))          AS promedio_dias
FROM envios;

-- ¿Cuántos clientes distintos han comprado?
SELECT COUNT(id_cliente) AS pedidos, COUNT(DISTINCT id_cliente) AS clientes_que_compraron
FROM pedidos;

-- PREGUNTA 2.1: ¿Qué cuenta COUNT(*), qué cuenta COUNT(columna) y qué
--               cuenta COUNT(DISTINCT columna)?
-- PREGUNTA 2.2: El promedio de días de entrega, ¿se calculó sobre 103
--               envíos o sobre menos? ¿Por qué eso es lo correcto?
-- PREGUNTA 2.3: Hay 30 clientes. ¿Cuántos NO han comprado, según la
--               última consulta?


/* ---------------------------------------------------------------------
   PASO 3 · GROUP BY: UN RESUMEN POR CADA GRUPO
   --------------------------------------------------------------------- */

-- 3a. ¿Cuántos clientes hay en cada ciudad?
SELECT ciudad, COUNT(*) AS clientes
FROM clientes
GROUP BY ciudad
ORDER BY clientes DESC;

-- 3b. ¿Cuántos pedidos hay en cada estado?
SELECT estado, COUNT(*) AS pedidos
FROM pedidos
GROUP BY estado;

-- 3c. Varias medidas por grupo: la nómina por cargo
SELECT cargo,
       COUNT(*)              AS empleados,
       MIN(salario)          AS salario_minimo,
       MAX(salario)          AS salario_maximo,
       ROUND(AVG(salario))   AS salario_promedio,
       SUM(salario)          AS nomina_mensual
FROM empleados
GROUP BY cargo
ORDER BY nomina_mensual DESC;

-- 3d. Agrupar por DOS columnas: un grupo por cada combinación
SELECT ciudad, tipo, COUNT(*) AS clientes
FROM clientes
GROUP BY ciudad, tipo
ORDER BY ciudad, tipo;

-- 3e. Agrupar por una expresión
SELECT CASE
           WHEN precio >= 2000000 THEN 'Gama alta'
           WHEN precio >= 500000  THEN 'Gama media'
           ELSE 'Económico'
       END       AS gama,
       COUNT(*)  AS productos,
       SUM(stock) AS unidades
FROM productos
GROUP BY gama;

-- PREGUNTA 3.1: ¿Cuántas filas devuelve 3a? Compararlo con
--               SELECT DISTINCT ciudad FROM clientes.
-- PREGUNTA 3.2: En 3b, ¿cuánto suman los cinco conteos? ¿Con qué número
--               debe coincidir?


/* ---------------------------------------------------------------------
   PASO 4 · LA REGLA DE GROUP BY
   En el SELECT solo puede ir lo que está en el GROUP BY o dentro de una
   función de agregación.
   --------------------------------------------------------------------- */

-- 4a. → ERROR 1055 esperado
SELECT ciudad, nombre, COUNT(*)
FROM clientes
GROUP BY ciudad;

-- 4b. → ERROR 1140 esperado
SELECT cargo, COUNT(*) FROM empleados;

-- 4c. Si se quieren ver los nombres de cada grupo: GROUP_CONCAT
SELECT ciudad,
       COUNT(*) AS clientes,
       GROUP_CONCAT(nombre ORDER BY nombre SEPARATOR ' | ') AS quienes
FROM clientes
GROUP BY ciudad;

-- PREGUNTA 4.1: En 4a, Aguachica tiene 9 clientes. Si la consulta se
--               permitiera, ¿qué nombre debería mostrar en la fila de
--               Aguachica? ¿Por qué el SGBD prefiere rechazarla?


/* ---------------------------------------------------------------------
   PASO 5 · GROUP BY CON JOIN
   Receta: primero armar el JOIN con el detalle; después agrupar.
   --------------------------------------------------------------------- */

-- 5a. Productos por categoría (con el NOMBRE de la categoría)
SELECT c.nombre AS categoria, COUNT(*) AS productos, ROUND(AVG(p.precio)) AS precio_promedio
FROM productos p
JOIN categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY productos DESC;

-- 5b. El total de cada pedido
SELECT d.id_pedido,
       COUNT(*)                                                        AS lineas,
       SUM(d.cantidad)                                                 AS unidades,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS total
FROM detalle_pedido d
GROUP BY d.id_pedido
ORDER BY total DESC
LIMIT 10;

-- 5c. Ventas por vendedor (sin los pedidos cancelados)
SELECT e.nombre                                                        AS vendedor,
       COUNT(DISTINCT pe.id_pedido)                                    AS pedidos,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS ventas
FROM empleados e
JOIN pedidos pe       ON pe.id_empleado = e.id_empleado
JOIN detalle_pedido d ON d.id_pedido    = pe.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY e.id_empleado, e.nombre
ORDER BY ventas DESC;

-- 5d. Los 10 productos más vendidos, por unidades
SELECT p.nombre, SUM(d.cantidad) AS unidades_vendidas
FROM detalle_pedido d
JOIN productos p ON p.id_producto = d.id_producto
JOIN pedidos pe  ON pe.id_pedido  = d.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY p.id_producto, p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 5e. Ventas por categoría PRINCIPAL (cuatro JOIN antes de agrupar)
SELECT madre.nombre                                                    AS categoria,
       SUM(d.cantidad)                                                 AS unidades,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS ventas
FROM detalle_pedido d
JOIN pedidos pe       ON pe.id_pedido       = d.id_pedido
JOIN productos p      ON p.id_producto      = d.id_producto
JOIN categorias hija  ON hija.id_categoria  = p.id_categoria
JOIN categorias madre ON madre.id_categoria = hija.id_categoria_padre
WHERE pe.estado <> 'Cancelado'
GROUP BY madre.id_categoria, madre.nombre
ORDER BY ventas DESC;

-- PREGUNTA 5.1: En 5a se agrupa por c.id_categoria además de c.nombre.
--               ¿Qué podría salir mal si se agrupara solo por un nombre
--               que no fuera único (por ejemplo, el nombre de un
--               cliente)?
-- PREGUNTA 5.2: En 5c se usa COUNT(DISTINCT pe.id_pedido). ¿Qué contaría
--               COUNT(*) en esa consulta? Probarlo.
-- PREGUNTA 5.3: ¿El producto más vendido en unidades es también el que
--               más dinero genera? Escribir la consulta para comprobarlo.


/* ---------------------------------------------------------------------
   PASO 6 · LEFT JOIN + GROUP BY: QUE APAREZCAN LOS QUE TIENEN CERO
   --------------------------------------------------------------------- */

-- 6a. Con INNER JOIN, los clientes sin pedidos desaparecen del resumen
SELECT c.nombre, COUNT(*) AS pedidos
FROM clientes c
JOIN pedidos pe ON pe.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY pedidos;

-- 6b. Con LEFT JOIN aparecen… pero COUNT(*) les cuenta 1
SELECT c.nombre, COUNT(*) AS pedidos
FROM clientes c
LEFT JOIN pedidos pe ON pe.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY pedidos;

-- 6c. Correcto: contar una columna de la tabla derecha
SELECT c.nombre, COUNT(pe.id_pedido) AS pedidos
FROM clientes c
LEFT JOIN pedidos pe ON pe.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY pedidos;

-- 6d. Lo mismo con sumas: SUM de solo NULL da NULL, no cero
SELECT s.nombre                                   AS sucursal,
       COUNT(e.id_empleado)                       AS empleados,
       SUM(e.salario)                             AS nomina,
       COALESCE(SUM(e.salario), 0)                AS nomina_corregida
FROM sucursales s
LEFT JOIN empleados e ON e.id_sucursal = s.id_sucursal
GROUP BY s.id_sucursal, s.nombre;

-- PREGUNTA 6.1: ¿Cuántas filas devuelven 6a, 6b y 6c?
-- PREGUNTA 6.2: ¿Por qué COUNT(*) da 1 para un cliente sin pedidos y
--               COUNT(pe.id_pedido) da 0?


/* ---------------------------------------------------------------------
   PASO 7 · HAVING: FILTRAR GRUPOS
   WHERE filtra FILAS antes de agrupar; HAVING filtra GRUPOS después.
   --------------------------------------------------------------------- */

-- 7a. Una función de agregación en WHERE → ERROR 1111 esperado
SELECT ciudad, COUNT(*) AS clientes
FROM clientes
WHERE COUNT(*) >= 5
GROUP BY ciudad;

-- 7b. La condición sobre el grupo va en HAVING
SELECT ciudad, COUNT(*) AS clientes
FROM clientes
GROUP BY ciudad
HAVING COUNT(*) >= 5;

-- 7c. WHERE y HAVING juntos: clientes con más de 8 pedidos NO cancelados
SELECT c.nombre, COUNT(*) AS pedidos
FROM clientes c
JOIN pedidos pe ON pe.id_cliente = c.id_cliente
WHERE pe.estado <> 'Cancelado'            -- filtra filas
GROUP BY c.id_cliente, c.nombre
HAVING COUNT(*) > 8                       -- filtra grupos
ORDER BY pedidos DESC;

-- 7d. Pedidos grandes: más de 10 millones
SELECT id_pedido,
       ROUND(SUM(cantidad * precio_unitario * (1 - descuento))) AS total
FROM detalle_pedido
GROUP BY id_pedido
HAVING total > 10000000
ORDER BY total DESC;

-- 7e. Detectar repetidos: ¿hay nombres de ciudad usados por más de una sucursal?
SELECT ciudad, COUNT(*) FROM sucursales GROUP BY ciudad HAVING COUNT(*) > 1;

-- PREGUNTA 7.1: En 7c, mover "pe.estado <> 'Cancelado'" al HAVING.
--               ¿Funciona? ¿Por qué?
-- PREGUNTA 7.2: Escribir el orden completo en que se EJECUTAN las
--               cláusulas: FROM, WHERE, GROUP BY, HAVING, SELECT,
--               ORDER BY, LIMIT.
-- PREGUNTA 7.3: 7e devuelve cero filas. ¿Qué significa eso? ¿Para qué
--               sirve este patrón al revisar la calidad de los datos?


/* ---------------------------------------------------------------------
   PASO 8 · AGRUPAR POR FECHAS
   --------------------------------------------------------------------- */

-- 8a. Pedidos por año
SELECT YEAR(fecha_pedido) AS anio, COUNT(*) AS pedidos
FROM pedidos
GROUP BY YEAR(fecha_pedido);

-- 8b. Ventas por mes
SELECT DATE_FORMAT(pe.fecha_pedido, '%Y-%m')                           AS periodo,
       COUNT(DISTINCT pe.id_pedido)                                    AS pedidos,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento)))  AS ventas
FROM pedidos pe
JOIN detalle_pedido d ON d.id_pedido = pe.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY periodo
ORDER BY periodo;

-- 8c. ¿Qué día de la semana se vende más?
SELECT DAYOFWEEK(fecha_pedido) AS numero, DAYNAME(fecha_pedido) AS dia, COUNT(*) AS pedidos
FROM pedidos
GROUP BY numero, dia
ORDER BY numero;

-- 8d. ¿A qué hora llegan los pedidos?
SELECT HOUR(fecha_pedido) AS hora, COUNT(*) AS pedidos
FROM pedidos
GROUP BY hora
ORDER BY hora;

-- PREGUNTA 8.1: En 8b, ¿por qué se agrupa por año-mes y no solo por
--               MONTH(fecha_pedido)? ¿Qué se mezclaría?
-- PREGUNTA 8.2: ¿Cuál fue el mejor mes en ventas y cuál el peor?


/* ---------------------------------------------------------------------
   PASO 9 · AGREGACIÓN CONDICIONAL: VARIAS COLUMNAS A PARTIR DE UNA
   Un CASE dentro de la función decide qué filas cuentan en cada columna.
   --------------------------------------------------------------------- */

-- 9a. Los estados "en columnas", por sucursal
SELECT s.nombre                                               AS sucursal,
       COUNT(*)                                               AS total,
       SUM(CASE WHEN pe.estado = 'Entregado' THEN 1 ELSE 0 END) AS entregados,
       SUM(CASE WHEN pe.estado = 'Cancelado' THEN 1 ELSE 0 END) AS cancelados,
       SUM(pe.estado IN ('Pendiente', 'Pagado', 'Enviado'))     AS en_proceso
FROM pedidos pe
JOIN sucursales s ON s.id_sucursal = pe.id_sucursal
GROUP BY s.id_sucursal, s.nombre;

-- 9b. Ventas de cada año, lado a lado, por categoría principal
SELECT madre.nombre AS categoria,
       ROUND(SUM(CASE WHEN YEAR(pe.fecha_pedido) = 2025
                      THEN d.cantidad * d.precio_unitario * (1 - d.descuento) ELSE 0 END)) AS ventas_2025,
       ROUND(SUM(CASE WHEN YEAR(pe.fecha_pedido) = 2026
                      THEN d.cantidad * d.precio_unitario * (1 - d.descuento) ELSE 0 END)) AS ventas_2026
FROM detalle_pedido d
JOIN pedidos pe       ON pe.id_pedido       = d.id_pedido
JOIN productos p      ON p.id_producto      = d.id_producto
JOIN categorias hija  ON hija.id_categoria  = p.id_categoria
JOIN categorias madre ON madre.id_categoria = hija.id_categoria_padre
WHERE pe.estado <> 'Cancelado'
GROUP BY madre.id_categoria, madre.nombre;

-- 9c. Porcentaje de cancelación por vendedor
SELECT e.nombre,
       COUNT(*)                                               AS pedidos,
       SUM(pe.estado = 'Cancelado')                           AS cancelados,
       ROUND(AVG(pe.estado = 'Cancelado') * 100, 1)           AS pct_cancelados
FROM pedidos pe
JOIN empleados e ON e.id_empleado = pe.id_empleado
GROUP BY e.id_empleado, e.nombre
ORDER BY pct_cancelados DESC;

-- PREGUNTA 9.1: En MySQL una comparación vale 1 si es cierta y 0 si es
--               falsa. Con eso, explicar por qué SUM(estado = 'Cancelado')
--               cuenta y AVG(estado = 'Cancelado') da una proporción.
-- PREGUNTA 9.2: ¿Qué categoría principal no aparece en 9b y por qué?


/* ---------------------------------------------------------------------
   PASO 10 · WITH ROLLUP: SUBTOTALES Y TOTAL GENERAL
   --------------------------------------------------------------------- */

-- 10a. Una fila extra con el total general
SELECT estado, COUNT(*) AS pedidos
FROM pedidos
GROUP BY estado WITH ROLLUP;

-- 10b. Con dos columnas: subtotal por sucursal y total general
SELECT s.nombre AS sucursal, pe.estado, COUNT(*) AS pedidos
FROM pedidos pe
JOIN sucursales s ON s.id_sucursal = pe.id_sucursal
GROUP BY s.nombre, pe.estado WITH ROLLUP;

-- 10c. Etiquetar las filas de total
SELECT IF(GROUPING(s.nombre), 'TODAS LAS SUCURSALES', s.nombre) AS sucursal,
       IF(GROUPING(pe.estado), 'Total', pe.estado)              AS estado,
       COUNT(*)                                                 AS pedidos
FROM pedidos pe
JOIN sucursales s ON s.id_sucursal = pe.id_sucursal
GROUP BY s.nombre, pe.estado WITH ROLLUP;

-- PREGUNTA 10.1: En 10b, ¿cómo se reconocen las filas de subtotal y la
--                del total general?


/* ---------------------------------------------------------------------
   PASO 11 · LA TRAMPA: DOS TABLAS "MUCHOS" EN EL MISMO JOIN
   Pregunta: por cada pedido, cuánto vale y cuánto se ha pagado.
   --------------------------------------------------------------------- */

-- 11a. El pedido 150 tiene 4 líneas de detalle y 2 pagos
SELECT * FROM detalle_pedido WHERE id_pedido = 150;
SELECT * FROM pagos          WHERE id_pedido = 150;

-- 11b. Uniendo las dos tablas al mismo tiempo…
SELECT pe.id_pedido,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento))) AS total,
       SUM(pg.valor)                                                  AS pagado
FROM pedidos pe
JOIN detalle_pedido d ON d.id_pedido  = pe.id_pedido
JOIN pagos pg         ON pg.id_pedido = pe.id_pedido
WHERE pe.id_pedido = 150
GROUP BY pe.id_pedido;

-- 11c. …cada línea se repite por cada pago, y cada pago por cada línea
SELECT pe.id_pedido, d.id_producto, pg.id_pago, pg.valor
FROM pedidos pe
JOIN detalle_pedido d ON d.id_pedido  = pe.id_pedido
JOIN pagos pg         ON pg.id_pedido = pe.id_pedido
WHERE pe.id_pedido = 150;

-- 11d. Solución: resumir cada tabla POR SEPARADO y unir los resúmenes
SELECT pe.id_pedido, pe.estado, t.total, COALESCE(g.pagado, 0) AS pagado,
       t.total - COALESCE(g.pagado, 0) AS saldo
FROM pedidos pe
JOIN (SELECT id_pedido,
             ROUND(SUM(cantidad * precio_unitario * (1 - descuento))) AS total
      FROM detalle_pedido
      GROUP BY id_pedido) t ON t.id_pedido = pe.id_pedido
LEFT JOIN (SELECT id_pedido, SUM(valor) AS pagado
           FROM pagos
           GROUP BY id_pedido) g ON g.id_pedido = pe.id_pedido
WHERE pe.estado IN ('Pendiente', 'Pagado', 'Enviado')
ORDER BY pe.id_pedido;

-- PREGUNTA 11.1: ¿Cuántas filas devuelve 11c? ¿Por cuánto quedó
--                multiplicado el total y por cuánto lo pagado en 11b?
-- PREGUNTA 11.2: ¿Qué pedidos tienen saldo pendiente según 11d?
-- PREGUNTA 11.3: Los resúmenes entre paréntesis de 11d son subconsultas
--                en el FROM. El laboratorio 06 las estudia a fondo.
--                ¿Por qué el segundo se une con LEFT JOIN?
