# Caso biblioteca · Subconsultas y vistas

**Bases de Datos I** — Práctica de subconsultas y vistas sobre la base de una biblioteca. Cada tema va en su propio archivo, organizado en partes: cada parte explica primero el concepto con un ejemplo, luego tiene ejercicios sencillos y termina con uno más elaborado. Cada archivo cierra con un ejercicio que lo junta todo.

---

## 1. El modelo

| Tabla | Qué guarda | Filas |
|---|---|---|
| `autores` | Autores y su país | 7 |
| `libros` | Libros, con género, año, ejemplares y autor (puede ser NULL) | 12 |
| `socios` | Socios de la biblioteca | 10 |
| `prestamos` | Qué socio se llevó qué libro (muchos a muchos). `fecha_devolucion` en NULL: no se ha devuelto | 22 |
| `multas` | Multas de un préstamo: `Retraso`, `Daño` o `Pérdida` | 6 |

Los datos traen a propósito algunos casos especiales que los ejercicios aprovechan: un autor sin libros, un libro sin autor ni año, un libro que nunca se ha prestado, dos socios sin préstamos y cuatro préstamos sin devolver.

---

## 2. Los archivos

| Paso | Archivo | Qué hace | Cómo se ejecuta |
|---|---|---|---|
| 1 | `01_base_datos.sql` | Crea la base `biblioteca` con sus 5 tablas y carga los datos de prueba | Completo |
| 2 | `02_subconsultas.sql` | 14 ejercicios en 6 partes: subconsulta de un solo valor, IN y NOT IN, EXISTS y NOT EXISTS, subconsulta en el SELECT, subconsulta en el FROM y todo junto. Solo consulta | Un ejercicio a la vez |
| 3 | `03_vistas.sql` | 9 ejercicios en 5 partes: crear y consultar vistas, ver que muestran los datos actuales, modificarlas y eliminarlas, guardar datos a través de ellas (WITH CHECK OPTION) y todo junto | Un ejercicio a la vez, en orden |

`03_vistas.sql` crea vistas y cambia datos. Si algo sale mal, se recarga la base con el paso 1 (también borra las vistas) y se empieza ese archivo de nuevo.

**Entrega:** los archivos `02_subconsultas.sql` y `03_vistas.sql` con todas las soluciones y las respuestas a las preguntas.

---

## 3. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| Error 1049 *Unknown database 'biblioteca'* | Ejecutar `01_base_datos.sql`. |
| Error 1242 *Subquery returns more than 1 row* | Se comparó con `=` una subconsulta que devuelve varias filas: usar `IN`, o revisar la subconsulta. |
| Error 1248 *Every derived table must have its own alias* | La subconsulta del FROM necesita un nombre: `(...) AS nombre`. |
| Error 1111 *Invalid use of group function* | Se usó una función de agregación en el WHERE o dentro de otra: pasarla a una subconsulta. |
| Error 1050 *Table 'prestamos_pendientes' already exists* | La vista ya existe: usar `CREATE OR REPLACE VIEW` o `DROP VIEW` primero. |
| Error 1369 *CHECK OPTION failed* | Se intentó guardar por una vista `WITH CHECK OPTION` una fila que la vista no mostraría. |
| Error 1175 en un UPDATE | Ejecutar `SET SQL_SAFE_UPDATES = 0;` (está al inicio de `03_vistas.sql`). |
