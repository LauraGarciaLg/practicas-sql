/* =====================================================================
   LABORATORIO 08 · EJERCICIOS — Usuarios, permisos y roles
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion y la
   limpieza de la guía (PASO 10) ejecutada.

   Las soluciones se escriben como administrador (root). Cada permiso se
   COMPRUEBA abriendo una conexión con la cuenta creada: al menos una
   instrucción que deba funcionar y una que deba ser rechazada, anotando
   el código de error.
   ===================================================================== */

USE tienda;


/* EJERCICIO 1 · Cuenta de solo lectura
   Crear la cuenta 'tienda_auditor'@'localhost' con permiso de consultar
   TODA la base tienda y nada más. Mostrar sus permisos.
   Prueba: una consulta con JOIN entre pedidos y clientes (funciona) y
   un UPDATE cualquiera (rechazado).
*/
-- Solución:



/* EJERCICIO 2 · Permisos por tabla
   Crear la cuenta 'tienda_despachos'@'localhost' para quien prepara los
   envíos. Necesita:
     - consultar pedidos, detalle_pedido, clientes y productos;
     - consultar, insertar y actualizar envios;
     - nada sobre pagos, empleados ni proveedores.
*/
-- Solución:



/* EJERCICIO 3 · Permisos por columna
   La cuenta tienda_despachos debe poder cambiar el ESTADO de un pedido
   (a 'Enviado' o 'Entregado'), pero ninguna otra columna de pedidos.
   Prueba: un UPDATE del estado (funciona) y un UPDATE de id_cliente
   (rechazado; anotar el código).
*/
-- Solución:



/* EJERCICIO 4 · Una vista para ocultar columnas y filas
   Recursos humanos quiere publicar un directorio interno SIN salarios
   ni documentos.
     a) Crear la vista v_directorio con: nombre del empleado, cargo,
        nombre de la sucursal, ciudad y nombre del jefe.
     b) Crear la cuenta 'tienda_practicante'@'localhost' con permiso de
        consulta ÚNICAMENTE sobre esa vista.
   Prueba: SELECT sobre la vista (funciona), SELECT sobre empleados
   (rechazado) y SHOW TABLES (¿qué aparece?).
*/
-- Solución:



/* EJERCICIO 5 · Roles
   a) Crear el rol 'rol_ventas' con los permisos que tuvo
      tienda_vendedor en la guía: consultar categorias, sucursales,
      clientes, pedidos y detalle_pedido; insertar en pedidos y
      detalle_pedido; actualizar email, telefono y ciudad de clientes.
   b) Crear las cuentas 'vendedor_natalia'@'localhost' y
      'vendedor_oscar'@'localhost', asignarles el rol y dejarlo como rol
      por defecto.
   c) Agregar al rol el permiso de consultar productos y comprobar que
      las dos cuentas lo reciben sin tocar a ninguna.
*/
-- Solución:



/* EJERCICIO 6 · REVOKE
   a) Retirar a tienda_despachos el permiso de INSERT sobre envios.
   b) Retirar a vendedor_oscar el rol rol_ventas.
   c) Mostrar los permisos de ambas cuentas y explicar qué conserva
      cada una.
*/
-- Solución:



/* EJERCICIO 7 · Administración de cuentas
   a) Cambiar la clave de tienda_auditor.
   b) Bloquear la cuenta tienda_practicante y comprobar el error al
      intentar conectarse. Anotar el código.
   c) Hacer que la clave de vendedor_natalia venza de inmediato
      (ALTER USER … PASSWORD EXPIRE). Conectarse con esa cuenta,
      intentar una consulta y anotar qué exige el servidor.
*/
-- Solución:



/* EJERCICIO 8 · Auditoría
   Con consultas sobre information_schema, responder:
     a) ¿Qué cuentas o roles tienen algún permiso sobre la tabla pedidos
        y cuál es?
     b) ¿Qué permisos por columna existen en la base tienda?
*/
-- Solución:



/* EJERCICIO 9 · Limpieza
   Eliminar todas las cuentas, el rol y la vista creados en estos
   ejercicios. Comprobar en mysql.user que no queda ninguna.
*/
-- Solución:



/* EJERCICIO 10 · Diseño (responder en el cuaderno)
   La tienda va a publicar una página web donde los clientes consultan
   el catálogo y hacen pedidos. La página se conecta a MySQL con UNA
   cuenta.
     a) ¿Qué permisos mínimos debe tener esa cuenta? Indicar tabla o
        vista y operación.
     b) ¿Qué podría hacer un atacante que robe la clave de esa cuenta?
        ¿Y si la página se conectara como root?
     c) ¿Qué tabla NO debería poder leer esa cuenta bajo ninguna
        circunstancia?
*/
