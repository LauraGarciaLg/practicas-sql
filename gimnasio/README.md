# Caso gimnasio · Introducción a SQL

**Bases de Datos I** — Primer contacto con SQL en MySQL.

Aquí se lleva a un servidor real el gimnasio que se diseñó con el modelo E-R y se normalizó hasta 3FN: primero se convierte el diseño en tablas, después se cargan datos y por último se prueban, una por una, las cuatro familias de instrucciones de SQL (DDL, DML, DCL y TCL).

Todo se trabaja **ejecutando** instrucciones en el SGBD y **observando** lo que ocurre.

---

## 1. Requisitos

- Un servidor **MySQL 8.0** o superior en marcha y un cliente SQL conectado. El [README principal](../README.md) explica cómo levantar el servidor con Docker y cómo conectarse.
- Estar conectado como `root`: el laboratorio crea un usuario.

---

## 2. Los tres archivos, en orden

```
gimnasio/
├── README.md            ← este archivo
├── 01_esquema.sql       del modelo a las tablas
├── 02_datos.sql         los datos de prueba
└── 03_laboratorio.sql   práctica guiada y ejercicios
```

| Paso | Archivo | Qué hace | Cómo se ejecuta |
|---|---|---|---|
| 1 | `01_esquema.sql` | Crea la base `gimnasio` con sus 5 tablas: `entrenadores`, `clientes`, `clases`, `inscripciones` y `pagos`. Se lee con el modelo relacional a la vista. | Completo |
| 2 | `02_datos.sql` | Llena las tablas con datos de prueba. | Completo |
| 3 | `03_laboratorio.sql` | **Parte A:** práctica guiada sobre los cuatro sublenguajes. **Parte B:** ejercicios para resolver de forma autónoma. | Un bloque a la vez |

Los pasos 1 y 2 dejan la base en un estado conocido. Se repiten cada vez que haga falta: antes de la parte B del laboratorio y siempre que algo se dañe durante la práctica.

---

## 3. Cómo trabajar el laboratorio

1. Ejecutar completos `01_esquema.sql` y `02_datos.sql`.
2. Abrir `03_laboratorio.sql` y ejecutar **un bloque a la vez**, nunca el archivo completo. Los atajos de cada cliente están en el [README principal](../README.md#4-ejecutar-un-script).
3. Mirar el **panel de resultados** (tablas) y el **panel de mensajes** (filas afectadas y errores; *Output* en Workbench).
4. Responder en el cuaderno las líneas marcadas `PREGUNTA`.
5. Al terminar la parte A, recargar la base (pasos 1 y 2) y resolver la parte B.

---

## 4. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| Error 1049 *Unknown database 'gimnasio'* | Ejecutar `01_esquema.sql` y `02_datos.sql`. |
| Error 1175 en un UPDATE o DELETE | Es el modo seguro de Workbench: ejecutar `SET SQL_SAFE_UPDATES = 0;` (está al inicio del laboratorio y vale para la sesión actual). |
| Error 1050 *Table 'salones' already exists* | El paso ya se había ejecutado: recargar la base y repetirlo. |
| Los resultados no coinciden con los comentarios | Recargar la base con `01_esquema.sql` y `02_datos.sql`. |
| Error 1227 al crear un usuario | La conexión no tiene permisos de administración: usar `root`. |
| Tildes o ñ mal escritas | Verificar que el archivo se abrió con codificación UTF-8. |

---

## 5. Convenciones del curso

- Tablas en **plural** y siempre en minúsculas: `clientes`, `inscripciones`.
- Los componentes de un atributo compuesto llevan el prefijo del atributo padre: `direccion_calle`, `direccion_barrio`, `direccion_ciudad`.
- Claves primarias con prefijo `id_`: `id_cliente`, `id_clase`.
- Restricciones con nombre descriptivo: `chk_saldo`, `fk_clase_entrenador`.

---

## 6. Qué sigue

El [caso tienda](../tienda/) retoma cada sublenguaje a fondo sobre una base más grande: `ALTER TABLE`, JOIN, GROUP BY, subconsultas, vistas, transacciones entre dos sesiones, permisos y roles.
