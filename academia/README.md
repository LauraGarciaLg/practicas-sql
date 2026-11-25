# Caso academia · Práctica de DDL y DML

**Bases de Datos I** — Segundo caso de práctica, con la misma forma del gimnasio pero sobre otro negocio: una academia de música. Sirve para practicar cambios de estructura (DDL), cambios de datos (DML) y consultas con JOIN y GROUP BY sin repetir los ejercicios del gimnasio.

---

## 1. El modelo

| Tabla | Qué guarda | Filas |
|---|---|---|
| `profesores` | Profesores y el instrumento que enseñan | 8 |
| `estudiantes` | Estudiantes de la academia | 30 |
| `cursos` | Cursos, con cupo, precio mensual y profesor (puede ser NULL) | 11 |
| `matriculas` | Qué estudiante está en qué curso (muchos a muchos) | 49 |
| `pagos` | Pagos de cada estudiante: `Matrícula`, `Mensualidad` o `Material` | 289 |

A diferencia del gimnasio, cada pago de `Mensualidad` o `Material` indica **a qué curso corresponde** (`id_curso`), así que se puede saber cuánto pagó un estudiante por cada curso. El pago de `Matrícula` es la cuota de ingreso y no tiene curso (`id_curso` en NULL).

Los datos traen a propósito algunos casos para que las consultas den resultados distintos según el tipo de JOIN: un profesor sin cursos, un curso sin profesor, un curso sin estudiantes, un estudiante sin matrículas y una estudiante que pagó la cuota de ingreso pero no se ha matriculado.

---

## 2. Los archivos

| Paso | Archivo | Qué hace | Cómo se ejecuta |
|---|---|---|---|
| 1 | `01_esquema.sql` | Crea la base `academia` con sus 5 tablas | Completo |
| 2 | `02_datos.sql` | Carga los datos de prueba | Completo |
| 3 | `03_ejercicios.sql` | 55 ejercicios en dos bloques: **A · lo ya visto** (DDL, DML, INNER JOIN, COUNT, SUM y LIMIT, partes 1 a 4) y **B · temas nuevos** (LIKE, MIN/MAX/AVG, DISTINCT, HAVING, LEFT y RIGHT JOIN, partes 5 a 10). Cada parte empieza con una definición corta de sus instrucciones | Un ejercicio a la vez |
| — | `04_soluciones.sql` | Una solución por ejercicio, con el resultado esperado | Para el docente |
| 4 | `05_taller.sql` | Taller de 13 consultas sobre la base cargada, en 4 bloques: consultar una tabla, contar y agrupar, unir tablas y reportes. En cada bloque, primero consultas sencillas y al final una más trabajable. No crea tablas ni cambia datos | Un ejercicio a la vez |
| 5 | `06_subconsultas.sql` | Subconsultas paso a paso, en el mismo orden de la presentación *Subconsultas y vistas*: un solo valor (en SELECT y en UPDATE), IN y NOT IN, NOT EXISTS y subconsultas anidadas. Cada parte empieza con el ejemplo de la diapositiva ya resuelto y sigue con ejercicios, de los más sencillos a los más trabajables (20 en total). Los UPDATE de la parte 1 cambian datos y el archivo trae las líneas para devolverlos | El ejemplo primero, luego un ejercicio a la vez |
| 6 | `07_vistas.sql` | Vistas paso a paso, con el mismo formato y en el orden de la presentación: crear y consultar, los datos actuales, modificar y eliminar, guardar datos a través de una vista (WITH CHECK OPTION) y todo junto (14 ejercicios). Crea vistas y cambia datos | En orden, sobre la base recién cargada |
| 7 | `08_triggers.sql` | Triggers, lo mínimo: qué son, BEFORE y AFTER, NEW y OLD; corregir datos con BEFORE INSERT, validar reglas con SIGNAL, guardar un historial (auditoría) con AFTER, y revisarlos y eliminarlos (2 ejercicios sencillos por parte, 8 en total). Cada estudiante se registra a sí mismo en `estudiantes`, y los 4 ejercicios marcados con [CAPTURA] van en la entrega. El mismo contenido está en [moodle/](moodle/) para el aula virtual | En orden, sobre la base recién cargada |

Los pasos 1 y 2 dejan la base en un estado conocido y se repiten cuando haga falta: **antes de la parte 3** de los ejercicios, **antes del taller**, **antes de `07_vistas.sql`**, **antes de `08_triggers.sql`** y siempre que algo se dañe. Recargar también borra las vistas y los triggers.

**Entrega del taller:** el archivo `05_taller.sql` con las consultas y las respuestas a las preguntas.

**Entrega de triggers:** un PDF con las capturas de los 4 ejercicios marcados con [CAPTURA] (1.1, 2.2, 3.2 y 4.2). El enunciado para la Tarea de Moodle está en [moodle/tarea_triggers.html](moodle/tarea_triggers.html).

---

## 3. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| Error 1049 *Unknown database 'academia'* | Ejecutar `01_esquema.sql` y `02_datos.sql`. |
| Error 1175 en un UPDATE o DELETE | Ejecutar `SET SQL_SAFE_UPDATES = 0;` (está al inicio de los ejercicios). |
| Error 1050 *Table 'salas' already exists* | El ejercicio ya se había hecho: recargar la base y repetirlo. |
| Los resultados no coinciden con las soluciones | Recargar la base antes de la parte 3. |
| Error 1050 al crear una vista | La vista ya existe: usar `CREATE OR REPLACE VIEW` o `DROP VIEW` primero. |
| Error 1369 *CHECK OPTION failed* | Se intentó guardar por una vista `WITH CHECK OPTION` una fila que la vista no mostraría. |
| Error 1288 o 1423 al cambiar datos por una vista | La vista no se puede actualizar (tiene columnas calculadas) o le faltan columnas obligatorias de la tabla. |
| Error de sintaxis 1064 al crear un trigger con `BEGIN … END` | En **DBeaver**: seleccionar todo el bloque, desde `CREATE TRIGGER` hasta el `END;` final, y ejecutarlo con Ctrl+Enter. En **Workbench** o la consola: falta el `DELIMITER //` antes, `END //` al final y `DELIMITER ;` después. |
| Error 1644 con un mensaje propio (*El curso está lleno*…) | No es un fallo: es un trigger que rechazó el cambio con `SIGNAL`. La fila no se guardó. |
| Error 1359 *Trigger already exists* | El trigger ya se había creado: `DROP TRIGGER nombre;` y volver a crearlo, o recargar la base. |
