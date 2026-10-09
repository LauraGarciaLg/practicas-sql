/* =====================================================================
   00 · PREPARACIÓN — 01_esquema.sql
   ---------------------------------------------------------------------
   Crea (o reinicia) la base de datos de la tienda con sus 10 tablas.

   Cuándo ejecutarlo:
     - Antes de cada laboratorio desde el 02 (y antes de los ejercicios
       del 01).
     - Siempre que la base quede dañada o con datos modificados.
   Después de este archivo se ejecuta 02_datos.sql.

   ATENCIÓN: borra la base "tienda" si ya existe.
   ===================================================================== */

SET NAMES utf8mb4;   -- tildes y ñ correctas también desde la consola

DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE tienda;


/* ---------------------------------------------------------------------
   Tablas sin dependencias
   --------------------------------------------------------------------- */

CREATE TABLE sucursales (
    id_sucursal     INT          PRIMARY KEY AUTO_INCREMENT,
    nombre          VARCHAR(50)  NOT NULL,
    ciudad          VARCHAR(40)  NOT NULL,
    direccion       VARCHAR(80),
    fecha_apertura  DATE         NOT NULL,
    CONSTRAINT uq_sucursal_nombre UNIQUE (nombre)
);

CREATE TABLE categorias (
    id_categoria        INT          PRIMARY KEY AUTO_INCREMENT,
    nombre              VARCHAR(50)  NOT NULL,
    id_categoria_padre  INT,                      -- NULL = categoría principal
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre),
    CONSTRAINT fk_categoria_padre FOREIGN KEY (id_categoria_padre)
        REFERENCES categorias(id_categoria)
);

CREATE TABLE proveedores (
    id_proveedor  INT           PRIMARY KEY AUTO_INCREMENT,
    nit           VARCHAR(15)   NOT NULL,
    nombre        VARCHAR(80)   NOT NULL,
    ciudad        VARCHAR(40)   NOT NULL,
    telefono      VARCHAR(15),
    email         VARCHAR(100),
    CONSTRAINT uq_proveedor_nit UNIQUE (nit)
);

CREATE TABLE clientes (
    id_cliente      INT           PRIMARY KEY AUTO_INCREMENT,
    documento       VARCHAR(15)   NOT NULL,
    nombre          VARCHAR(100)  NOT NULL,
    tipo            ENUM('Persona', 'Empresa') NOT NULL DEFAULT 'Persona',
    email           VARCHAR(100),
    telefono        VARCHAR(15),
    ciudad          VARCHAR(40)   NOT NULL,
    fecha_registro  DATE          NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_cliente_documento UNIQUE (documento)
);


/* ---------------------------------------------------------------------
   Tablas que dependen de las anteriores
   --------------------------------------------------------------------- */

CREATE TABLE empleados (
    id_empleado    INT            PRIMARY KEY AUTO_INCREMENT,
    documento      VARCHAR(15)    NOT NULL,
    nombre         VARCHAR(80)    NOT NULL,
    cargo          VARCHAR(30)    NOT NULL,
    salario        DECIMAL(12,2)  NOT NULL,
    fecha_ingreso  DATE           NOT NULL,
    id_sucursal    INT            NOT NULL,
    id_jefe        INT,                           -- NULL = no tiene jefe
    CONSTRAINT uq_empleado_documento UNIQUE (documento),
    CONSTRAINT chk_empleado_salario  CHECK (salario > 0),
    CONSTRAINT fk_empleado_sucursal  FOREIGN KEY (id_sucursal)
        REFERENCES sucursales(id_sucursal),
    CONSTRAINT fk_empleado_jefe      FOREIGN KEY (id_jefe)
        REFERENCES empleados(id_empleado)
);

CREATE TABLE productos (
    id_producto   INT            PRIMARY KEY AUTO_INCREMENT,
    sku           VARCHAR(12)    NOT NULL,
    nombre        VARCHAR(100)   NOT NULL,
    id_categoria  INT            NOT NULL,
    id_proveedor  INT,
    costo         DECIMAL(12,2)  NOT NULL,
    precio        DECIMAL(12,2)  NOT NULL,
    stock         INT            NOT NULL DEFAULT 0,
    stock_minimo  INT            NOT NULL DEFAULT 0,
    activo        BOOLEAN        NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_producto_sku     UNIQUE (sku),
    CONSTRAINT chk_producto_costo  CHECK (costo > 0),
    CONSTRAINT chk_producto_precio CHECK (precio >= costo),
    CONSTRAINT chk_producto_stock  CHECK (stock >= 0),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria),
    CONSTRAINT fk_producto_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedores(id_proveedor)
);

CREATE TABLE pedidos (
    id_pedido     INT       PRIMARY KEY AUTO_INCREMENT,
    id_cliente    INT       NOT NULL,
    id_empleado   INT       NOT NULL,             -- vendedor que lo atendió
    id_sucursal   INT       NOT NULL,
    fecha_pedido  DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado        ENUM('Pendiente', 'Pagado', 'Enviado', 'Entregado', 'Cancelado')
                            NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT fk_pedido_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    CONSTRAINT fk_pedido_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT fk_pedido_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
);

CREATE INDEX idx_pedido_fecha ON pedidos (fecha_pedido);

-- Cada fila es un producto dentro de un pedido. El precio se copia del
-- producto en el momento de la venta: si mañana cambia el precio de
-- lista, los pedidos anteriores conservan el valor con el que se vendió.
CREATE TABLE detalle_pedido (
    id_pedido        INT            NOT NULL,
    id_producto      INT            NOT NULL,
    cantidad         INT            NOT NULL,
    precio_unitario  DECIMAL(12,2)  NOT NULL,
    descuento        DECIMAL(4,2)   NOT NULL DEFAULT 0,   -- 0.10 = 10 %
    PRIMARY KEY (id_pedido, id_producto),
    CONSTRAINT chk_detalle_cantidad  CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio    CHECK (precio_unitario > 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento BETWEEN 0 AND 0.50),
    CONSTRAINT fk_detalle_pedido   FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

CREATE TABLE pagos (
    id_pago     INT            PRIMARY KEY AUTO_INCREMENT,
    id_pedido   INT            NOT NULL,
    fecha_pago  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor       DECIMAL(12,2)  NOT NULL,
    metodo      ENUM('Efectivo', 'Tarjeta', 'Transferencia', 'Billetera digital') NOT NULL,
    CONSTRAINT chk_pago_valor CHECK (valor > 0),
    CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- Un pedido tiene como máximo un envío (UNIQUE). Los pedidos que el
-- cliente recoge en la sucursal no tienen fila aquí.
CREATE TABLE envios (
    id_envio        INT            PRIMARY KEY AUTO_INCREMENT,
    id_pedido       INT            NOT NULL,
    transportadora  VARCHAR(40)    NOT NULL,
    costo_envio     DECIMAL(10,2)  NOT NULL DEFAULT 0,
    fecha_envio     DATE           NOT NULL,
    fecha_entrega   DATE,                         -- NULL = aún en camino
    CONSTRAINT uq_envio_pedido   UNIQUE (id_pedido),
    CONSTRAINT chk_envio_costo   CHECK (costo_envio >= 0),
    CONSTRAINT chk_envio_fechas  CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_envio),
    CONSTRAINT fk_envio_pedido   FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

SHOW TABLES;
