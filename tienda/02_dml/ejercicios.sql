/* =====================================================================
   LABORATORIO 02 · EJERCICIOS — DML
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.
   Los ejercicios se resuelven EN ORDEN: algunos dependen de los
   anteriores. Antes de cada UPDATE o DELETE se escribe el SELECT que
   muestra las filas que se van a modificar.
   ===================================================================== */

USE tienda;
SET SQL_SAFE_UPDATES = 0;


/* EJERCICIO 1 · INSERT con claves generadas
   La sucursal Valledupar Norte (id 4) va a empezar a operar. Insertar:
     a) Un administrador para esa sucursal, cuyo jefe es la gerente (id 1).
     b) Un vendedor para esa sucursal, cuyo jefe es el administrador
        recién insertado. El id del jefe NO se escribe a mano: se obtiene
        con LAST_INSERT_ID().
   Los datos personales son libres. Consultar los empleados de la
   sucursal 4 para verificar.
*/
-- Solución:



/* EJERCICIO 2 · INSERT de varias filas
   a) Insertar la subcategoría 'Tablets', hija de Computadores (id 1).
   b) Con UN solo INSERT, agregar tres tablets a esa categoría. Una de
      ellas sin indicar stock ni stock_minimo, para comprobar los
      valores por defecto.
*/
-- Solución:



/* EJERCICIO 3 · Registrar una venta completa
   Julián Mantilla (cliente 29) compra en la sucursal 3, atendido por el
   vendedor 10: una unidad del producto 11 y dos del producto 22, estas
   últimas con 10 % de descuento. Paga todo con tarjeta.
     a) Insertar el pedido (estado 'Pagado').
     b) Insertar las dos líneas de detalle. El precio_unitario NO se
        escribe a mano: se toma de productos con INSERT … SELECT.
     c) Insertar el pago por el total exacto del pedido.
     d) Descontar del stock las unidades vendidas.
   Verificar con un SELECT sobre cada tabla afectada.
*/
-- Solución:



/* EJERCICIO 4 · CREATE TABLE + INSERT … SELECT
   Bodega necesita la lista de productos por reponer. Crear la tabla
   productos_por_reponer (id_producto, nombre, stock, stock_minimo,
   faltante) y llenarla con los productos activos cuyo stock está por
   debajo del mínimo. "faltante" es la cantidad que hace falta para
   llegar al mínimo.
*/
-- Solución:



/* EJERCICIO 5 · Provocar errores
   Escribir un INSERT o UPDATE que falle por cada una de estas causas y
   anotar el código de error:
     a) Un empleado con salario cero.
     b) Un pago para un pedido que no existe.
     c) Un envío cuya fecha de entrega es anterior a la de envío.
     d) Un segundo envío para un pedido que ya tiene uno.
     e) Una línea de detalle con 80 % de descuento.
     f) Un producto con stock negativo, mediante UPDATE.
*/
-- Solución:



/* EJERCICIO 6 · UPDATE de filas puntuales
   a) Wilmer Carrascal (cliente 10) se mudó a Aguachica y su nuevo
      teléfono es 3105559910.
   b) El pedido 155 llegó a su destino el 12 de septiembre de 2026:
      registrar la fecha de entrega en su envío y cambiar el estado del
      pedido a 'Entregado'.
*/
-- Solución:



/* EJERCICIO 7 · UPDATE con expresiones
   a) Subir 5 % el precio de todos los audífonos (categoría 10),
      redondeado a miles.
   b) Aumentar en 5 unidades el stock_minimo de los productos que
      cuestan menos de 50.000.
   c) Poner en mayúsculas el nombre de todas las transportadoras en la
      tabla envios.
*/
-- Solución:



/* EJERCICIO 8 · UPDATE con CASE
   Nueva política de inventario. Con UN solo UPDATE, fijar el
   stock_minimo de TODOS los productos según su precio:
     - 2.000.000 o más          → 2
     - de 500.000 a 1.999.999   → 4
     - menos de 500.000         → 10
*/
-- Solución:



/* EJERCICIO 9 · UPDATE con JOIN
   Hubo una inundación en Gamarra y no se puede despachar. Cancelar los
   pedidos que están en estado 'Pendiente' de los clientes de esa
   ciudad. ¿Cuántos pedidos cambiaron?
*/
-- Solución:



/* EJERCICIO 10 · UPDATE con subconsulta
   Desactivar (activo = FALSE) los productos que no se vendieron ni una
   sola vez durante 2026. Los pedidos cancelados no cuentan como venta.
   ¿Cuántos productos quedaron inactivos en total?
*/
-- Solución:



/* EJERCICIO 11 · DELETE e integridad referencial
   a) Eliminar el proveedor 8.
   b) Intentar eliminar el proveedor 7. Explicar el error.
   c) Contar las filas de detalle_pedido. Eliminar los pedidos
      cancelados del primer semestre de 2025 y volver a contar.
      ¿Cuántos pedidos se borraron y cuántas líneas de detalle
      desaparecieron con ellos? ¿Por qué?
*/
-- Solución:



/* EJERCICIO 12 · DELETE con subconsulta o JOIN
   Eliminar los clientes que nunca han hecho un pedido. ¿Cuántos se
   borraron? En los datos originales eran más: ¿qué cambió?
*/
-- Solución:



/* EJERCICIO 13 · Eliminar un pedido con todo lo que depende de él
   Eliminar por completo el pedido 155 (tiene detalle, pago y envío).
   Escribir las instrucciones en el orden correcto y explicar por qué
   para una de las tablas hijas no hace falta un DELETE.
*/
-- Solución:



/* EJERCICIO 14 · DELETE, TRUNCATE y DROP
   a) Crear pagos_copia con todos los datos de pagos.
   b) Eliminar de la copia los pagos en efectivo. Anotar las filas
      afectadas.
   c) Vaciar la copia con TRUNCATE. ¿Qué dice el mensaje sobre las filas
      afectadas? ¿En qué se diferencia del mensaje de b)?
   d) Eliminar las tablas pagos_copia y productos_por_reponer.
*/
-- Solución:



/* EJERCICIO 15 · Reflexión (responder en el cuaderno)
   a) En el ejercicio 3 se ejecutaron cuatro instrucciones para una sola
      venta. ¿Qué pasaría con los datos si el servidor se apaga después
      de la segunda? (El laboratorio 07 resuelve este problema.)
   b) ¿Por qué detalle_pedido guarda su propio precio_unitario en vez de
      leer siempre el precio de la tabla productos?
*/
