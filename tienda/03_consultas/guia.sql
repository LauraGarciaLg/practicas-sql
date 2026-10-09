/* =====================================================================
   LABORATORIO 03 · CONSULTAS SOBRE UNA TABLA
   SELECT · WHERE · ORDER BY · LIMIT · funciones · CASE
   ---------------------------------------------------------------------
   Objetivo: dominar SELECT sobre una sola tabla antes de combinar
   varias: elegir columnas, calcular, filtrar, ordenar, paginar y
   transformar textos, números y fechas.

   Requisito: base tienda recién cargada con 00_preparacion.
   Esta guía solo consulta: no modifica ningún dato.

   Cómo trabajar: una consulta a la vez. Antes de ejecutarla, predecir
   cuántas filas devolverá; después, comparar.
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;


/* ---------------------------------------------------------------------
   PASO 1 · ELEGIR COLUMNAS, CALCULAR Y RENOMBRAR
   --------------------------------------------------------------------- */

SELECT * FROM sucursales;                               -- todas las columnas

SELECT nombre, ciudad FROM sucursales;                  -- solo algunas, en el orden pedido

-- Columnas calculadas y alias
SELECT nombre,
       costo,
       precio,
       precio - costo                            AS ganancia,
       ROUND((precio - costo) / costo * 100, 1)  AS margen_pct
FROM productos;

-- Un alias con espacios va entre comillas invertidas
SELECT nombre AS `Nombre del producto`, stock * costo AS `Valor en bodega`
FROM productos;

-- SELECT sin tabla: sirve para probar expresiones
SELECT 7 / 2, 7 DIV 2, 7 % 2, CURRENT_DATE, NOW();

-- DISTINCT: quitar filas repetidas del resultado
SELECT ciudad FROM clientes;
SELECT DISTINCT ciudad FROM clientes;
SELECT DISTINCT ciudad, tipo FROM clientes;

-- PREGUNTA 1.1: ¿Las columnas ganancia y margen_pct existen en la tabla
--               productos? ¿Dónde "viven"?
-- PREGUNTA 1.2: ¿Cuántas filas devolvió cada una de las tres últimas
--               consultas? ¿Sobre qué se aplica DISTINCT cuando hay dos
--               columnas?
-- PREGUNTA 1.3: ¿Por qué en un programa real se evita SELECT * ?


/* ---------------------------------------------------------------------
   PASO 2 · WHERE: COMPARACIONES Y OPERADORES LÓGICOS
   --------------------------------------------------------------------- */

SELECT nombre, precio FROM productos WHERE precio > 2000000;

SELECT nombre, cargo FROM empleados WHERE cargo <> 'Vendedor';

SELECT nombre, stock, stock_minimo FROM productos WHERE stock < stock_minimo;    -- columna contra columna

SELECT nombre, ciudad, tipo
FROM clientes
WHERE ciudad = 'Aguachica' AND tipo = 'Empresa';

SELECT nombre, ciudad
FROM clientes
WHERE ciudad = 'Ocaña' OR ciudad = 'Cúcuta';

SELECT nombre, ciudad FROM clientes WHERE NOT ciudad = 'Aguachica';

-- La precedencia: AND se evalúa antes que OR
SELECT nombre, ciudad, tipo
FROM clientes
WHERE ciudad = 'Ocaña' OR ciudad = 'Cúcuta' AND tipo = 'Empresa';         -- 2a

SELECT nombre, ciudad, tipo
FROM clientes
WHERE (ciudad = 'Ocaña' OR ciudad = 'Cúcuta') AND tipo = 'Empresa';       -- 2b

-- Texto: con la intercalación de la base (…_ai_ci) no se distinguen
-- mayúsculas ni tildes
SELECT nombre, ciudad FROM clientes WHERE ciudad = 'ocana';

-- PREGUNTA 2.1: ¿Cuántas filas devuelven 2a y 2b? Explicar la
--               diferencia con palabras.
-- PREGUNTA 2.2: En la última consulta, ¿aparecen los clientes de Ocaña?
--               ¿Qué significan "ai" y "ci" en utf8mb4_0900_ai_ci?


/* ---------------------------------------------------------------------
   PASO 3 · BETWEEN, IN y LIKE
   --------------------------------------------------------------------- */

-- BETWEEN incluye los dos extremos
SELECT nombre, precio FROM productos WHERE precio BETWEEN 100000 AND 500000;

SELECT nombre, fecha_registro
FROM clientes
WHERE fecha_registro BETWEEN '2025-01-01' AND '2025-06-30';

-- IN: pertenecer a una lista
SELECT nombre, ciudad FROM clientes WHERE ciudad IN ('Ocaña', 'Cúcuta', 'Bucaramanga');
SELECT nombre, ciudad FROM clientes WHERE ciudad NOT IN ('Aguachica', 'Bucaramanga');

-- LIKE: patrones.  %  = cualquier cantidad de caracteres   _ = exactamente uno
SELECT nombre FROM productos WHERE nombre LIKE 'Portátil%';        -- empieza por
SELECT nombre FROM productos WHERE nombre LIKE '%Bluetooth%';      -- contiene
SELECT nombre FROM clientes  WHERE nombre LIKE '%ez';              -- termina en
SELECT sku    FROM productos WHERE sku LIKE 'ACC-00_';             -- un carácter exacto
SELECT nombre FROM clientes  WHERE nombre LIKE '_a%';              -- segunda letra "a"
SELECT nombre FROM productos WHERE nombre NOT LIKE '%GB%';

-- La trampa de BETWEEN con fecha Y HORA: pedidos de agosto de 2026
SELECT COUNT(*) FROM pedidos
WHERE fecha_pedido BETWEEN '2026-08-01' AND '2026-08-31';                  -- 3a

SELECT COUNT(*) FROM pedidos
WHERE fecha_pedido >= '2026-08-01' AND fecha_pedido < '2026-09-01';        -- 3b

SELECT id_pedido, fecha_pedido FROM pedidos WHERE DATE(fecha_pedido) = '2026-08-31';

-- PREGUNTA 3.1: 3a y 3b deberían contar lo mismo, pero no. ¿Qué pedido
--               se pierde en 3a y por qué? (Pista: '2026-08-31'
--               equivale a '2026-08-31 00:00:00'.)
-- PREGUNTA 3.2: ¿Qué forma de filtrar un mes es la segura para columnas
--               DATETIME?
-- PREGUNTA 3.3: ¿Cuántos productos tienen "GB" en el nombre?


/* ---------------------------------------------------------------------
   PASO 4 · NULL: EL VALOR DESCONOCIDO
   --------------------------------------------------------------------- */

SELECT nombre, email FROM clientes WHERE email IS NULL;
SELECT nombre, email FROM clientes WHERE email IS NOT NULL;

-- 4a. La trampa clásica: comparar con = NULL
SELECT nombre, email FROM clientes WHERE email = NULL;

-- 4b. Estas dos consultas "opuestas" no suman los 30 clientes
SELECT COUNT(*) FROM clientes WHERE email LIKE '%@correo.example';
SELECT COUNT(*) FROM clientes WHERE email NOT LIKE '%@correo.example';

-- 4c. Un NULL en la lista de NOT IN deja la consulta sin resultados
SELECT nombre, ciudad FROM clientes WHERE ciudad NOT IN ('Aguachica', NULL);

-- 4d. Operar con NULL da NULL
SELECT 5 + NULL, CONCAT('Hola ', NULL), NULL = NULL, NULL IS NULL;

-- 4e. Reemplazar el NULL al mostrar
SELECT nombre,
       IFNULL(email, 'sin correo')                  AS email,
       COALESCE(telefono, email, 'sin contacto')    AS contacto
FROM clientes;

-- PREGUNTA 4.1: ¿Cuántas filas devuelve 4a? ¿Qué resultado da cualquier
--               comparación con NULL?
-- PREGUNTA 4.2: En 4b, ¿cuánto suman los dos conteos? ¿Dónde están los
--               clientes que faltan?
-- PREGUNTA 4.3: ¿Qué diferencia hay entre IFNULL y COALESCE? ¿Qué
--               cliente aparece como 'sin contacto'?


/* ---------------------------------------------------------------------
   PASO 5 · ORDER BY y LIMIT
   --------------------------------------------------------------------- */

SELECT nombre, precio FROM productos ORDER BY precio;              -- ascendente (por defecto)
SELECT nombre, precio FROM productos ORDER BY precio DESC;

-- Varios criterios: el segundo desempata al primero
SELECT nombre, cargo, salario
FROM empleados
ORDER BY cargo ASC, salario DESC;

-- Ordenar por una expresión o por un alias
SELECT nombre, precio - costo AS ganancia
FROM productos
ORDER BY ganancia DESC;

-- ¿Dónde quedan los NULL al ordenar?
SELECT nombre, telefono FROM clientes ORDER BY telefono;

-- LIMIT: los primeros N
SELECT nombre, precio FROM productos ORDER BY precio DESC LIMIT 5;

-- LIMIT con OFFSET: paginación (página 1, 2 y 3 de 10 productos)
SELECT id_producto, nombre FROM productos ORDER BY id_producto LIMIT 10 OFFSET 0;
SELECT id_producto, nombre FROM productos ORDER BY id_producto LIMIT 10 OFFSET 10;
SELECT id_producto, nombre FROM productos ORDER BY id_producto LIMIT 10 OFFSET 20;

-- LIMIT sin ORDER BY: ¿cuáles cinco?
SELECT nombre, precio FROM productos LIMIT 5;

-- PREGUNTA 5.1: ¿En qué posición aparecen los NULL con ORDER BY
--               ascendente? ¿Y con DESC?
-- PREGUNTA 5.2: ¿Por qué LIMIT sin ORDER BY no garantiza qué filas se
--               obtienen?
-- PREGUNTA 5.3: Escribir la fórmula del OFFSET para la página P con N
--               filas por página.


/* ---------------------------------------------------------------------
   PASO 6 · FUNCIONES DE TEXTO
   --------------------------------------------------------------------- */

SELECT nombre,
       UPPER(nombre)                 AS mayusculas,
       LOWER(nombre)                 AS minusculas,
       CHAR_LENGTH(nombre)           AS letras,
       LEFT(nombre, 5)               AS primeras_5,
       SUBSTRING(nombre, 1, 10)      AS primeras_10
FROM clientes
LIMIT 5;

-- CONCAT une textos; CONCAT_WS usa un separador
SELECT CONCAT(nombre, ' (', ciudad, ')')           AS cliente,
       CONCAT_WS(' · ', documento, tipo, ciudad)   AS ficha
FROM clientes
LIMIT 5;

-- Partir un texto: el prefijo del sku y el dominio del correo
SELECT sku,
       SUBSTRING_INDEX(sku, '-', 1)   AS prefijo,
       SUBSTRING_INDEX(sku, '-', -1)  AS consecutivo
FROM productos
LIMIT 5;

SELECT email, SUBSTRING_INDEX(email, '@', -1) AS dominio
FROM proveedores;

-- REPLACE, TRIM, LPAD
SELECT REPLACE(nombre, 'S.A.S.', 'SAS')      AS nombre_limpio,
       TRIM('   Aguachica   ')               AS sin_espacios,
       LPAD(id_proveedor, 5, '0')            AS codigo
FROM proveedores;

-- CHAR_LENGTH cuenta caracteres; LENGTH cuenta bytes
SELECT ciudad, CHAR_LENGTH(ciudad) AS caracteres, LENGTH(ciudad) AS bytes
FROM sucursales;

-- Las funciones también sirven en WHERE y ORDER BY
SELECT nombre FROM productos WHERE CHAR_LENGTH(nombre) > 35 ORDER BY CHAR_LENGTH(nombre) DESC;

-- PREGUNTA 6.1: ¿En qué ciudades difieren caracteres y bytes? ¿Por qué?
-- PREGUNTA 6.2: ¿Qué devuelve SUBSTRING_INDEX cuando el email es NULL?


/* ---------------------------------------------------------------------
   PASO 7 · FUNCIONES NUMÉRICAS
   --------------------------------------------------------------------- */

SELECT precio / 3                  AS sin_redondear,
       ROUND(precio / 3)           AS entero,
       ROUND(precio / 3, 2)        AS dos_decimales,
       ROUND(precio / 3, -3)       AS a_miles,
       CEILING(precio / 3)         AS hacia_arriba,
       FLOOR(precio / 3)           AS hacia_abajo,
       TRUNCATE(precio / 3, 1)     AS truncado
FROM productos
WHERE id_producto = 1;

-- El valor de cada línea de un pedido: cantidad × precio × (1 − descuento)
SELECT id_pedido, id_producto, cantidad, precio_unitario, descuento,
       cantidad * precio_unitario                              AS bruto,
       ROUND(cantidad * precio_unitario * descuento)           AS valor_descuento,
       ROUND(cantidad * precio_unitario * (1 - descuento))     AS neto
FROM detalle_pedido
WHERE id_pedido = 2;

-- FORMAT: separador de miles para mostrar (el resultado es TEXTO)
SELECT nombre, precio, FORMAT(precio, 0, 'es_CO') AS precio_legible
FROM productos
ORDER BY precio DESC
LIMIT 5;

-- PREGUNTA 7.1: ¿Qué hace el segundo argumento de ROUND cuando es
--               negativo?
-- PREGUNTA 7.2: Como FORMAT devuelve texto, ¿qué pasaría si se ordena
--               por precio_legible en lugar de precio? Comprobarlo.


/* ---------------------------------------------------------------------
   PASO 8 · FUNCIONES DE FECHA
   --------------------------------------------------------------------- */

SELECT fecha_pedido,
       DATE(fecha_pedido)        AS solo_fecha,
       TIME(fecha_pedido)        AS solo_hora,
       YEAR(fecha_pedido)        AS anio,
       MONTH(fecha_pedido)       AS mes,
       DAY(fecha_pedido)         AS dia,
       HOUR(fecha_pedido)        AS hora,
       DAYNAME(fecha_pedido)     AS dia_semana,
       QUARTER(fecha_pedido)     AS trimestre
FROM pedidos
LIMIT 5;

-- DATE_FORMAT: la fecha como texto, en el formato que se necesite
SELECT fecha_pedido,
       DATE_FORMAT(fecha_pedido, '%d/%m/%Y')          AS formato_colombiano,
       DATE_FORMAT(fecha_pedido, '%Y-%m')             AS periodo,
       DATE_FORMAT(fecha_pedido, '%d de %M de %Y')    AS largo
FROM pedidos
LIMIT 5;

-- Nombres de día y mes en español (vale para la sesión actual)
SET lc_time_names = 'es_CO';
SELECT DATE_FORMAT(fecha_pedido, '%W %d de %M de %Y') AS fecha_larga FROM pedidos LIMIT 5;

-- Diferencias entre fechas: días que tardó cada entrega
SELECT id_pedido, fecha_envio, fecha_entrega,
       DATEDIFF(fecha_entrega, fecha_envio) AS dias_en_camino
FROM envios
ORDER BY dias_en_camino DESC
LIMIT 8;

-- Antigüedad de los empleados a 31 de diciembre de 2026
SELECT nombre, fecha_ingreso,
       TIMESTAMPDIFF(YEAR,  fecha_ingreso, '2026-12-31') AS anios,
       TIMESTAMPDIFF(MONTH, fecha_ingreso, '2026-12-31') AS meses
FROM empleados
ORDER BY fecha_ingreso;

-- Sumar y restar intervalos
SELECT fecha_envio,
       DATE_ADD(fecha_envio, INTERVAL 5 DAY)    AS entrega_maxima,
       fecha_envio + INTERVAL 1 MONTH           AS un_mes_despues,
       LAST_DAY(fecha_envio)                    AS fin_de_mes
FROM envios
LIMIT 5;

-- Filtrar por partes de la fecha
SELECT id_pedido, fecha_pedido FROM pedidos
WHERE YEAR(fecha_pedido) = 2026 AND MONTH(fecha_pedido) = 9;

SELECT id_pedido, fecha_pedido, DAYNAME(fecha_pedido) AS dia FROM pedidos
WHERE DAYOFWEEK(fecha_pedido) = 7;                -- 1 = domingo … 7 = sábado

-- PREGUNTA 8.1: ¿Qué diferencia hay entre DATEDIFF y TIMESTAMPDIFF?
-- PREGUNTA 8.2: ¿Hay pedidos en domingo? Escribir la consulta que lo
--               comprueba.
-- PREGUNTA 8.3: En la consulta de entregas, ¿dónde quedaron los envíos
--               con fecha_entrega en NULL y qué valor muestra
--               dias_en_camino?


/* ---------------------------------------------------------------------
   PASO 9 · CASE e IF: DECIDIR DENTRO DE LA CONSULTA
   --------------------------------------------------------------------- */

-- CASE con condiciones: clasificar los productos por precio
SELECT nombre, precio,
       CASE
           WHEN precio >= 2000000 THEN 'Gama alta'
           WHEN precio >= 500000  THEN 'Gama media'
           ELSE 'Económico'
       END AS gama
FROM productos
ORDER BY precio DESC;

-- CASE con valores: traducir un código
SELECT id_pedido, estado,
       CASE estado
           WHEN 'Pendiente' THEN 'Falta el pago'
           WHEN 'Pagado'    THEN 'Listo para despachar'
           WHEN 'Enviado'   THEN 'En camino'
           WHEN 'Entregado' THEN 'Cerrado'
           ELSE 'Anulado'
       END AS situacion
FROM pedidos
ORDER BY id_pedido DESC
LIMIT 15;

-- IF: una sola condición
SELECT nombre, stock, stock_minimo,
       IF(stock < stock_minimo, 'REPONER', 'ok') AS alerta
FROM productos
ORDER BY alerta DESC, nombre;

-- CASE en ORDER BY: un orden que no es alfabético ni numérico
SELECT nombre, cargo
FROM empleados
ORDER BY CASE cargo
             WHEN 'Gerente'       THEN 1
             WHEN 'Administrador' THEN 2
             WHEN 'Contador'      THEN 3
             WHEN 'Vendedor'      THEN 4
             ELSE 5
         END, nombre;

-- PREGUNTA 9.1: En el primer CASE, ¿importa el orden de los WHEN? ¿Qué
--               pasaría si "precio >= 500000" fuera el primero?
-- PREGUNTA 9.2: ¿Qué devuelve un CASE sin ELSE cuando ninguna condición
--               se cumple?


/* ---------------------------------------------------------------------
   PASO 10 · EL ORDEN EN QUE SE EVALÚA UNA CONSULTA
   Se ESCRIBE:  SELECT → FROM → WHERE → ORDER BY → LIMIT
   Se EJECUTA:  FROM → WHERE → SELECT → ORDER BY → LIMIT
   --------------------------------------------------------------------- */

-- 10a. El alias se define en SELECT, que se evalúa DESPUÉS de WHERE
--      → ERROR 1054 esperado
SELECT nombre, precio - costo AS ganancia
FROM productos
WHERE ganancia > 500000;

-- 10b. En WHERE hay que repetir la expresión
SELECT nombre, precio - costo AS ganancia
FROM productos
WHERE precio - costo > 500000;

-- 10c. En ORDER BY sí se puede usar el alias
SELECT nombre, precio - costo AS ganancia
FROM productos
WHERE precio - costo > 500000
ORDER BY ganancia DESC;

-- PREGUNTA 10.1: Con el orden de ejecución, explicar por qué 10a falla
--                y 10c funciona.
