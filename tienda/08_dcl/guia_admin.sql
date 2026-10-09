/* =====================================================================
   LABORATORIO 08 · DCL — USUARIOS, PERMISOS Y ROLES
   CREATE USER · GRANT · REVOKE · roles · vistas para restringir
   ---------------------------------------------------------------------
   Objetivo: aplicar el principio de mínimo privilegio. Cada persona de
   la tienda recibe una cuenta que puede hacer SOLO lo que su trabajo
   exige, y se comprueba desde su propia conexión qué logra y qué no.

   Requisito: base tienda recién cargada con 00_preparacion.

   Este archivo se ejecuta como ADMINISTRADOR (root). Después de cada
   paso, la guía indica qué archivo de prueba abrir en OTRA conexión,
   con la cuenta recién configurada:

       prueba_vendedor.sql   →  usuario tienda_vendedor   clave Vende*2026
       prueba_contador.sql   →  usuario tienda_contador   clave Conta*2026
       prueba_bodega.sql     →  usuario tienda_bodega     clave Bodega*2026

   El README del caso explica cómo crear esas conexiones en cada cliente.
   Cada cuenta se llama 'usuario'@'localhost': en MySQL una cuenta es el
   nombre MÁS el equipo desde el que se conecta.
   ===================================================================== */

SET NAMES utf8mb4;
USE tienda;


/* ---------------------------------------------------------------------
   PASO 1 · ¿QUIÉN SOY Y QUIÉN MÁS EXISTE?
   --------------------------------------------------------------------- */

SELECT USER(), CURRENT_USER();
SHOW GRANTS;                                  -- los permisos de la cuenta actual

SELECT user, host, account_locked FROM mysql.user ORDER BY user;

-- PREGUNTA 1.1: ¿Qué permisos tiene root? ¿Sobre qué objetos (qué
--               significa ON *.*)?
-- PREGUNTA 1.2: ¿Por qué la aplicación de la tienda NO debería
--               conectarse como root?


/* ---------------------------------------------------------------------
   PASO 2 · CREAR CUENTAS
   --------------------------------------------------------------------- */

-- Por si la guía se ejecuta por segunda vez
DROP USER IF EXISTS 'tienda_vendedor'@'localhost', 'tienda_contador'@'localhost',
                    'tienda_bodega'@'localhost';
DROP ROLE IF EXISTS 'rol_bodega';

CREATE USER 'tienda_vendedor'@'localhost' IDENTIFIED BY 'Vende*2026';
CREATE USER 'tienda_contador'@'localhost' IDENTIFIED BY 'Conta*2026';

SHOW GRANTS FOR 'tienda_vendedor'@'localhost';

-- 2a. Crear una cuenta que ya existe → ERROR 1396 esperado
CREATE USER 'tienda_vendedor'@'localhost' IDENTIFIED BY 'otra';

-- OBSERVAR: una cuenta nueva solo tiene USAGE: puede conectarse y nada más.
--
-- >>> PRUEBA: abrir prueba_vendedor.sql como tienda_vendedor y ejecutar
--     la PARTE 1. Luego volver aquí.
--
-- PREGUNTA 2.1: ¿Qué significa el permiso USAGE?
-- PREGUNTA 2.2: ¿Qué puede ver y hacer tienda_vendedor en este momento?


/* ---------------------------------------------------------------------
   PASO 3 · GRANT SOBRE TABLAS, COLUMNAS Y VISTAS
   Un vendedor necesita: consultar el catálogo, registrar clientes y
   pedidos, y corregir los datos de contacto de un cliente. No necesita
   ver cuánto le cuesta cada producto a la tienda ni los salarios.
   --------------------------------------------------------------------- */

-- 3a. Permisos sobre tablas completas
GRANT SELECT          ON tienda.categorias     TO 'tienda_vendedor'@'localhost';
GRANT SELECT          ON tienda.sucursales     TO 'tienda_vendedor'@'localhost';
GRANT SELECT, INSERT  ON tienda.clientes       TO 'tienda_vendedor'@'localhost';
GRANT SELECT, INSERT  ON tienda.pedidos        TO 'tienda_vendedor'@'localhost';
GRANT SELECT, INSERT  ON tienda.detalle_pedido TO 'tienda_vendedor'@'localhost';

-- 3b. Permiso sobre ALGUNAS columnas: de un cliente solo puede cambiar
--     los datos de contacto, no el nombre ni el documento
GRANT UPDATE (email, telefono, ciudad) ON tienda.clientes TO 'tienda_vendedor'@'localhost';

-- 3c. Una vista como filtro: el catálogo sin la columna costo y sin los
--     productos inactivos. El vendedor recibe permiso sobre la VISTA,
--     no sobre la tabla productos.
CREATE OR REPLACE VIEW v_catalogo AS
SELECT p.id_producto, p.sku, p.nombre, c.nombre AS categoria, p.precio, p.stock
FROM productos p
JOIN categorias c ON c.id_categoria = p.id_categoria
WHERE p.activo;

GRANT SELECT ON tienda.v_catalogo TO 'tienda_vendedor'@'localhost';

SHOW GRANTS FOR 'tienda_vendedor'@'localhost';

-- >>> PRUEBA: en la conexión de tienda_vendedor, ejecutar la PARTE 2
--     de prueba_vendedor.sql. Luego volver aquí.
--
-- PREGUNTA 3.1: ¿Cuántas líneas muestra ahora SHOW GRANTS? ¿Cómo se
--               distingue el permiso por columnas?
-- PREGUNTA 3.2: El vendedor no tiene ningún permiso sobre la tabla
--               productos y aun así ve precios y existencias. ¿Cómo?
-- PREGUNTA 3.3: ¿Qué columnas y qué filas de productos quedan ocultas
--               para el vendedor?


/* ---------------------------------------------------------------------
   PASO 4 · GRANT SOBRE TODA LA BASE
   La contadora consulta todo para sus informes, y además registra y
   corrige pagos. No modifica nada más.
   --------------------------------------------------------------------- */

GRANT SELECT         ON tienda.*     TO 'tienda_contador'@'localhost';     -- todas las tablas y vistas
GRANT INSERT, UPDATE ON tienda.pagos TO 'tienda_contador'@'localhost';

SHOW GRANTS FOR 'tienda_contador'@'localhost';

-- 4a. Otorgar un permiso sobre algo que no existe → ERROR 1146 esperado
GRANT SELECT ON tienda.facturas TO 'tienda_contador'@'localhost';

-- >>> PRUEBA: abrir prueba_contador.sql como tienda_contador y ejecutar
--     la PARTE 1. Luego volver aquí.
--
-- PREGUNTA 4.1: ¿Qué diferencia hay entre ON tienda.* , ON tienda.pagos
--               y ON *.* ?
-- PREGUNTA 4.2: Si mañana se crea una tabla nueva en tienda, ¿la
--               contadora podrá consultarla sin un GRANT adicional? ¿Y
--               el vendedor?


/* ---------------------------------------------------------------------
   PASO 5 · REVOKE: RETIRAR PERMISOS
   La gerencia decide que solo el personal administrativo registra
   clientes nuevos.
   --------------------------------------------------------------------- */

REVOKE INSERT ON tienda.clientes FROM 'tienda_vendedor'@'localhost';

SHOW GRANTS FOR 'tienda_vendedor'@'localhost';

-- 5a. Retirar un permiso sobre una tabla en la que la cuenta no tiene
--     ninguno → ERROR 1147 esperado
REVOKE SELECT ON tienda.empleados FROM 'tienda_vendedor'@'localhost';

-- >>> PRUEBA: en la conexión de tienda_vendedor (sin cerrarla), ejecutar
--     la PARTE 3 de prueba_vendedor.sql. Luego volver aquí.
--
-- PREGUNTA 5.1: Después del REVOKE, ¿qué permisos conserva el vendedor
--               sobre clientes?
-- PREGUNTA 5.2: ¿El vendedor tuvo que reconectarse para que el REVOKE
--               tuviera efecto?


/* ---------------------------------------------------------------------
   PASO 6 · ROLES: PERMISOS PARA UN CARGO, NO PARA UNA PERSONA
   Si mañana entran tres bodegueros, no se repiten los GRANT tres
   veces: se crea un rol con los permisos del cargo y se asigna el rol.
   --------------------------------------------------------------------- */

CREATE ROLE 'rol_bodega';

GRANT SELECT ON tienda.productos   TO 'rol_bodega';
GRANT SELECT ON tienda.categorias  TO 'rol_bodega';
GRANT SELECT ON tienda.proveedores TO 'rol_bodega';
GRANT UPDATE (stock, stock_minimo) ON tienda.productos TO 'rol_bodega';

CREATE USER 'tienda_bodega'@'localhost' IDENTIFIED BY 'Bodega*2026';
GRANT 'rol_bodega' TO 'tienda_bodega'@'localhost';

SHOW GRANTS FOR 'tienda_bodega'@'localhost';
SHOW GRANTS FOR 'tienda_bodega'@'localhost' USING 'rol_bodega';

-- >>> PRUEBA: abrir prueba_bodega.sql como tienda_bodega y ejecutar la
--     PARTE 1. Luego volver aquí.

-- 6a. Tener un rol asignado no es tenerlo ACTIVO. Para que se active
--     solo al conectarse, se define como rol por defecto:
SET DEFAULT ROLE 'rol_bodega' TO 'tienda_bodega'@'localhost';

-- >>> PRUEBA: CERRAR la conexión de tienda_bodega, abrirla de nuevo y
--     ejecutar la PARTE 2 de prueba_bodega.sql. Luego volver aquí.

-- 6b. Un cambio en el rol llega a todos los que lo tienen
GRANT SELECT ON tienda.sucursales TO 'rol_bodega';

-- PREGUNTA 6.1: Comparar los dos SHOW GRANTS. ¿Qué muestra cada uno?
-- PREGUNTA 6.2: ¿Por qué la PARTE 1 de la prueba falló aunque el rol ya
--               estaba asignado?
-- PREGUNTA 6.3: Si se contrata un segundo bodeguero, ¿cuántas
--               instrucciones hacen falta para dejarlo con los mismos
--               permisos?


/* ---------------------------------------------------------------------
   PASO 7 · WITH GRANT OPTION: PERMISO PARA DAR PERMISOS
   --------------------------------------------------------------------- */

-- La contadora podrá compartir la consulta de envíos con quien la necesite
GRANT SELECT ON tienda.envios TO 'tienda_contador'@'localhost' WITH GRANT OPTION;

SHOW GRANTS FOR 'tienda_contador'@'localhost';

-- >>> PRUEBA: en la conexión de tienda_contador, ejecutar la PARTE 2 de
--     prueba_contador.sql. Luego volver aquí.

SHOW GRANTS FOR 'tienda_vendedor'@'localhost';       -- ¿apareció un permiso nuevo?

-- PREGUNTA 7.1: ¿Quién le dio al vendedor el permiso sobre envios?
-- PREGUNTA 7.2: ¿Qué riesgo tiene repartir WITH GRANT OPTION?


/* ---------------------------------------------------------------------
   PASO 8 · ADMINISTRAR CUENTAS
   --------------------------------------------------------------------- */

-- 8a. Cambiar una clave
ALTER USER 'tienda_vendedor'@'localhost' IDENTIFIED BY 'NuevaClave*2026';

-- 8b. Bloquear una cuenta sin borrarla (por ejemplo, durante vacaciones)
ALTER USER 'tienda_bodega'@'localhost' ACCOUNT LOCK;
SELECT user, host, account_locked FROM mysql.user WHERE user LIKE 'tienda%';

-- >>> PRUEBA: intentar una conexión NUEVA como tienda_bodega (debe ser
--     rechazada con el error 3118) y una conexión nueva como
--     tienda_vendedor con la clave anterior (error 1045) y con la nueva.

ALTER USER 'tienda_bodega'@'localhost' ACCOUNT UNLOCK;

-- 8c. Una clave demasiado simple. Si el servidor tiene activa la
--     política de contraseñas la rechaza; en la instalación del curso
--     no está activa y la acepta.
SHOW VARIABLES LIKE 'validate_password%';

-- PREGUNTA 8.1: ¿Qué ventaja tiene bloquear una cuenta frente a
--               eliminarla?
-- PREGUNTA 8.2: Las sesiones que ya estaban abiertas con la clave
--               anterior, ¿se cerraron al cambiarla?


/* ---------------------------------------------------------------------
   PASO 9 · AUDITAR: ¿QUIÉN PUEDE HACER QUÉ?
   Los permisos también son datos y se consultan con SELECT.
   --------------------------------------------------------------------- */

-- Permisos a nivel de base de datos
SELECT grantee, table_schema, privilege_type, is_grantable
FROM information_schema.schema_privileges
WHERE table_schema = 'tienda';

-- Permisos a nivel de tabla
SELECT grantee, table_name, privilege_type, is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'tienda'
ORDER BY grantee, table_name, privilege_type;

-- Permisos a nivel de columna
SELECT grantee, table_name, column_name, privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'tienda'
ORDER BY grantee, table_name, column_name;

-- Roles asignados
SELECT from_user AS rol, to_user AS usuario FROM mysql.role_edges;

-- PREGUNTA 9.1: Con estas consultas, llenar en el cuaderno la matriz de
--               permisos (S = SELECT, I = INSERT, U = UPDATE, D = DELETE):
--               | Tabla          | vendedor | contador | bodega |
--               | clientes       |          |          |        |
--               | productos      |          |          |        |
--               | pedidos        |          |          |        |
--               | detalle_pedido |          |          |        |
--               | pagos          |          |          |        |
--               | envios         |          |          |        |
--               | empleados      |          |          |        |
-- PREGUNTA 9.2: ¿Alguna cuenta puede ejecutar DELETE sobre alguna
--               tabla? ¿Es una buena decisión? ¿Por qué?


/* ---------------------------------------------------------------------
   PASO 10 · LIMPIEZA
   Se ejecuta al terminar el laboratorio (y los ejercicios).
   --------------------------------------------------------------------- */

DROP USER IF EXISTS 'tienda_vendedor'@'localhost', 'tienda_contador'@'localhost',
                    'tienda_bodega'@'localhost';
DROP ROLE IF EXISTS 'rol_bodega';
DROP VIEW IF EXISTS v_catalogo;

SELECT user, host FROM mysql.user ORDER BY user;

-- PREGUNTA 10.1: Al eliminar una cuenta, ¿qué pasa con sus permisos?
--                ¿Y con los datos que insertó en las tablas?
