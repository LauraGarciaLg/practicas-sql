/* =====================================================================
   LABORATORIO 04 · EJERCICIOS — Combinar tablas
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.
   Antes de escribir cada consulta, ubicar en el diagrama las tablas que
   intervienen y el camino de claves foráneas que las une. Comparar el
   número de filas con el resultado esperado.
   En estos ejercicios NO se usa GROUP BY (eso es el laboratorio 05).
   ===================================================================== */

USE tienda;


/* EJERCICIO 1 · Dos JOIN
   Nombre de cada producto, nombre de su categoría y nombre de su
   proveedor. Deben aparecer TODOS los productos, incluso el que no
   tiene proveedor.
   Resultado esperado: 40 filas.
*/
-- Solución:



/* EJERCICIO 2 · INNER JOIN
   Nombre y cargo de cada empleado, con el nombre y la ciudad de la
   sucursal donde trabaja. Ordenar por sucursal y luego por nombre.
   Resultado esperado: 12 filas.
*/
-- Solución:



/* EJERCICIO 3 · Cuatro tablas con filtro
   Pedidos de septiembre de 2026: número de pedido, fecha, nombre y
   ciudad del cliente, nombre del vendedor y estado.
   Resultado esperado: 8 filas.
*/
-- Solución:



/* EJERCICIO 4 · La factura de un pedido
   Líneas del pedido 150: sku, nombre del producto, cantidad,
   precio_unitario, descuento y subtotal de la línea (sin decimales).
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 5 · De un cliente a sus productos
   Nombres de los productos que ha comprado alguna vez la Clínica Santa
   Lucía, sin repetir y en orden alfabético. No cuentan los pedidos
   cancelados.
   Resultado esperado: 15 filas.
*/
-- Solución:



/* EJERCICIO 6 · Cinco tablas
   Clientes (sin repetir) que han comprado algún producto de la
   categoría principal 'Audio'. Recordar que los productos pertenecen a
   subcategorías.
   Resultado esperado: 24 filas.
*/
-- Solución:



/* EJERCICIO 7 · Comparar columnas de dos tablas
   Pedidos atendidos en una sucursal que queda en una ciudad distinta a
   la del cliente: número de pedido, cliente, ciudad del cliente,
   sucursal y ciudad de la sucursal.
   Resultado esperado: 53 filas.
*/
-- Solución:



/* EJERCICIO 8 · LEFT JOIN
   Todas las sucursales con los nombres de sus empleados. La sucursal
   que aún no tiene empleados también debe aparecer.
   Resultado esperado: 13 filas.
*/
-- Solución:



/* EJERCICIO 9 · Buscar lo que falta
   Subcategorías (categorías que tienen padre) a las que todavía no
   pertenece ningún producto.
   Resultado esperado: 2 filas.
*/
-- Solución:



/* EJERCICIO 10 · Buscar lo que falta, con filtro
   Empleados con cargo 'Vendedor' que no han atendido ningún pedido.
   Resultado esperado: 1 fila.
*/
-- Solución:



/* EJERCICIO 11 · Pedidos sin pago
   Pedidos que no están cancelados y no tienen ningún pago registrado:
   número de pedido, fecha, estado y nombre del cliente.
   Resultado esperado: 3 filas.
*/
-- Solución:



/* EJERCICIO 12 · Envíos en camino
   Envíos que todavía no se han entregado: número de pedido, nombre y
   teléfono del cliente, transportadora y fecha de envío.
   Resultado esperado: 1 fila.
*/
-- Solución:



/* EJERCICIO 13 · Autocombinación doble
   Cada empleado con el nombre de su jefe y el nombre del jefe de su
   jefe. Deben aparecer los 12 empleados; donde no haya jefe se muestra
   NULL.
   Resultado esperado: 12 filas.
*/
-- Solución:



/* EJERCICIO 14 · Parejas dentro de una tabla
   Parejas de empleados que trabajan en la misma sucursal y tienen el
   mismo cargo. Cada pareja debe salir una sola vez.
   Resultado esperado: 3 filas.
*/
-- Solución:



/* EJERCICIO 15 · El filtro en ON o en WHERE
   Todos los empleados con cargo 'Vendedor' y, si los tienen, los
   números de los pedidos que atendieron en septiembre de 2026. Un
   vendedor sin pedidos en ese mes debe aparecer con NULL.
   Resultado esperado: 11 filas; tres vendedores aparecen con NULL.
*/
-- Solución:



/* EJERCICIO 16 · UNION
   Una sola lista de correos para un boletín: tipo ('Cliente' o
   'Proveedor'), nombre y email de todos los clientes y proveedores que
   tienen correo. Ordenar por tipo y nombre.
   Resultado esperado: 32 filas.
*/
-- Solución:



/* EJERCICIO 17 · Reflexión (responder en el cuaderno)
   a) Para el ejercicio 9, ¿qué resultado daría un INNER JOIN? ¿Por qué?
   b) En el ejercicio 15, ¿qué ocurre si la condición de la fecha se
      escribe en el WHERE?
*/
