# Prácticas de SQL

Material para aprender SQL **ejecutando** instrucciones en un servidor MySQL y **observando** lo que ocurre. El repositorio trae un servidor listo para levantar con Docker y **tres bases de datos de práctica**, cada una en su carpeta y con su propio `README.md`.

---

## 1. Las bases de datos

| | [gimnasio/](gimnasio/) | [academia/](academia/) | [tienda/](tienda/) |
|---|---|---|---|
| **Para qué** | Introducción: el primer contacto con SQL | Practicar DDL, DML y consultas con JOIN sobre un modelo pequeño | Práctica a fondo de cada tema |
| **Cuándo** | Al empezar la unidad, justo después del modelo E-R y la normalización | Después del gimnasio | Durante el resto de la unidad |
| **Base de datos** | `gimnasio` · 5 tablas, 32 filas | `academia` · 5 tablas, 77 filas | `tienda` · 10 tablas, cerca de 950 filas |
| **Tablas** | `entrenadores`, `clientes`, `clases`, `inscripciones`, `pagos` | `profesores`, `estudiantes`, `cursos`, `matriculas`, `pagos` | `sucursales`, `empleados`, `categorias`, `proveedores`, `productos`, `clientes`, `pedidos`, `detalle_pedido`, `pagos`, `envios` |
| **Material** | 1 laboratorio: práctica guiada y 7 ejercicios | 55 ejercicios y sus soluciones | 8 laboratorios (guía y ejercicios) y un reto integrador |
| **Se aprende** | Qué son DDL, DML, DCL y TCL y qué modifica cada uno | `CREATE`/`ALTER`/`DROP`, `INSERT`/`UPDATE`/`DELETE`, errores de restricciones, JOIN, funciones de agregación, GROUP BY y HAVING | A usarlos de verdad: `ALTER TABLE`, JOIN, GROUP BY, subconsultas, vistas, transacciones, permisos y roles |

### Ruta recomendada

1. **Preparar el equipo:** levantar el servidor (sección 2) y conectarse (sección 3).
2. **Gimnasio:** ejecutar `01_esquema.sql` y `02_datos.sql` y trabajar `03_laboratorio.sql`. Es el mismo gimnasio que se diseñó en clase, ahora convertido en tablas.
3. **Academia:** ejecutar `01_esquema.sql` y `02_datos.sql` y resolver `03_ejercicios.sql`.
4. **Tienda:** seguir los laboratorios en orden, del 01 al 09.

| Tienda | Tema | |
|---|---|---|
| 01 | DDL | Construir la base desde cero y transformarla |
| 02 | DML | Insertar, actualizar y eliminar datos |
| 03 | Consultas | `SELECT` sobre una tabla: filtros, orden, funciones |
| 04 | JOIN | Combinar varias tablas |
| 05 | Agrupación | `GROUP BY`, `HAVING` y funciones de agregación |
| 06 | Subconsultas y vistas | Subconsultas, CTE, funciones de ventana, vistas |
| 07 | TCL | Transacciones y trabajo con dos sesiones |
| 08 | DCL | Usuarios, permisos y roles |
| 09 | Reto integrador | Un encargo completo, sin guía |

### Lo que tienen en común

- Cada base se crea con sus propios scripts y **se puede recargar las veces que haga falta**: si algo se daña durante una práctica, se vuelven a ejecutar y queda como al principio.
- Todas conviven en el mismo servidor sin afectarse. Varias tienen tablas con el mismo nombre (`clientes`, `pagos`), pero son distintas: cada script empieza con `USE gimnasio;`, `USE academia;` o `USE tienda;` para indicar sobre cuál trabaja.
- Las guías se ejecutan **un bloque a la vez**, leyendo los comentarios `OBSERVAR` y respondiendo las `PREGUNTAS` en el cuaderno.

El archivo `docker-compose.yml` levanta un servidor MySQL vacío que sirve para todos los casos y para cualquier práctica propia.

---

## 2. Levantar el servidor

Se necesita [Docker](https://docs.docker.com/get-docker/) con Docker Compose.

Desde la carpeta del repositorio:

```bash
docker compose up -d      # iniciar
docker compose ps         # comprobar: mysql debe aparecer como "healthy"
docker compose stop       # detener (los datos se conservan)
docker compose down -v    # borrar todo y empezar de cero
```

También sirve un MySQL Server 8.0 o superior instalado directamente en el equipo.

---

## 3. Conectarse

Los datos de conexión son los mismos para cualquier cliente SQL:

| Campo | Valor |
|---|---|
| Host | `127.0.0.1` |
| Puerto | `3306` |
| Usuario | `root` |
| Contraseña | `root` |
| Base de datos | (vacío) |

**DBeaver:** *Database → New Database Connection → MySQL*, completar los datos y pulsar *Test Connection*. La primera vez pide descargar el driver. Si aparece *Public Key Retrieval is not allowed*, en la pestaña *Driver properties* se cambia `allowPublicKeyRetrieval` a `true`.

**MySQL Workbench:** clic en **⊕** junto a *MySQL Connections*, completar los datos y pulsar *Test Connection*.

Las cuentas que crean las prácticas (por ejemplo `'tienda_vendedor'@'localhost'`) se conectan igual, cambiando solo usuario y contraseña.

---

## 4. Ejecutar un script

| Acción | DBeaver | MySQL Workbench |
|---|---|---|
| La instrucción donde está el cursor | Ctrl + Enter | Ctrl + Enter |
| Un bloque seleccionado (varias instrucciones) | Alt + X | Ctrl + Shift + Enter |
| El archivo completo (sin selección) | Alt + X | Ctrl + Shift + Enter |

En DBeaver, **Ctrl + Enter con varias instrucciones seleccionadas las envía como una sola** y produce un error de sintaxis (1064). Para varias instrucciones se usa Alt + X.

---

## 5. Convenciones

- Los nombres de tablas y vistas van siempre en **minúsculas**: en Linux, MySQL distingue mayúsculas de minúsculas en esos nombres.
- Las palabras reservadas de SQL van en mayúsculas: `SELECT`, `CREATE TABLE`.
- Cada caso crea sus propias bases de datos y puede reiniciarlas sin afectar a los demás.
