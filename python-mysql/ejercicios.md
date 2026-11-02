# Python y MySQL · Transacciones

**Nombre:**

> Este archivo es la entrega. Completar cada `✏️`: pegar la salida de la terminal o de Workbench y responder con palabras propias.
>
> Los programas se ejecutan desde la carpeta `python-mysql` con `py nombre_del_archivo.py`.

**Situación:** en la academia, matricular a un estudiante son **dos operaciones**: insertar la matrícula (`matriculas`) y registrar el pago de la mensualidad (`pagos`). Nunca debe quedar una sin la otra.

Para revisar el resultado de cada ejercicio, ejecutar en Workbench o DBeaver:

```sql
SELECT * FROM academia.matriculas WHERE id_estudiante IN (11, 12);
SELECT * FROM academia.pagos      WHERE id_estudiante IN (11, 12) AND concepto = 'Mensualidad';
```

---

### Ejercicio 1. Comprobar la conexión

Antes de trabajar con transacciones hay que confirmar que Python llega a la base `academia`. El programa `01_conexion.py` se conecta, lista los estudiantes y muestra si la conexión confirma los cambios automáticamente (*autocommit*). Ese dato explica todo lo que pasa en los ejercicios siguientes.

**Pasos:** ejecutar `01_conexion.py`.

✏️ Las 3 últimas líneas de la salida:

```text

```

**Pregunta:** ¿Qué valor tiene `autocommit`? ¿Qué significa?

✏️

---

### Ejercicio 2. Una transacción que se confirma

Se matricula a Tomás Navarro (id 11) en Violín Inicial (curso 6) y se registra su pago. El programa `02_matricular.py` hace las dos operaciones dentro de una transacción: si las dos salen bien, las confirma con `commit()`; si alguna falla, las deshace con `rollback()`. En este ejercicio se observa el caso en que todo sale bien y luego un caso en que la base de datos rechaza la operación.

**Pasos:**
1. Ejecutar `02_matricular.py` sin cambiar nada.
2. Revisar las tablas en Workbench con las consultas del inicio.
3. Ejecutar el programa **otra vez**, sin cambiar nada.

✏️ Salida de la primera y de la segunda ejecución:

```text

```

**Preguntas**

a) ¿Quedaron guardados la matrícula y el pago de Tomás Navarro (id 11)?

✏️

b) ¿Por qué falló la segunda ejecución?

✏️

---

### Ejercicio 3. Olvidar el `commit()`

Ahora se matricula a Isabel Romero (id 12), pero el programa no confirma la transacción: se desactiva la línea del `commit()`. Se trata de comprobar si los cambios quedan guardados aunque los dos `INSERT` se ejecuten sin errores.

**Pasos:**
1. En `02_matricular.py`, cambiar `ID_ESTUDIANTE = 11` por `ID_ESTUDIANTE = 12`.
2. Poner un `#` al inicio de la línea `conexion.commit()` para desactivarla.
3. Ejecutar el programa y revisar las tablas en Workbench.

✏️ Salida del programa y lo que muestra Workbench para el estudiante 12:

```text

```

**Pregunta:** El programa dice que guardó la matrícula y el pago. ¿Es cierto? ¿Por qué?

✏️

---

### Ejercicio 4. Un error a mitad de la transacción

Se vuelve a matricular a Isabel Romero, esta vez con un pago de valor 0, que la base de datos no acepta. La primera operación (la matrícula) funciona y la segunda (el pago) falla. Se trata de comprobar qué pasa con la operación que sí funcionó cuando falla otra de la misma transacción.

**Pasos:**
1. Quitar el `#` de la línea `conexion.commit()`.
2. Dejar `ID_ESTUDIANTE = 12` y cambiar `VALOR = 200000` por `VALOR = 0`.
3. Ejecutar el programa y revisar las tablas en Workbench.

✏️ Salida del programa y lo que muestra Workbench para el estudiante 12:

```text

```

**Preguntas**

a) ¿Por qué falló el pago? (Pista: buscar `chk_valor` en `academia/01_esquema.sql`).

✏️

b) La salida dice `1. Matrícula insertada`. ¿Por qué la matrícula no está en la tabla?

✏️

c) Si `conexion.commit()` estuviera **entre** las dos operaciones, ¿qué habría quedado guardado? ¿Qué problema causaría?

✏️

---

### Ejercicio 5. Lo mismo en SQL

Las transacciones no son algo propio de Python: son de la base de datos, y Python solo envía las órdenes. En este ejercicio se hace directamente en SQL lo que hizo el programa. Se abre una transacción, se inserta una matrícula, se consulta y se deshace. Al final se compara cada instrucción SQL con su equivalente en Python.

**Pasos:** ejecutar en Workbench, **una instrucción a la vez**:

```sql
USE academia;
START TRANSACTION;
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (12, 6);
SELECT * FROM matriculas WHERE id_estudiante = 12;
ROLLBACK;
SELECT * FROM matriculas WHERE id_estudiante = 12;
```

✏️ Resultado de cada `SELECT`:

```text

```

**Preguntas**

a) ¿Qué instrucción de Python equivale a `COMMIT` y cuál a `ROLLBACK`?

✏️

b) En Workbench hay que escribir `START TRANSACTION`, pero en Python no. ¿Por qué? (Pista: ejercicio 1).

✏️

---

### Investigación

Consultar la documentación de la librería y otras fuentes para entender las piezas que usan los programas: la librería de conexión, el cursor y las consultas parametrizadas. Responder brevemente, con palabras propias:

1. ¿Qué librerías permiten conectar Python con MySQL y cómo se instalan?

✏️

2. ¿Qué es un cursor?

✏️

3. En `02_matricular.py` los datos se pasan con `%s`. ¿Qué es una consulta parametrizada y por qué previene la inyección SQL?

✏️

**Fuentes consultadas:**

-
