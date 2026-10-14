# Caso academia · Práctica de DDL y DML

**Bases de Datos I** — Segundo caso de práctica, con la misma forma del gimnasio pero sobre otro negocio: una academia de música. Sirve para practicar cambios de estructura (DDL), cambios de datos (DML) y consultas con JOIN y GROUP BY sin repetir los ejercicios del gimnasio.

---

## 1. El modelo

| Tabla | Qué guarda | Filas |
|---|---|---|
| `profesores` | Profesores y el instrumento que enseñan | 6 |
| `estudiantes` | Estudiantes de la academia | 12 |
| `cursos` | Cursos, con cupo, precio mensual y profesor (puede ser NULL) | 8 |
| `matriculas` | Qué estudiante está en qué curso (muchos a muchos) | 17 |
| `pagos` | Pagos de cada estudiante: `Matrícula`, `Mensualidad` o `Material` | 34 |

A diferencia del gimnasio, cada pago de `Mensualidad` o `Material` indica **a qué curso corresponde** (`id_curso`), así que se puede saber cuánto pagó un estudiante por cada curso. El pago de `Matrícula` es la cuota de ingreso y no tiene curso (`id_curso` en NULL).

Los datos traen a propósito algunos casos para que las consultas den resultados distintos según el tipo de JOIN: un profesor sin cursos, un curso sin profesor, un curso sin estudiantes, un estudiante sin matrículas y una estudiante que pagó la cuota de ingreso pero no se ha matriculado.

---

## 2. Los archivos

| Paso | Archivo | Qué hace | Cómo se ejecuta |
|---|---|---|---|
| 1 | `01_esquema.sql` | Crea la base `academia` con sus 5 tablas | Completo |
| 2 | `02_datos.sql` | Carga los datos de prueba | Completo |
| 3 | `03_ejercicios.sql` | 38 ejercicios: DDL (1.x), DML (2.x), consultas (3.x) y funciones de agregación (4.x) | Un ejercicio a la vez |
| — | `04_soluciones.sql` | Una solución por ejercicio, con el resultado esperado | Para el docente |

Los pasos 1 y 2 dejan la base en un estado conocido y se repiten cuando haga falta: **antes de las partes 3 y 4** de los ejercicios y siempre que algo se dañe.

---

## 3. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| Error 1049 *Unknown database 'academia'* | Ejecutar `01_esquema.sql` y `02_datos.sql`. |
| Error 1175 en un UPDATE o DELETE | Ejecutar `SET SQL_SAFE_UPDATES = 0;` (está al inicio de los ejercicios). |
| Error 1050 *Table 'salas' already exists* | El ejercicio ya se había hecho: recargar la base y repetirlo. |
| Los resultados no coinciden con las soluciones | Recargar la base antes de las partes 3 y 4. |
