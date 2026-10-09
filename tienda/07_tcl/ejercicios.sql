/* =====================================================================
   LABORATORIO 07 · EJERCICIOS — Transacciones
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.
   Los ejercicios se resuelven EN ORDEN. Cada transacción se escribe
   completa (de START TRANSACTION a COMMIT o ROLLBACK) y se verifica
   con consultas antes y después.
   ===================================================================== */

USE tienda;
SET SQL_SAFE_UPDATES = 0;


/* EJERCICIO 1 · Ensayar un cambio masivo
   Dentro de una transacción, subir 15 % el precio de TODOS los
   productos. Consultar el precio promedio antes del cambio, después
   del cambio y después de deshacerlo.
*/
-- Solución:



/* EJERCICIO 2 · Una venta completa
   Tatiana Cáceres (cliente 28) compra en la sucursal 2, con la
   vendedora 7: 1 unidad del producto 10 y 3 unidades del producto 17
   (estas con 5 % de descuento). Paga por transferencia.
   Registrar la venta como UNA transacción: pedido en estado 'Pagado',
   líneas de detalle con el precio de lista actual, descuento del stock
   y pago por el total exacto. Confirmar y verificar.
*/
-- Solución:



/* EJERCICIO 3 · Una venta que no se puede completar
   El Hotel Brisas del Río (cliente 30) pide 5 unidades del producto 5
   en la sucursal 1, con el vendedor 6. Solo hay 2 en bodega.
   Escribir la transacción igual que en el ejercicio 2, ejecutarla paso
   a paso y, cuando aparezca el error, tomar la decisión correcta.
   Verificar que no quedó NADA de esa venta: ni pedido, ni detalle, ni
   cambio en el stock. Anotar el código del error.
*/
-- Solución:



/* EJERCICIO 4 · Cancelar un pedido y devolver la mercancía
   El pedido 153 está en estado 'Pagado' y el cliente desiste. En una
   sola transacción:
     a) Devolver al stock las unidades de TODAS sus líneas, con un
        único UPDATE (pista: UPDATE con JOIN a detalle_pedido).
     b) Cambiar el estado del pedido a 'Cancelado'.
   Consultar el stock de los productos involucrados antes y después.
   ¿Por qué estas dos operaciones deben ir en la misma transacción?
*/
-- Solución:



/* EJERCICIO 5 · SAVEPOINT
   En una sola transacción:
     a) Insertar el proveedor 'Redes y Cables del Cesar' (NIT
        900123011-1, Valledupar).
     b) Crear el punto de guardado proveedor_listo.
     c) Insertar dos productos de ese proveedor en la categoría 12.
     d) Crear el punto de guardado productos_listos.
     e) Por error, poner en 0 el stock de TODOS los productos.
     f) Deshacer únicamente el error.
     g) Confirmar.
   Verificar que el proveedor y sus dos productos existen y que el
   stock de los demás productos no cambió.
*/
-- Solución:



/* EJERCICIO 6 · Predecir el COMMIT implícito
   Antes de ejecutar, anotar la predicción: al final, ¿existe el envío
   del pedido 155?

     START TRANSACTION;
     DELETE FROM envios WHERE id_pedido = 155;
     ALTER TABLE envios ADD COLUMN observaciones VARCHAR(100);
     ROLLBACK;
     SELECT * FROM envios WHERE id_pedido = 155;

   Ejecutarlo, explicar el resultado y dejar la tabla envios sin la
   columna nueva.
*/
-- Solución:



/* EJERCICIO 7 · Dos sesiones: el abono duplicado
   El pedido 154 está 'Pendiente' y tiene un abono. Dos cajeras, en dos
   conexiones distintas, van a registrar al mismo tiempo el pago del
   saldo, cada una sin saber de la otra.
     a) Calcular el saldo del pedido 154 (total menos lo pagado).
     b) Escribir los pasos de la cajera A y de la cajera B, usando
        SELECT … FOR UPDATE sobre la fila del pedido, de modo que solo
        UNA registre el pago y cambie el estado a 'Pagado', y la otra
        se dé cuenta de que ya no hay nada que cobrar.
     c) Ejecutarlo en dos conexiones y describir qué vio cada cajera.
*/
-- Solución:



/* EJERCICIO 8 · Reflexión (responder en el cuaderno)
   a) Para cada propiedad ACID, citar el ejercicio de esta hoja donde
      se nota con más claridad.
   b) En el ejercicio 7, ¿qué habría pasado sin FOR UPDATE?
   c) Una transacción que queda abierta durante minutos (por ejemplo,
      esperando que el usuario responda en pantalla), ¿qué problema le
      causa a las demás sesiones?
*/
