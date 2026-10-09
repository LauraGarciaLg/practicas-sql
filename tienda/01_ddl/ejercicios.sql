/* =====================================================================
   LABORATORIO 01 · EJERCICIOS — DDL
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion
   (01_esquema.sql y luego 02_datos.sql).

   La tienda va a crecer: cupones de descuento, reseñas de productos y
   devoluciones. Cada estudiante escribe su solución debajo del
   enunciado, la ejecuta y verifica el resultado con DESCRIBE o
   SHOW CREATE TABLE. Todas las restricciones llevan nombre propio
   (uq_…, chk_…, fk_…).
   ===================================================================== */

USE tienda;


/* EJERCICIO 1 · CREATE TABLE con restricciones
   Crear la tabla cupones:
     - id_cupon      clave primaria autoincremental
     - codigo        texto de hasta 20 caracteres, obligatorio y único
     - porcentaje    decimal; solo admite valores entre 0.01 y 0.50
     - fecha_inicio  fecha obligatoria
     - fecha_fin     fecha obligatoria; no puede ser anterior a fecha_inicio
     - activo        booleano, verdadero por defecto
*/
-- Solución:



/* EJERCICIO 2 · Claves foráneas y UNIQUE compuesto
   Crear la tabla resenas (reseñas de productos):
     - id_resena     clave primaria autoincremental
     - id_producto   obligatorio, clave foránea hacia productos
     - id_cliente    obligatorio, clave foránea hacia clientes
     - calificacion  entero pequeño entre 1 y 5
     - comentario    texto opcional de hasta 300 caracteres
     - fecha         fecha y hora; por defecto, el momento de la inserción
   Regla del negocio: un cliente puede reseñar cada producto UNA sola vez.
*/
-- Solución:



/* EJERCICIO 3 · Clave foránea compuesta
   Crear la tabla devoluciones. Solo se puede devolver un producto que
   realmente esté en el pedido, así que la clave foránea apunta a la
   clave primaria COMPUESTA de detalle_pedido.
     - id_devolucion  clave primaria autoincremental
     - id_pedido, id_producto   obligatorios; juntos son clave foránea
                                hacia detalle_pedido
     - cantidad       entero mayor que cero
     - motivo         solo 'Defectuoso', 'Equivocado' o 'Desistimiento'
     - fecha          fecha; por defecto, la fecha actual
   Después, comprobar la clave foránea con dos INSERT: uno que funcione
   (el pedido 1 incluye el producto 20) y uno que falle (el pedido 1 no
   incluye el producto 1). Anotar el código de error.
*/
-- Solución:



/* EJERCICIO 4 · ADD COLUMN
   a) Agregar a clientes la columna fecha_nacimiento (fecha, opcional),
      ubicada justo después de nombre.
   b) Agregar a clientes la columna puntos (entero, obligatorio, 0 por
      defecto) con una restricción que impida valores negativos.
   c) Consultar tres clientes y explicar qué valor recibió cada columna
      nueva en las filas que ya existían.
*/
-- Solución:



/* EJERCICIO 5 · Clave foránea con ON DELETE
   a) Agregar a pedidos la columna id_cupon (opcional) con clave foránea
      hacia cupones, de modo que si se elimina un cupón los pedidos que
      lo usaron queden con id_cupon en NULL.
   b) Comprobarlo: insertar un cupón, asignarlo al pedido 160, eliminar
      el cupón y consultar el pedido 160.
*/
-- Solución:



/* EJERCICIO 6 · MODIFY, CHANGE y RENAME
   a) Ampliar proveedores.nombre a 120 caracteres (sigue siendo
      obligatorio).
   b) Renombrar clientes.telefono a celular.
   c) Cambiar empleados.cargo para que solo admita 'Gerente',
      'Administrador', 'Vendedor', 'Bodeguero' o 'Contador'.
   d) Intentar reducir clientes.ciudad a 5 caracteres. Anotar el error y
      explicar qué lo causa.
*/
-- Solución:



/* EJERCICIO 7 · Restricciones sobre datos existentes
   a) Intentar agregar a productos un CHECK que exija stock >= stock_minimo.
      Anotar el error.
   b) Escribir la consulta que muestra los productos que impiden crear
      esa restricción. ¿Cuántos son?
   c) Agregar a clientes una restricción UNIQUE sobre email. Varios
      clientes tienen el email en NULL: explicar por qué la restricción
      se crea de todos modos.
*/
-- Solución:



/* EJERCICIO 8 · Índices
   a) Crear un índice sobre clientes(ciudad).
   b) Crear un índice compuesto sobre pedidos(estado, fecha_pedido).
   c) Mostrar los índices de pedidos y explicar de dónde salió cada uno.
   d) Con EXPLAIN, comprobar si esta consulta usa el índice de a):
        SELECT * FROM clientes WHERE ciudad = 'Ocaña';
   e) Eliminar el índice de a).
*/
-- Solución:



/* EJERCICIO 9 · Copiar, vaciar y eliminar
   a) Crear clientes_respaldo con todos los datos de clientes.
   b) Comparar SHOW CREATE TABLE de clientes y de clientes_respaldo:
      anotar tres cosas que la copia NO conservó.
   c) Vaciar clientes_respaldo con TRUNCATE y luego eliminarla.
   d) Intentar TRUNCATE TABLE pedidos y DROP TABLE proveedores. Anotar
      el código de cada error y qué tabla lo provoca.
*/
-- Solución:



/* EJERCICIO 10 · Reto: deshacer todo
   Escribir, en el orden correcto, las instrucciones DDL que dejan la
   base exactamente como estaba antes del ejercicio 1: sin las tres
   tablas nuevas, sin las columnas y restricciones agregadas y con los
   nombres y tipos originales. No se permite volver a ejecutar
   00_preparacion ni usar DROP DATABASE.
   Pista: el orden importa por las claves foráneas.
*/
-- Solución:



/* EJERCICIO 11 · Reflexión (responder en el cuaderno)
   a) ¿Por qué conviene corregir los datos ANTES de agregar una
      restricción, y no al revés?
   b) En una base en producción con millones de filas, ¿qué riesgos
      tiene ejecutar un ALTER TABLE en horario de atención?
*/
