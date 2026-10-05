# Caso gimnasio · Sistema de gestión de un gimnasio

**Bases de Datos I** — Prácticas en MySQL de los temas 03 a 09 de la unidad de SQL.

Cada laboratorio se trabaja **ejecutando** instrucciones en el SGBD y **observando** lo que ocurre. Todos usan el mismo caso: el gimnasio que se diseñó con el modelo E-R y se normalizó hasta 3FN.

---

## 1. Requisitos

- Un servidor **MySQL 8.0** o superior en marcha y un cliente SQL conectado. El [README principal](../README.md) explica cómo levantar el servidor con Docker y cómo conectarse.
- Un usuario con permisos de administración (`root`). Los laboratorios 01 y 07 crean usuarios.

---

## 2. Estructura de la carpeta

```
gimnasio/
├── README.md                      ← este archivo
├── 00_preparacion/
│   ├── 01_esquema.sql             crea (o reinicia) la base gimnasio
│   └── 02_datos.sql               carga los datos de prueba
├── 01_ddl_dml_dcl/                guia.sql · ejercicios.sql
├── 02_lenguaje_sql/               guia.sql · ejercicios.sql
├── 03_consultas_subconsultas/     guia.sql · ejercicios.sql
├── 04_tratamiento_datos/          datos_sucios.sql · guia.sql · ejercicios.sql
├── 05_transacciones/              guia.sql · sesion_A.sql · sesion_B.sql · ejercicios.sql
├── 06_vistas/                     guia.sql · ejercicios.sql
└── 07_seguridad/                  guia_admin.sql · prueba_recepcion.sql
                                   prueba_contador.sql · ejercicios.sql
```

Cada tipo de archivo tiene una sola responsabilidad:

| Archivo | Para qué sirve |
|---|---|
| `00_preparacion/*.sql` | Dejar la base en un estado conocido. Se puede ejecutar las veces que haga falta. |
| `guia.sql` | Práctica guiada paso a paso: ejecutar, observar y responder preguntas en el cuaderno. |
| `ejercicios.sql` | Enunciados para resolver de forma autónoma, con espacio para la solución. |
| `datos_sucios.sql`, `sesion_A/B.sql`, `prueba_*.sql` | Material de apoyo propio de un laboratorio. |

---

## 3. Orden de trabajo

| Lab | Tema | Preparación previa |
|---|---|---|
| 01 | Lenguajes DDL, DML y DCL | Ninguna (usa su propia base `lab01_mapa`) |
| 02 | Lenguaje SQL | Ninguna (la guía construye la base `gimnasio`) |
| 03 | Consultas y subconsultas | Ejecutar `00_preparacion` |
| 04 | Tratamiento de datos | `00_preparacion` + `datos_sucios.sql` |
| 05 | Transacciones | Ejecutar `00_preparacion` |
| 06 | Creación de vistas | Ejecutar `00_preparacion` |
| 07 | Seguridad y control de acceso | Ejecutar `00_preparacion` |

**Regla de oro:** antes de cada laboratorio desde el 03, se ejecutan `01_esquema.sql` y luego `02_datos.sql`. Así todos parten de los mismos datos y los resultados coinciden con los que describen las guías. Si algo se daña durante la práctica, se vuelve a ejecutar la preparación.

---

## 4. Cómo trabajar las guías

1. Abrir el archivo `.sql` en el cliente SQL.
2. Ejecutar **un bloque a la vez**, nunca la guía completa. Los atajos de cada cliente están en el [README principal](../README.md#4-ejecutar-un-script).
3. Mirar el **panel de resultados** (tablas) y el **panel de mensajes** (filas afectadas y errores; *Output* en Workbench).
4. Responder en el cuaderno las líneas marcadas `PREGUNTA`.

> Los archivos de `00_preparacion` y `datos_sucios.sql` sí se ejecutan completos.

---

## 5. Errores a propósito

Muchas guías incluyen instrucciones que **deben fallar**. Están marcadas con `ERROR xxxx esperado`. El error es parte de la práctica: se lee el mensaje y se explica por qué ocurrió. Por eso las guías no se ejecutan completas de una vez: el cliente se detiene en el primer error.

Códigos que aparecerán:

| Código | Significado |
|---|---|
| 1054 | Columna desconocida (por ejemplo, un alias usado en WHERE) |
| 1062 | Valor duplicado en PRIMARY KEY o UNIQUE |
| 1111 | Función de agregación usada donde no se permite |
| 1142 | Permiso denegado para ese usuario |
| 1175 | Modo seguro de Workbench (UPDATE o DELETE sin clave en el WHERE) |
| 1242 | Una subconsulta escalar devolvió más de una fila |
| 1288 | La vista no es actualizable |
| 1292 / 1406 | Fecha inválida / texto demasiado largo |
| 1364 | Falta un valor obligatorio (NOT NULL sin DEFAULT) |
| 1369 | Violación de WITH CHECK OPTION en una vista |
| 1451 / 1452 | Violación de clave foránea (borrar un padre / insertar un hijo huérfano) |
| 3819 | Violación de una restricción CHECK |

---

## 6. El modo seguro de Workbench

Workbench trae activado *Safe Updates*, que bloquea los UPDATE y DELETE cuyo WHERE no usa una columna clave (error 1175). El laboratorio 02 lo muestra a propósito. Las guías siguientes incluyen al inicio:

```sql
SET SQL_SAFE_UPDATES = 0;
```

Esto lo desactiva solo para la sesión actual.

---

## 7. Laboratorios con más de una conexión

### Laboratorio 05 (aislamiento de transacciones)

Se necesitan **dos sesiones independientes**:

1. Ir a la pestaña de inicio de Workbench (ícono de la casa).
2. Hacer clic en la conexión local: se abre la primera pestaña de conexión.
3. Volver a la pestaña de inicio y hacer clic **otra vez** en la misma conexión (o usar **Database → Connect to Database…**). Queda una segunda pestaña de conexión, que es otra sesión.
4. Abrir `sesion_A.sql` en la primera y `sesion_B.sql` en la segunda, y seguir el orden A1 → B1 → B2 → A2 → B3 → A3 → B4 → A4 → B5.

### Laboratorio 07 (usuarios)

Para probar lo que puede hacer cada usuario creado:

1. En la pestaña de inicio, clic en **⊕** junto a *MySQL Connections*.
2. *Connection Name*: `recepcion1` · *Hostname*: `localhost` · *Port*: `3306` · *Username*: `recepcion1`.
3. **Test Connection**, escribir la clave indicada en la guía y aceptar.
4. Abrir esa conexión y ejecutar `prueba_recepcion.sql`. Repetir con `contador1` y `prueba_contador.sql`.

---

## 8. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| Error 1175 en un UPDATE o DELETE | Ejecutar `SET SQL_SAFE_UPDATES = 0;` (ver sección 6). |
| Error 1049 *Unknown database 'gimnasio'* | Ejecutar `00_preparacion/01_esquema.sql` y `02_datos.sql`. |
| Los resultados no coinciden con la guía | Reiniciar con `00_preparacion` antes del laboratorio. |
| Error 1045 *Access denied* al conectar como `recepcion1` o `contador1` | Revisar la clave (en el lab 07 la de `recepcion1` cambia en el paso 6) y que el *Hostname* de la conexión sea `localhost`. |
| Error 1205 *Lock wait timeout* en el lab 05 | La otra sesión no confirmó a tiempo (50 s). Hacer ROLLBACK en ambas y repetir los pasos. |
| La consulta del lab 05 se queda "ejecutando" | Es lo esperado: está esperando un bloqueo de la otra sesión. |
| Tildes o ñ mal escritas | Los scripts incluyen `SET NAMES utf8mb4;`. Verificar que el archivo se abrió con codificación UTF-8. |
| No se puede crear un usuario (error 1227) | La conexión no tiene permisos de administración: usar `root`. |

---

## 9. Convenciones del curso

- Tablas en **plural**; tablas y vistas siempre en minúsculas: `clientes`, `inscripciones`, `v_horario`.
- Los componentes de un atributo compuesto llevan el prefijo del atributo padre: `direccion_calle`, `direccion_barrio`, `direccion_ciudad`.
- Claves primarias con prefijo `id_`: `id_cliente`, `id_clase`.
- Restricciones con nombre descriptivo: `chk_saldo`, `fk_clase_entrenador`.
