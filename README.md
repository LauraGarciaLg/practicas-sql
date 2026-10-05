# Prácticas de SQL

Material para aprender SQL **ejecutando** instrucciones en un servidor MySQL y **observando** lo que ocurre. El repositorio trae un servidor listo para levantar con Docker y una colección de casos de práctica, cada uno en su propia carpeta.

---

## 1. Contenido

| Carpeta | Caso | Temas |
|---|---|---|
| [gimnasio/](gimnasio/) | Sistema de gestión de un gimnasio | DDL, DML y DCL · lenguaje SQL · consultas y subconsultas · tratamiento de datos · transacciones · vistas · seguridad y control de acceso |

Cada caso tiene su propio `README.md` con el orden de trabajo y las indicaciones particulares.

El archivo `docker-compose.yml` levanta un servidor MySQL vacío que sirve para cualquier caso o práctica propia.

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

Las cuentas que crean las prácticas (por ejemplo `'recepcion1'@'localhost'`) se conectan igual, cambiando solo usuario y contraseña.

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
