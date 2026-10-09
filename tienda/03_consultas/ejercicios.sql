/* =====================================================================
   LABORATORIO 03 · EJERCICIOS — Consultas sobre una tabla
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.
   Cada consulta usa UNA sola tabla. Cada estudiante escribe su
   solución debajo del enunciado y compara el número de filas con el
   resultado esperado: si no coincide, la consulta no está bien.
   ===================================================================== */

USE tienda;


/* EJERCICIO 1 · Columnas calculadas
   Nombre, precio y precio con IVA del 19 % (columna precio_con_iva, sin
   decimales) de todos los productos, en orden alfabético.
   Resultado esperado: 40 filas.
*/
-- Solución:



/* EJERCICIO 2 · DISTINCT
   Ciudades donde hay proveedores, sin repetir y en orden alfabético.
   Resultado esperado: 7 filas.
*/
-- Solución:



/* EJERCICIO 3 · AND, BETWEEN y ORDER BY
   Productos activos que cuestan entre 500.000 y 1.500.000, del más caro
   al más barato.
   Resultado esperado: 9 filas.
*/
-- Solución:



/* EJERCICIO 4 · Operadores lógicos
   Clientes de tipo Empresa que NO son de Aguachica.
   Resultado esperado: 4 filas.
*/
-- Solución:



/* EJERCICIO 5 · NULL
   Clientes a los que les falta el correo o el teléfono. Mostrar nombre,
   email y telefono.
   Resultado esperado: 6 filas.
*/
-- Solución:



/* EJERCICIO 6 · LIKE
   Productos cuyo nombre contiene "gamer" o "RGB".
   Resultado esperado: 5 filas.
*/
-- Solución:



/* EJERCICIO 7 · Fechas
   Empleados que ingresaron entre 2020 y 2022 (ambos años completos),
   del más antiguo al más reciente.
   Resultado esperado: 5 filas.
*/
-- Solución:



/* EJERCICIO 8 · Fecha y hora
   Pedidos cancelados del segundo trimestre de 2026 (abril, mayo y
   junio). Atención: fecha_pedido es DATETIME.
   Resultado esperado: 1 fila.
*/
-- Solución:



/* EJERCICIO 9 · Expresiones, ORDER BY y LIMIT
   Los 5 productos con mayor margen de ganancia. El margen es
   (precio - costo) / costo, expresado en porcentaje con un decimal.
   Mostrar nombre, costo, precio y margen_pct.
   Resultado esperado: 5 filas; el primero es un protector de pantalla con 200.0.
*/
-- Solución:



/* EJERCICIO 10 · Paginación
   La TERCERA página de la lista de clientes ordenada por nombre, con
   8 clientes por página.
   Resultado esperado: 8 filas.
*/
-- Solución:



/* EJERCICIO 11 · Funciones de texto
   Para los clientes cuyo nombre tiene más de 20 caracteres, una sola
   columna "etiqueta" con el formato  NOMBRE EN MAYÚSCULAS (Ciudad)  y
   otra columna con la cantidad de caracteres del nombre. Ordenar del
   nombre más largo al más corto.
   Resultado esperado: 5 filas.
*/
-- Solución:



/* EJERCICIO 12 · Texto y NULL
   Nombre de cada proveedor y el dominio de su correo (lo que va después
   de la @). Si no tiene correo, mostrar 'sin correo'.
   Resultado esperado: 8 filas, dos de ellas con 'sin correo'.
*/
-- Solución:



/* EJERCICIO 13 · Diferencia de fechas
   Envíos que tardaron más de 5 días en llegar: id_pedido,
   transportadora, fecha_envio, fecha_entrega y dias. Del más demorado
   al menos demorado.
   Resultado esperado: 16 filas.
*/
-- Solución:



/* EJERCICIO 14 · TIMESTAMPDIFF y CASE
   Nombre, fecha de ingreso y años cumplidos en la empresa al 31 de
   diciembre de 2026 de cada empleado, más una columna "antiguedad":
     - 7 años o más  → 'Fundador'
     - 3 años o más  → 'Antiguo'
     - menos de 3    → 'Nuevo'
   Resultado esperado: 12 filas; 3 fundadores, 7 antiguos y 2 nuevos.
*/
-- Solución:



/* EJERCICIO 15 · CASE en SELECT y en ORDER BY
   Productos activos con una columna "inventario":
     - 'Agotado'  si no hay existencias
     - 'Bajo'     si el stock está por debajo del mínimo
     - 'Justo'    si el stock es igual al mínimo
     - 'Suficiente' en los demás casos
   Mostrar solo los que NO están en 'Suficiente', ordenados así:
   primero los agotados, luego los bajos y al final los justos.
   Resultado esperado: 9 filas.
*/
-- Solución:



/* EJERCICIO 16 · Partes de una fecha
   Pedidos hechos un sábado a las 3 de la tarde o después. Mostrar
   id_pedido, la fecha con formato dd/mm/aaaa y la hora con formato
   hh:mm.
   Resultado esperado: 6 filas.
*/
-- Solución:



/* EJERCICIO 17 · Encontrar el error
   Estas tres consultas no hacen lo que dice su comentario. Explicar el
   problema de cada una y escribir la versión correcta.

   a) -- Productos con más de 300.000 de ganancia        (correcta: 14 filas)
      SELECT nombre, precio - costo AS ganancia
      FROM productos
      WHERE ganancia > 300000;

   b) -- Proveedores sin teléfono registrado             (correcta: 1 fila)
      SELECT nombre FROM proveedores WHERE telefono = NULL;

   c) -- Pedidos de julio de 2026                        (correcta: 6 filas)
      SELECT * FROM pedidos
      WHERE fecha_pedido BETWEEN '2026-07-01' AND '2026-07-31'
        AND estado = 'Entregado' OR estado = 'Enviado';
*/
-- Solución:

