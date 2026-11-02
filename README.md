# Prácticas de SQL

Material para aprender SQL **ejecutando** instrucciones en un servidor MySQL y **observando** lo que ocurre. El repositorio trae **cuatro bases de datos de práctica** y una actividad de transacciones desde Python, cada una en su carpeta.

---

## 1. Las bases de datos

| | [gimnasio/](gimnasio/) | [academia/](academia/) | [veterinaria/](veterinaria/) | [biblioteca/](biblioteca/) |
|---|---|---|---|---|
| **Para qué** | Introducción: el primer contacto con SQL | Practicar DDL, DML y consultas sobre un modelo pequeño | Ejercicio integrador: construir una base a partir de un enunciado | Practicar subconsultas y vistas |
| **Cuándo** | Al empezar la unidad, justo después del modelo E-R y la normalización | Después del gimnasio | Después de la academia | Después de la veterinaria |
| **Base de datos** | `gimnasio` · 5 tablas, 32 filas | `academia` · 5 tablas, 77 filas | `veterinaria` · 3 tablas, 12 filas | `biblioteca` · 5 tablas, 57 filas |
| **Tablas** | `entrenadores`, `clientes`, `clases`, `inscripciones`, `pagos` | `profesores`, `estudiantes`, `cursos`, `matriculas`, `pagos` | `veterinarios`, `animales`, `atenciones` | `autores`, `libros`, `socios`, `prestamos`, `multas` |
| **Material** | 1 laboratorio: práctica guiada y 7 ejercicios | 55 ejercicios y sus soluciones | 4 ejercicios y su solución, en un solo archivo | 2 archivos: 14 ejercicios de subconsultas y 9 de vistas |
| **Se aprende** | Qué son DDL, DML, DCL y TCL y qué modifica cada uno | Lo ya visto (`CREATE`/`ALTER`/`DROP`, `INSERT`/`UPDATE`/`DELETE`, INNER JOIN, COUNT, SUM y LIMIT) y temas nuevos (LIKE, MIN/MAX/AVG, DISTINCT, HAVING, LEFT y RIGHT JOIN) | Pasar de las reglas del negocio a tablas con sus claves y restricciones, cargar datos y consultarlos con JOIN y GROUP BY | Subconsultas de un valor, con IN/NOT IN y EXISTS/NOT EXISTS, en el SELECT y en el FROM; crear, modificar y eliminar vistas, y guardar datos a través de ellas con WITH CHECK OPTION |

### Ruta recomendada

1. **Preparar el equipo:** instalar MySQL (sección 2) y conectarse (sección 3).
2. **Gimnasio:** ejecutar `01_esquema.sql` y `02_datos.sql` y trabajar `03_laboratorio.sql`. Es el mismo gimnasio que se diseñó en clase, ahora convertido en tablas.
3. **Academia:** ejecutar `01_esquema.sql` y `02_datos.sql` y resolver `03_ejercicios.sql`.
4. **Veterinaria:** resolver el enunciado del inicio de `veterinaria.sql`; el resto del archivo es la solución.
5. **Biblioteca:** ejecutar `01_base_datos.sql` y resolver `02_subconsultas.sql` y después `03_vistas.sql`.
6. **Python y MySQL:** actividad investigativa en casa, antes de la clase de transacciones. Seguir la guía de [python-mysql/](python-mysql/): conectar Python con MySQL y observar COMMIT y ROLLBACK en 5 ejercicios cortos sobre la base `academia`.

### Lo que tienen en común

- Cada base se crea con sus propios scripts y **se puede recargar las veces que haga falta**: si algo se daña durante una práctica, se vuelven a ejecutar y queda como al principio.
- Todas conviven en el mismo servidor sin afectarse. Varias tienen tablas con el mismo nombre (`pagos`), pero son distintas: cada script empieza con `USE gimnasio;`, `USE academia;`, `USE veterinaria;` o `USE biblioteca;` para indicar sobre cuál trabaja.
- Los ejercicios se ejecutan **uno a la vez**, respondiendo las preguntas que traen.

---

## 2. Preparar el equipo

### Descargar el repositorio

En la página del repositorio en GitHub, botón verde **Code → Download ZIP**, y descomprimir el archivo. Quien use Git puede clonarlo y actualizarlo con `git pull`.

### Instalar MySQL en Windows

1. Descargar **MySQL Installer** desde https://dev.mysql.com/downloads/installer/.
2. Instalar **MySQL Server 8.0** y **MySQL Workbench**.
3. Durante la instalación se define la **contraseña de root**: anotarla, se pide cada vez que se conecta.
4. Al terminar, MySQL queda como un servicio de Windows llamado **MySQL80** que arranca solo con el equipo. Si algún día no conecta, revisar en *Servicios* de Windows que esté *En ejecución*.

### Alternativa: Docker

Quien prefiera no instalar MySQL puede usar el servidor que trae el repositorio en `docker-compose.yml`. Se necesita [Docker Desktop](https://docs.docker.com/get-docker/). Desde la carpeta del repositorio:

```bash
docker compose up -d      # iniciar
docker compose ps         # comprobar: mysql debe aparecer como "healthy"
docker compose stop       # detener (los datos se conservan)
docker compose down -v    # borrar todo y empezar de cero
```

Con Docker, la contraseña de root es `root`.

---

## 3. Conectarse

Los datos de conexión son los mismos para cualquier cliente SQL:

| Campo | Valor |
|---|---|
| Host | `127.0.0.1` |
| Puerto | `3306` |
| Usuario | `root` |
| Contraseña | La que se definió al instalar MySQL (con Docker: `root`) |
| Base de datos | (vacío) |

**MySQL Workbench:** clic en **⊕** junto a *MySQL Connections*, completar los datos y pulsar *Test Connection*.

**DBeaver:** *Database → New Database Connection → MySQL*, completar los datos y pulsar *Test Connection*. La primera vez pide descargar el driver. Si aparece *Public Key Retrieval is not allowed*, en la pestaña *Driver properties* se cambia `allowPublicKeyRetrieval` a `true`.

---

## 4. Ejecutar un script

| Acción | MySQL Workbench | DBeaver |
|---|---|---|
| La instrucción donde está el cursor | Ctrl + Enter | Ctrl + Enter |
| Un bloque seleccionado (varias instrucciones) | Ctrl + Shift + Enter | Alt + X |
| El archivo completo (sin selección) | Ctrl + Shift + Enter | Alt + X |

En DBeaver, **Ctrl + Enter con varias instrucciones seleccionadas las envía como una sola** y produce un error de sintaxis (1064). Para varias instrucciones se usa Alt + X.

---

## 5. La terminal de MySQL

Además de Workbench y DBeaver, MySQL tiene una consola de texto. Sirve para cargar una base rápido o para trabajar en un equipo sin cliente gráfico.

Hay que distinguir dos terminales:

- **La terminal del sistema** (`C:\>` o `PS C:\>`) entiende comandos de Windows, pero no SQL.
- **La consola de MySQL** (`mysql>`) entiende SQL.

Escribir `SHOW DATABASES;` en la terminal del sistema da un error como *"SHOW" no se reconoce como un comando*.

### Entrar

En el menú Inicio, abrir **MySQL 8.0 Command Line Client** y escribir la contraseña de root.

También se puede desde una terminal del sistema:

```
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p --default-character-set=utf8mb4
```

Pide la contraseña, que no se ve mientras se escribe. Se entró cuando el prompt cambia a `mysql>`. Para salir: `exit`.

`--default-character-set=utf8mb4` hace que las tildes y la ñ se vean y se guarden bien.

**Con Docker**, desde una terminal del sistema y con el servidor levantado:

```bash
docker exec -it mysql mysql -uroot -proot --default-character-set=utf8mb4
```

### Comandos básicos

| Comando | Qué hace |
|---|---|
| `SHOW DATABASES;` | Lista las bases de datos del servidor |
| `USE academia;` | Elige la base con la que se va a trabajar |
| `SELECT DATABASE();` | Muestra qué base está elegida |
| `SHOW TABLES;` | Lista las tablas de la base elegida |
| `DESCRIBE cursos;` | Muestra las columnas de una tabla, sus tipos y sus claves |
| `SHOW CREATE TABLE cursos\G` | Muestra el CREATE TABLE completo, con sus restricciones |
| `exit` | Sale de la consola |

### Cómo se escribe

- Toda instrucción termina en **`;`**. Si se presiona Enter sin el `;`, aparece `->`: la consola espera el resto. Una consulta se puede escribir en varias líneas.
- Si aparece `'>` o `">`, quedó una comilla sin cerrar: se escribe la comilla que falta y luego `\c`.
- **`\c`** cancela lo que se lleva escrito sin ejecutarlo.
- Terminar con **`\G`** en vez de `;` muestra cada fila en vertical, útil cuando la tabla no cabe a lo ancho.
- Las flechas **↑ ↓** recorren las instrucciones anteriores.

### Ejecutar un archivo completo

Ya dentro de `mysql>`, con la ruta completa del archivo y barras `/` (no `\`), aunque sea Windows:

```sql
SOURCE C:/Users/usuario/Downloads/practicas-sql/academia/01_esquema.sql;
```

Con Docker basta la ruta tal como se ve en el repositorio, porque la carpeta está compartida con el contenedor: `SOURCE academia/01_esquema.sql;`.

Las líneas que pasan rápido en pantalla son los resultados de cada instrucción del archivo; al final aparece la tabla de verificación.

### Errores frecuentes

| Mensaje | Causa y solución |
|---|---|
| *"SHOW" no se reconoce como un comando* | Se escribió SQL en la terminal del sistema. Primero hay que entrar a `mysql>`. |
| *'mysql' no se reconoce como un comando* | Usar **MySQL 8.0 Command Line Client** o la ruta completa del `mysql.exe`. |
| `ERROR 1045: Access denied` | La contraseña de root no es la correcta. |
| `ERROR 1046: No database selected` | Falta elegir la base: `USE academia;`. |
| `ERROR 2003: Can't connect to MySQL server` | El servicio **MySQL80** está detenido: iniciarlo en *Servicios* de Windows. Con Docker: `docker compose up -d` y esperar a que `docker compose ps` diga *healthy*. |
| Las tildes salen como `Ã¡` o `?` | Faltó `--default-character-set=utf8mb4` al entrar. |
| `Failed to open file '...', error: 2` | La ruta del archivo está mal: revisarla y usar barras `/`. |

---

## 6. Convenciones

- Los nombres de tablas y vistas van siempre en **minúsculas**: en Linux, MySQL distingue mayúsculas de minúsculas en esos nombres.
- Las palabras reservadas de SQL van en mayúsculas: `SELECT`, `CREATE TABLE`.
- Cada caso crea sus propias bases de datos y puede reiniciarlas sin afectar a los demás.
