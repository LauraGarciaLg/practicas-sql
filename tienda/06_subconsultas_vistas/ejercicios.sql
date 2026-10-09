/* =====================================================================
   LABORATORIO 06 · EJERCICIOS — Subconsultas, CTE, ventanas y vistas
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.

   Convenciones (las mismas del laboratorio 05):
     - Valor de una línea:  cantidad * precio_unitario * (1 - descuento)
     - "Ventas" y "comprado" excluyen los pedidos 'Cancelado'.
   Cada enunciado indica la técnica que se debe usar. Comparar el número
   de filas con el resultado esperado.
   ===================================================================== */

USE tienda;


/* EJERCICIO 1 · Subconsulta escalar
   Productos activos cuyo stock es mayor que el stock promedio de todos
   los productos. Mostrar nombre y stock, de mayor a menor.
   Resultado esperado: 12 filas.
*/
-- Solución:



/* EJERCICIO 2 · Subconsulta escalar con MIN
   El empleado (o los empleados) con el salario más bajo. Sin usar
   ORDER BY ni LIMIT.
   Resultado esperado: 1 fila.
*/
-- Solución:



/* EJERCICIO 3 · Subconsulta escalar sobre otra fila
   Clientes que viven en la misma ciudad que Santiago Ardila, sin
   incluirlo a él. La ciudad NO se escribe a mano.
   Resultado esperado: 5 filas.
*/
-- Solución:



/* EJERCICIO 4 · IN
   Productos que alguna vez se vendieron con 15 % de descuento. Nombre y
   precio, en orden alfabético.
   Resultado esperado: 33 filas.
*/
-- Solución:



/* EJERCICIO 5 · NOT EXISTS
   Categorías que no tienen ningún producto asignado directamente.
   Resultado esperado: 7 filas. (¿Por qué aparecen las cinco principales?)
*/
-- Solución:



/* EJERCICIO 6 · Subconsultas correlacionadas en el SELECT
   Por cada sucursal: nombre, número de empleados y número de pedidos,
   cada conteo con su propia subconsulta. Sin JOIN ni GROUP BY.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 7 · Subconsulta correlacionada en el WHERE
   Empleados que ganan más que el salario promedio de SU sucursal.
   Mostrar nombre, cargo, salario e id_sucursal.
   Resultado esperado: 5 filas.
*/
-- Solución:



/* EJERCICIO 8 · EXISTS y NOT EXISTS
   Clientes que han hecho pedidos pero nunca han recibido un envío por
   transportadora (todos sus pedidos fueron recogidos en la sucursal,
   están cancelados o aún no se despachan).
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 9 · Tabla derivada
   Clientes cuyo total comprado es mayor que el promedio de lo comprado
   por cliente. Mostrar nombre y total, de mayor a menor.
   Pista: primero el total por cliente; después, el promedio de esos
   totales.
   Resultado esperado: 8 filas.
*/
-- Solución:



/* EJERCICIO 10 · HAVING con subconsulta
   Clientes que han comprado en TODAS las sucursales que tienen pedidos.
   El número de sucursales no se escribe a mano.
   Resultado esperado: 1 fila.
*/
-- Solución:



/* EJERCICIO 11 · El más reciente de cada grupo
   El último pedido de cada cliente: nombre del cliente, número de
   pedido, fecha y estado. Resolverlo con una subconsulta correlacionada
   o con ROW_NUMBER().
   Resultado esperado: 27 filas.
*/
-- Solución:



/* EJERCICIO 12 · CTE + función de ventana
   Los 3 productos más vendidos (en unidades) de cada categoría
   PRINCIPAL: categoría, producto, unidades y puesto.
   Resultado esperado: 12 filas.
*/
-- Solución:



/* EJERCICIO 13 · Ventanas: acumulado y fila anterior
   Historial de compras del Colegio Nuevo Saber (pedidos no cancelados,
   en orden cronológico): número de pedido, fecha, total del pedido,
   total acumulado hasta ese pedido y días transcurridos desde su pedido
   anterior.
   Resultado esperado: 11 filas.
*/
-- Solución:



/* EJERCICIO 14 · CTE recursiva
   Todas las categorías con su ruta completa desde la categoría
   principal, por ejemplo:  Computadores > Portátiles
   Mostrar id_categoria, nivel y ruta, ordenado por ruta.
   Resultado esperado: 15 filas.
*/
-- Solución:



/* EJERCICIO 15 · Tres formas
   Productos activos que NO se han vendido en 2026 (en pedidos no
   cancelados). Resolverlo de dos maneras distintas (NOT EXISTS, NOT IN
   o LEFT JOIN … IS NULL) y comprobar que ambas devuelven lo mismo.
   Resultado esperado: 6 filas.
*/
-- Solución:



/* EJERCICIO 16 · Vista para informes
   a) Crear la vista v_ventas con UNA fila por cada línea vendida (sin
      pedidos cancelados) y estas columnas: id_pedido, fecha_pedido,
      anio, cliente, ciudad_cliente, vendedor, sucursal, producto,
      subcategoria, categoria (la principal), cantidad y subtotal.
   b) Usando SOLO la vista, obtener las ventas por categoría y año.
      Resultado esperado: 8 filas.
*/
-- Solución:



/* EJERCICIO 17 · Vista actualizable
   a) Crear la vista v_stock_critico con los productos activos cuyo
      stock es menor o igual al mínimo: id_producto, sku, nombre, stock
      y stock_minimo.
      Resultado esperado al consultarla: 9 filas.
   b) A través de la vista, sumar 10 unidades al stock del producto 8.
   c) Consultar otra vez la vista. ¿Sigue apareciendo el producto 8?
      ¿Por qué?
   d) Dejar el stock del producto 8 como estaba y eliminar las dos
      vistas.
*/
-- Solución:

