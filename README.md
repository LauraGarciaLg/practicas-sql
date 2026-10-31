# Prácticas de SQL

Material para aprender SQL **ejecutando** instrucciones en un servidor MySQL y **observando** lo que ocurre. El repositorio trae un servidor listo para levantar con Docker y **cuatro bases de datos de práctica**, cada una en su carpeta y con su propio `README.md`.

---

## 1. Las bases de datos

| | [gimnasio/](gimnasio/) | [academia/](academia/) | [biblioteca/](biblioteca/) | [tienda/](tienda/) |
|---|---|---|---|---|
| **Para qué** | Introducción: el primer contacto con SQL | Practicar DDL, DML y consultas con JOIN sobre un modelo pequeño | Taller: practicar todas las instrucciones vistas sobre una base nueva | Práctica a fondo de cada tema |
| **Cuándo** | Al empezar la unidad, justo después del modelo E-R y la normalización | Después del gimnasio | Después de la academia | Durante el resto de la unidad |
| **Base de datos** | `gimnasio` · 5 tablas, 32 filas | `academia` · 5 tablas, 77 filas | `biblioteca` · 5 tablas, 57 filas | `tienda` · 10 tablas, cerca de 950 filas |
| **Tablas** | `entrenadores`, `clientes`, `clases`, `inscripciones`, `pagos` | `profesores`, `estudiantes`, `cursos`, `matriculas`, `pagos` | `autores`, `libros`, `socios`, `prestamos`, `multas` | `sucursales`, `empleados`, `categorias`, `proveedores`, `productos`, `clientes`, `pedidos`, `detalle_pedido`, `pagos`, `envios` |
| **Material** | 1 laboratorio: práctica guiada y 7 ejercicios | 55 ejercicios y sus soluciones | Taller de 10 ejercicios | 8 laboratorios (guía y ejercicios) y un reto integrador |
| **Se aprende** | Qué son DDL, DML, DCL y TCL y qué modifica cada uno | `CREATE`/`ALTER`/`DROP`, `INSERT`/`UPDATE`/`DELETE`, errores de restricciones, JOIN, funciones de agregación, GROUP BY y HAVING | Lo mismo, sin repetir ejercicios: LIMIT y OFFSET, LIKE, MIN/MAX/AVG, DISTINCT, HAVING, LEFT y RIGHT JOIN y DATE_FORMAT | A usarlos de verdad: `ALTER TABLE`, JOIN, GROUP BY, subconsultas, vistas, transacciones, permisos y roles |

### Ruta recomendada

1. **Preparar el equipo:** levantar el servidor (sección 2) y conectarse (sección 3).
2. **Gimnasio:** ejecutar `01_esquema.sql` y `02_datos.sql` y trabajar `03_laboratorio.sql`. Es el mismo gimnasio que se diseñó en clase, ahora convertido en tablas.
3. **Academia:** ejecutar `01_esquema.sql` y `02_datos.sql` y resolver `03_ejercicios.sql`.
4. **Biblioteca:** ejecutar `01_base_datos.sql` y resolver el taller `02_taller.sql`.
5. **Tienda:** seguir los laboratorios en orden, del 01 al 09.

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
- Todas conviven en el mismo servidor sin afectarse. Varias tienen tablas con el mismo nombre (`clientes`, `pagos`), pero son distintas: cada script empieza con `USE gimnasio;`, `USE academia;`, `USE biblioteca;` o `USE tienda;` para indicar sobre cuál trabaja.
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

---

## 4. Ejecutar un script

| Acción | DBeaver | MySQL Workbench |
|---|---|---|
| La instrucción donde está el cursor | Ctrl + Enter | Ctrl + Enter |
| Un bloque seleccionado (varias instrucciones) | Alt + X | Ctrl + Shift + Enter |
| El archivo completo (sin selección) | Alt + X | Ctrl + Shift + Enter |

En DBeaver, **Ctrl + Enter con varias instrucciones seleccionadas las envía como una sola** y produce un error de sintaxis (1064). Para varias instrucciones se usa Alt + X.

---

## 5. La terminal de MySQL

Además de DBeaver y Workbench, MySQL tiene una consola de texto. Sirve para cargar una base rápido o para trabajar en un equipo sin cliente gráfico.

Hay que distinguir dos terminales:

- **La terminal del sistema** (`$`, `PS C:\>`, `C:\>` o `sh-5.1#`) entiende comandos del sistema operativo, como `docker` o `mysql`, pero no SQL.
- **La consola de MySQL** (`mysql>`) entiende SQL.

Escribir `SHOW DATABASES;` en la terminal del sistema da un error como `command not found`.

### Entrar

**Con Docker** (el servidor de este repositorio). En una terminal del sistema, con el servidor levantado (sección 2):

```bash
docker exec -it mysql mysql -uroot -proot --default-character-set=utf8mb4
```

Si ya se está *dentro* del contenedor (por ejemplo, con *Attach Shell* de VS Code, y el prompt es `sh-5.1#`), basta con:

```bash
mysql -uroot -proot --default-character-set=utf8mb4
```

**Sin Docker** (MySQL Server instalado en el equipo):

```bash
mysql -h 127.0.0.1 -P 3306 -u root -p
```

Pide la contraseña, que no se ve mientras se escribe. Es la que se definió al instalar MySQL. En Windows también sirve **MySQL 8.0 Command Line Client**, en el menú Inicio. Si sale *'mysql' no se reconoce como un comando*, se usa la ruta completa: `"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p`.

En los dos casos, se entró cuando el prompt cambia a `mysql>`. Para salir: `exit`.

`--default-character-set=utf8mb4` hace que las tildes y la ñ se vean y se guarden bien.

### Comandos básicos

| Comando | Qué hace |
|---|---|
| `SHOW DATABASES;` | Lista las bases de datos del servidor |
| `USE biblioteca;` | Elige la base con la que se va a trabajar |
| `SELECT DATABASE();` | Muestra qué base está elegida |
| `SHOW TABLES;` | Lista las tablas de la base elegida |
| `DESCRIBE libros;` | Muestra las columnas de una tabla, sus tipos y sus claves |
| `SHOW CREATE TABLE libros\G` | Muestra el CREATE TABLE completo, con sus restricciones |
| `exit` | Sale de la consola |

### Cómo se escribe

- Toda instrucción termina en **`;`**. Si se presiona Enter sin el `;`, aparece `->`: la consola espera el resto. Una consulta se puede escribir en varias líneas.
- Si aparece `'>` o `">`, quedó una comilla sin cerrar: se escribe la comilla que falta y luego `\c`.
- **`\c`** cancela lo que se lleva escrito sin ejecutarlo.
- Terminar con **`\G`** en vez de `;` muestra cada fila en vertical, útil cuando la tabla no cabe a lo ancho.
- Las flechas **↑ ↓** recorren las instrucciones anteriores.

### Ejecutar un archivo completo

Ya dentro de `mysql>`, con la ruta del archivo tal como se ve en el repositorio:

```sql
SOURCE biblioteca/01_base_datos.sql;
```

- **Con Docker** funciona así, porque la carpeta del repositorio está compartida con el contenedor.
- **Sin Docker** funciona igual si la consola se abrió desde la carpeta del repositorio. Si no, se usa la ruta completa, con barras `/` incluso en Windows: `SOURCE C:/Users/usuario/practicas-sql/biblioteca/01_base_datos.sql;`.

Las líneas que pasan rápido en pantalla son los resultados de cada instrucción del archivo; al final aparece la tabla de verificación.

### Errores frecuentes

| Mensaje | Causa y solución |
|---|---|
| `SHOW: command not found` o *"SHOW" no se reconoce* | Se escribió SQL en la terminal del sistema. Primero hay que entrar a `mysql>`. |
| `ERROR 1045: Access denied … (using password: NO)` | Faltaron el usuario y la contraseña: `mysql -uroot -proot`. |
| `ERROR 1046: No database selected` | Falta elegir la base: `USE biblioteca;`. |
| `ERROR 2002` o `ERROR 2003: Can't connect to MySQL server` | El servidor no está levantado o todavía está arrancando. Con Docker: `docker compose ps` y esperar a que diga *healthy*. |
| `Error: No such container: mysql` | El contenedor no existe o no está corriendo: `docker compose up -d` desde la carpeta del repositorio. |
| `mysql: command not found` o *'mysql' no se reconoce* | El cliente de MySQL no está instalado en el equipo. Usar el comando con Docker o la ruta completa del `mysql.exe`. |
| Las tildes salen como `Ã¡` o `?` | Faltó `--default-character-set=utf8mb4` al entrar. |
| `Failed to open file 'biblioteca/01_base_datos.sql', error: 2` | La consola no encuentra el archivo. Con Docker: el contenedor se creó antes de que se compartiera la carpeta; ejecutar `docker compose up -d` desde la carpeta del repositorio y volver a entrar. Sin Docker: usar la ruta completa. |

---

## 6. Convenciones

- Los nombres de tablas y vistas van siempre en **minúsculas**: en Linux, MySQL distingue mayúsculas de minúsculas en esos nombres.
- Las palabras reservadas de SQL van en mayúsculas: `SELECT`, `CREATE TABLE`.
- Cada caso crea sus propias bases de datos y puede reiniciarlas sin afectar a los demás.
