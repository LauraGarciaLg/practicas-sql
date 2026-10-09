/* =====================================================================
   LABORATORIO 05 · EJERCICIOS — Resumir datos
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.

   Convenciones para todos los ejercicios:
     - Valor de una línea:  cantidad * precio_unitario * (1 - descuento)
     - "Ventas" excluye siempre los pedidos en estado 'Cancelado'.
     - Los valores en dinero se muestran sin decimales (ROUND).
   Comparar el número de filas con el resultado esperado.
   ===================================================================== */

USE tienda;


/* EJERCICIO 1 · Agregación simple
   En una sola fila: cuántos productos activos hay, su precio promedio y
   cuánto valdría todo el inventario si se vendiera al precio de lista
   (stock × precio).
   Resultado esperado: 1 fila, con 39 productos.
*/
-- Solución:



/* EJERCICIO 2 · LEFT JOIN + GROUP BY
   Cantidad de productos que surte cada proveedor (nombre del
   proveedor). El proveedor que no surte ninguno debe aparecer con 0.
   Ordenar de mayor a menor.
   Resultado esperado: 8 filas.
*/
-- Solución:



/* EJERCICIO 3 · Varias medidas por grupo
   Por cada sucursal: número de empleados, salario promedio y nómina
   total. La sucursal sin empleados debe aparecer con 0 empleados y
   nómina 0.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 4 · GROUP BY sobre una tabla
   Por cada método de pago: cantidad de pagos, valor total y valor
   promedio. Ordenar por valor total descendente.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 5 · Agregación y NULL
   Por cada transportadora: envíos realizados, envíos ya entregados,
   costo total de envío y promedio de días entre envío y entrega (con
   un decimal).
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 6 · Ranking con JOIN
   Los 5 clientes que más han comprado: nombre, tipo, número de pedidos
   y total comprado.
   Resultado esperado: 5 filas.
*/
-- Solución:



/* EJERCICIO 7 · Agrupar por dos criterios
   Ventas por sucursal y año: sucursal, año, número de pedidos y ventas.
   Ordenar por sucursal y año.
   Resultado esperado: 6 filas.
*/
-- Solución:



/* EJERCICIO 8 · HAVING
   Ciudades (de los clientes) cuyas ventas superan los 30 millones:
   ciudad y ventas, de mayor a menor.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 9 · COUNT(DISTINCT) y HAVING
   Productos que aparecen en más de 15 pedidos distintos: nombre del
   producto, número de pedidos y unidades vendidas.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 10 · WHERE y HAVING juntos
   Clientes con más de un pedido cancelado: nombre y cantidad de
   cancelaciones.
   Resultado esperado: 3 filas.
*/
-- Solución:



/* EJERCICIO 11 · Agrupar por fechas
   Ventas por trimestre: año, trimestre, número de pedidos y ventas,
   en orden cronológico.
   Resultado esperado: 7 filas.
*/
-- Solución:



/* EJERCICIO 12 · Agregación condicional
   Por cada categoría PRINCIPAL, las unidades vendidas separadas en dos
   columnas: unidades_personas y unidades_empresas, según el tipo de
   cliente que compró.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 13 · Una medida calculada
   Los 10 productos que más utilidad han dejado. La utilidad de una
   línea es lo que se cobró menos lo que costó:
       cantidad * (precio_unitario * (1 - descuento) - costo)
   (se usa el costo actual del producto). Mostrar nombre, unidades
   vendidas y utilidad.
   Resultado esperado: 10 filas.
*/
-- Solución:



/* EJERCICIO 14 · ROLLUP
   Por cada vendedor: número de pedidos, ventas y venta promedio por
   pedido (ventas / pedidos). Agregar una fila final con el total
   general.
   Resultado esperado: 6 filas (5 vendedores y el total).
*/
-- Solución:



/* EJERCICIO 15 · Buscar patrones con HAVING
   Meses (año-mes) en los que se cancelaron 2 o más pedidos.
   Resultado esperado: 2 filas.
*/
-- Solución:



/* EJERCICIO 16 · La trampa de las dos tablas "muchos"
   Un estudiante escribió esta consulta para comparar, por cliente, lo
   que ha comprado y lo que ha pagado. Los números salen inflados.
     a) Explicar por qué.
     b) Escribir una versión correcta. Pista: PASO 11 de la guía.
        Resultado esperado: 27 filas.

   SELECT c.nombre,
          ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento))) AS comprado,
          SUM(pg.valor) AS pagado
   FROM clientes c
   JOIN pedidos pe       ON pe.id_cliente = c.id_cliente
   JOIN detalle_pedido d ON d.id_pedido   = pe.id_pedido
   JOIN pagos pg         ON pg.id_pedido  = pe.id_pedido
   WHERE pe.estado <> 'Cancelado'
   GROUP BY c.id_cliente, c.nombre;
*/
-- Solución:

