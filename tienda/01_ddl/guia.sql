/* =====================================================================
   LABORATORIO 01 · DDL — CONSTRUIR Y TRANSFORMAR LA ESTRUCTURA
   CREATE · ALTER · RENAME · TRUNCATE · DROP
   ---------------------------------------------------------------------
   Objetivo: construir desde cero la base de la tienda y modificarla
   como ocurre en un proyecto real: el primer diseño nunca es el
   definitivo. Se agregan, cambian y eliminan columnas, restricciones,
   índices y tablas, y se observa cómo reacciona el SGBD cuando la
   estructura ya tiene datos.

   Base de datos: tienda (esta guía la crea desde cero; no necesita la
   preparación 00).

   Cómo trabajar:
     - Ejecutar UN bloque a la vez, nunca la guía completa.
     - Después de cada bloque, leer "OBSERVAR" y responder las
       "PREGUNTAS" en el cuaderno.
     - Las instrucciones marcadas "ERROR xxxx esperado" DEBEN fallar:
       se lee el mensaje y se explica la causa.
   ===================================================================== */

SET NAMES utf8mb4;


/* ---------------------------------------------------------------------
   PASO 1 · LA BASE DE DATOS
   --------------------------------------------------------------------- */

DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SHOW DATABASES;
SHOW CREATE DATABASE tienda;
USE tienda;
SELECT DATABASE();            -- ¿sobre qué base se está trabajando?

-- 1a. Crear una base que ya existe  → ERROR 1007 esperado
CREATE DATABASE tienda;

-- 1b. Con IF NOT EXISTS no hay error, solo una advertencia
CREATE DATABASE IF NOT EXISTS tienda;
SHOW WARNINGS;

-- PREGUNTA 1.1: ¿Para qué sirven IF EXISTS e IF NOT EXISTS en un script
--               que se va a ejecutar muchas veces?
-- PREGUNTA 1.2: ¿Qué pasaría con las tildes y la ñ si la base se creara
--               con el juego de caracteres latin1 o ascii?


/* ---------------------------------------------------------------------
   PASO 2 · PRIMERA VERSIÓN DE LAS TABLAS
   Se empieza con un diseño mínimo, a propósito incompleto. Los pasos
   siguientes lo corrigen con ALTER TABLE.
   --------------------------------------------------------------------- */

CREATE TABLE categorias (
    id_categoria  INT          PRIMARY KEY AUTO_INCREMENT,
    nombre        VARCHAR(50)  NOT NULL
);

CREATE TABLE proveedores (
    id_proveedor  INT          PRIMARY KEY AUTO_INCREMENT,
    nit           VARCHAR(15)  NOT NULL,
    nombre        VARCHAR(80)  NOT NULL,
    ciudad        VARCHAR(40)  NOT NULL
);

SHOW TABLES;
DESCRIBE proveedores;
SHOW CREATE TABLE proveedores;

-- 2a. Una tabla con clave foránea hacia una tabla que todavía no existe
--     → ERROR 1824 esperado
CREATE TABLE pedidos (
    id_pedido   INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente  INT NOT NULL,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- 2b. productos sí puede crearse: categorias ya existe
CREATE TABLE productos (
    id_producto   INT          PRIMARY KEY AUTO_INCREMENT,
    nombre        VARCHAR(30)  NOT NULL,
    valor         INT          NOT NULL,
    id_categoria  INT          NOT NULL,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
);

DESCRIBE productos;

-- OBSERVAR: en DESCRIBE, la columna Key muestra PRI (clave primaria),
--           UNI (única) o MUL (índice que admite repetidos, como el de
--           una clave foránea).
-- PREGUNTA 2.1: ¿Por qué falló 2a? ¿En qué orden deben crearse las
--               tablas de una base con claves foráneas?
-- PREGUNTA 2.2: ¿Qué diferencia hay entre lo que muestra DESCRIBE y lo
--               que muestra SHOW CREATE TABLE?

-- Unos pocos datos de prueba, para ver cómo se comporta ALTER TABLE
-- cuando la tabla ya tiene filas.
INSERT INTO categorias (nombre) VALUES ('Portátiles'), ('Smartphones'), ('Audífonos');

INSERT INTO proveedores (nit, nombre, ciudad) VALUES
    ('900123001-1', 'Distribuciones TecnoAndina S.A.S.', 'Bogotá'),
    ('900123006-6', 'Celumóvil Colombia',                'Bogotá');

INSERT INTO productos (nombre, valor, id_categoria) VALUES
    ('Portátil 14" Core i5',          2450000, 1),
    ('Smartphone 6.5" 128GB',          890000, 2),
    ('Audífonos de diadema Bluetooth', 189000, 3);


/* ---------------------------------------------------------------------
   PASO 3 · ALTER TABLE … ADD COLUMN
   --------------------------------------------------------------------- */

-- 3a. Una columna al final
ALTER TABLE proveedores ADD COLUMN telefono VARCHAR(15);

-- 3b. Varias columnas en una sola instrucción, eligiendo la posición
ALTER TABLE productos
    ADD COLUMN sku    VARCHAR(12)   AFTER id_producto,
    ADD COLUMN costo  DECIMAL(12,2) AFTER nombre,
    ADD COLUMN stock  INT NOT NULL DEFAULT 0;

DESCRIBE productos;
SELECT * FROM productos;

-- 3c. Una columna NOT NULL sin DEFAULT sobre una tabla que ya tiene filas
ALTER TABLE productos ADD COLUMN stock_minimo INT NOT NULL;
SELECT id_producto, nombre, sku, costo, stock, stock_minimo FROM productos;

-- OBSERVAR: las filas que ya existían tuvieron que recibir algún valor
--           en las columnas nuevas.
-- PREGUNTA 3.1: ¿Qué valor quedó en sku y en costo? ¿Y en stock?
-- PREGUNTA 3.2: En 3c la columna es NOT NULL y no tiene DEFAULT. ¿Qué
--               valor puso MySQL en las filas existentes? ¿Es un dato
--               real o inventado? ¿Qué riesgo tiene eso?


/* ---------------------------------------------------------------------
   PASO 4 · ALTER TABLE … MODIFY / CHANGE / RENAME COLUMN
   --------------------------------------------------------------------- */

-- 4a. Ampliar una columna: siempre es seguro
ALTER TABLE productos MODIFY COLUMN nombre VARCHAR(100) NOT NULL;

-- 4b. Reducirla por debajo de lo que ya hay guardado → ERROR 1406 esperado
ALTER TABLE productos MODIFY COLUMN nombre VARCHAR(10) NOT NULL;

-- 4c. Renombrar una columna (conserva tipo y restricciones)
ALTER TABLE productos RENAME COLUMN valor TO precio;

-- 4d. CHANGE renombra y redefine a la vez: hay que escribir el tipo completo
ALTER TABLE productos CHANGE COLUMN precio precio DECIMAL(12,2) NOT NULL;

-- 4e. La trampa de MODIFY: se redefine la columna COMPLETA.
--     Aquí se quiere solo cambiar el DEFAULT de stock…
ALTER TABLE productos MODIFY COLUMN stock INT DEFAULT 10;
DESCRIBE productos;
-- …y stock dejó de ser NOT NULL, porque no se volvió a escribir.
ALTER TABLE productos MODIFY COLUMN stock INT NOT NULL DEFAULT 0;

-- 4f. Para tocar solo el valor por defecto existe ALTER COLUMN
ALTER TABLE productos ALTER COLUMN stock_minimo SET DEFAULT 5;
ALTER TABLE productos ALTER COLUMN stock_minimo DROP DEFAULT;

-- 4g. Convertir un texto que no es número → ERROR 1366 esperado
ALTER TABLE proveedores MODIFY COLUMN ciudad INT;

DESCRIBE productos;

-- PREGUNTA 4.1: ¿Por qué falló 4b y no 4a? ¿Qué tendría que pasar con
--               los datos para que 4b funcionara?
-- PREGUNTA 4.2: ¿Qué diferencia hay entre MODIFY COLUMN, CHANGE COLUMN,
--               RENAME COLUMN y ALTER COLUMN?
-- PREGUNTA 4.3: ¿Por qué el precio se cambió de INT a DECIMAL(12,2) y no
--               a FLOAT?


/* ---------------------------------------------------------------------
   PASO 5 · AGREGAR RESTRICCIONES A TABLAS CON DATOS
   El SGBD revisa las filas que ya existen: si alguna incumple la regla
   nueva, la restricción no se crea.
   --------------------------------------------------------------------- */

-- 5a. UNIQUE sobre el NIT
ALTER TABLE proveedores ADD CONSTRAINT uq_proveedor_nit UNIQUE (nit);

-- 5b. El sku debe ser obligatorio, pero las filas actuales lo tienen
--     en NULL → ERROR 1138 esperado
ALTER TABLE productos MODIFY COLUMN sku VARCHAR(12) NOT NULL;

-- Primero se corrigen los datos; después se cambia la estructura.
UPDATE productos SET sku = 'PORT-001', costo = 1850000, stock_minimo = 4 WHERE id_producto = 1;
UPDATE productos SET sku = 'CEL-001',  costo =  620000, stock_minimo = 8 WHERE id_producto = 2;
UPDATE productos SET sku = 'AUD-002',  costo =  110000, stock_minimo = 8 WHERE id_producto = 3;

ALTER TABLE productos
    MODIFY COLUMN sku   VARCHAR(12)   NOT NULL,
    MODIFY COLUMN costo DECIMAL(12,2) NOT NULL,
    ADD CONSTRAINT uq_producto_sku UNIQUE (sku);

-- 5c. CHECK que los datos actuales NO cumplen → ERROR 3819 esperado
ALTER TABLE productos ADD CONSTRAINT chk_producto_stock CHECK (stock > 0);

-- 5d. CHECK bien planteados
ALTER TABLE productos
    ADD CONSTRAINT chk_producto_stock  CHECK (stock >= 0),
    ADD CONSTRAINT chk_producto_costo  CHECK (costo > 0),
    ADD CONSTRAINT chk_producto_precio CHECK (precio >= costo);

-- 5e. La restricción ya protege la tabla → ERROR 3819 esperado
UPDATE productos SET precio = 100 WHERE id_producto = 1;

-- 5f. Clave foránea nueva: productos → proveedores
ALTER TABLE productos ADD COLUMN id_proveedor INT AFTER id_categoria;
UPDATE productos SET id_proveedor = 99 WHERE id_producto = 3;      -- un proveedor que no existe

--     Con ese dato huérfano la clave foránea no se puede crear
--     → ERROR 1452 esperado
ALTER TABLE productos ADD CONSTRAINT fk_producto_proveedor
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor);

UPDATE productos SET id_proveedor = NULL WHERE id_producto = 3;
UPDATE productos SET id_proveedor = 1    WHERE id_producto = 1;
UPDATE productos SET id_proveedor = 2    WHERE id_producto = 2;

ALTER TABLE productos ADD CONSTRAINT fk_producto_proveedor
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor);

SHOW CREATE TABLE productos;

-- PREGUNTA 5.1: Completar en el cuaderno: instrucción | ¿pasó? |
--               código de error | causa (para 5b, 5c, 5e y el primer
--               intento de 5f).
-- PREGUNTA 5.2: ¿Por qué el producto 3 puede quedar con id_proveedor en
--               NULL sin violar la clave foránea?
-- PREGUNTA 5.3: ¿Qué ventaja tiene ponerle nombre a cada restricción
--               (uq_…, chk_…, fk_…) en lugar de dejar que MySQL lo elija?


/* ---------------------------------------------------------------------
   PASO 6 · UNA TABLA QUE SE REFERENCIA A SÍ MISMA
   Una categoría puede pertenecer a otra: Portátiles → Computadores.
   --------------------------------------------------------------------- */

ALTER TABLE categorias
    ADD COLUMN id_categoria_padre INT,
    ADD CONSTRAINT uq_categoria_nombre UNIQUE (nombre),
    ADD CONSTRAINT fk_categoria_padre FOREIGN KEY (id_categoria_padre)
        REFERENCES categorias(id_categoria);

INSERT INTO categorias (nombre) VALUES ('Computadores');             -- quedará con id 4
UPDATE categorias SET id_categoria_padre = 4 WHERE id_categoria = 1;
SELECT * FROM categorias;

-- 6a. Padre inexistente → ERROR 1452 esperado
UPDATE categorias SET id_categoria_padre = 50 WHERE id_categoria = 2;

-- PREGUNTA 6.1: ¿Qué significa que id_categoria_padre esté en NULL?
-- PREGUNTA 6.2: ¿Podría resolverse lo mismo con dos tablas (categorias
--               y subcategorias)? ¿Qué se gana con una sola?


/* ---------------------------------------------------------------------
   PASO 7 · ÍNDICES
   --------------------------------------------------------------------- */

SHOW INDEX FROM productos;

-- Las búsquedas por nombre de producto serán frecuentes
CREATE INDEX idx_producto_nombre ON productos (nombre);
SHOW INDEX FROM productos;

-- EXPLAIN muestra el plan de ejecución: qué índice usa la consulta
EXPLAIN SELECT * FROM productos WHERE nombre = 'Smartphone 6.5" 128GB';
EXPLAIN SELECT * FROM productos WHERE stock = 0;

DROP INDEX idx_producto_nombre ON productos;

-- OBSERVAR: PRIMARY KEY, UNIQUE y FOREIGN KEY crearon índices sin que
--           nadie lo pidiera.
-- PREGUNTA 7.1: ¿Cuántos índices tenía productos antes del CREATE INDEX
--               y de dónde salió cada uno?
-- PREGUNTA 7.2: En los dos EXPLAIN, ¿qué aparece en las columnas "type"
--               y "key"? ¿Cuál de las dos consultas recorre la tabla
--               completa?
-- PREGUNTA 7.3: Si los índices aceleran las consultas, ¿por qué no se
--               crea un índice sobre cada columna?


/* ---------------------------------------------------------------------
   PASO 8 · QUITAR COLUMNAS Y RESTRICCIONES
   --------------------------------------------------------------------- */

-- 8a. Quitar una columna: se pierden también sus datos
ALTER TABLE proveedores DROP COLUMN telefono;

-- 8b. Quitar una columna que sostiene una clave foránea
--     → ERROR 1828 esperado
ALTER TABLE productos DROP COLUMN id_proveedor;

-- 8c. Orden correcto: primero la restricción, después la columna
ALTER TABLE productos DROP FOREIGN KEY fk_producto_proveedor;
ALTER TABLE productos DROP COLUMN id_proveedor;

-- 8d. Quitar un CHECK y un UNIQUE
ALTER TABLE productos DROP CHECK chk_producto_precio;
ALTER TABLE proveedores DROP INDEX uq_proveedor_nit;      -- un UNIQUE es un índice

-- 8e. Sin el UNIQUE, el NIT repetido entra sin problema
INSERT INTO proveedores (nit, nombre, ciudad) VALUES ('900123001-1', 'Proveedor duplicado', 'Cali');
SELECT * FROM proveedores;

--     …y ahora el UNIQUE ya no se puede volver a crear → ERROR 1062 esperado
ALTER TABLE proveedores ADD CONSTRAINT uq_proveedor_nit UNIQUE (nit);

-- PREGUNTA 8.1: ¿Se puede recuperar el contenido de la columna telefono
--               después de 8a?
-- PREGUNTA 8.2: ¿Qué enseña 8e sobre quitar restricciones "un momento"
--               en una base que está en uso?


/* ---------------------------------------------------------------------
   PASO 9 · COPIAR, RENOMBRAR, VACIAR Y ELIMINAR TABLAS
   --------------------------------------------------------------------- */

-- 9a. Copia de la ESTRUCTURA (columnas, índices), sin filas
CREATE TABLE productos_plantilla LIKE productos;

-- 9b. Copia de los DATOS a partir de una consulta
CREATE TABLE productos_respaldo AS SELECT * FROM productos;

SHOW CREATE TABLE productos_plantilla;
SHOW CREATE TABLE productos_respaldo;
SELECT * FROM productos_respaldo;

-- 9c. Renombrar una tabla
RENAME TABLE productos_respaldo TO productos_copia;
SHOW TABLES;

-- 9d. TRUNCATE: vacía la tabla y la deja como recién creada
TRUNCATE TABLE productos_copia;
SELECT COUNT(*) FROM productos_copia;

-- 9e. Eliminar una tabla a la que otra apunta → ERROR 3730 esperado
DROP TABLE categorias;

-- 9f. Vaciar una tabla a la que otra apunta   → ERROR 1701 esperado
TRUNCATE TABLE categorias;

-- 9g. Eliminar tablas que nadie referencia
DROP TABLE productos_copia, productos_plantilla;

-- 9h. Eliminar una tabla que no existe → ERROR 1051 esperado
DROP TABLE productos_copia;
DROP TABLE IF EXISTS productos_copia;         -- sin error

-- PREGUNTA 9.1: Comparar los dos SHOW CREATE TABLE. ¿Cuál de las copias
--               conservó la clave primaria, el AUTO_INCREMENT y los
--               índices? ¿Alguna conservó las claves foráneas?
-- PREGUNTA 9.2: ¿En qué orden habría que eliminar categorias,
--               proveedores y productos? Compararlo con el orden en que
--               se crearon.
-- PREGUNTA 9.3: Completar en el cuaderno:
--               | Instrucción | ¿Borra filas? | ¿Borra estructura? |
--               | DELETE      |               |                    |
--               | TRUNCATE    |               |                    |
--               | DROP        |               |                    |


/* ---------------------------------------------------------------------
   PASO 10 · EL CATÁLOGO: LA BASE DE DATOS QUE DESCRIBE A LAS DEMÁS
   Todo lo creado con DDL queda registrado en information_schema y se
   consulta con SELECT, como cualquier tabla.
   --------------------------------------------------------------------- */

SELECT table_name, table_rows, create_time
FROM information_schema.tables
WHERE table_schema = 'tienda';

SELECT table_name, column_name, column_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'tienda'
ORDER BY table_name, ordinal_position;

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'tienda'
ORDER BY table_name, constraint_type;

-- PREGUNTA 10.1: ¿Cuántas restricciones tiene cada tabla y de qué tipo?
-- PREGUNTA 10.2: ¿Qué restricciones de las creadas en el PASO 5 ya no
--                aparecen? ¿En qué paso se eliminó cada una?


/* ---------------------------------------------------------------------
   PASO 11 · CIERRE
   ---------------------------------------------------------------------
   Lo construido hasta aquí es un borrador de tres tablas. La versión
   completa de la base (10 tablas, con todas sus restricciones y cientos
   de filas) está en la carpeta 00_preparacion.

     1. Abrir ../00_preparacion/01_esquema.sql y leerlo completo: todas
        las instrucciones son DDL y ya se conocen.
     2. Ejecutar 01_esquema.sql y después 02_datos.sql.
     3. Resolver ejercicios.sql sobre esa base.

   PREGUNTA 11.1: En 01_esquema.sql, ¿qué tablas se crean primero y por
                  qué? ¿Cuál es la última y de cuáles depende?
   PREGUNTA 11.2: ¿Qué instrucción DDL de la tabla de 9.3 puede
                  deshacerse con ROLLBACK? (Se comprobará en el
                  laboratorio 07.)
   --------------------------------------------------------------------- */
