/* =====================================================================
   CASO ACADEMIA · 03_ejercicios.sql
   PRÁCTICA DE DDL, DML Y CONSULTAS
   ---------------------------------------------------------------------
   Requisito: haber ejecutado 01_esquema.sql y luego 02_datos.sql.

   Este archivo tiene tres partes:
     PARTE 1 · DDL         cambiar la ESTRUCTURA (ejercicios 1.1 a 1.6)
     PARTE 2 · DML         cambiar los DATOS     (ejercicios 2.1 a 2.11)
     PARTE 3 · Consultas   leer los datos        (ejercicios 3.1 a 3.11)

   Cómo trabajar:
     - Escribir la solución debajo de cada enunciado y ejecutarla sola
       (Ctrl+Enter en la instrucción, Alt+X / Ctrl+Shift+Enter un bloque).
     - Después de cada cambio, comprobarlo con DESCRIBE o SELECT.
     - Las partes 1 y 2 se hacen en orden: unas dependen de otras.
     - ANTES de la parte 3, recargar la base (01_esquema.sql y
       02_datos.sql) para trabajar con los datos originales.

   Tablas: profesores, estudiantes, cursos, matriculas, pagos.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;

-- Workbench bloquea los UPDATE y DELETE que no filtran por una clave
-- (error 1175). Esta línea lo permite solo durante esta sesión.
SET SQL_SAFE_UPDATES = 0;

-- Para empezar: reconocer la estructura
SHOW TABLES;
DESCRIBE cursos;
DESCRIBE pagos;


/* =====================================================================
   PARTE 1 · DDL — CAMBIAR LA ESTRUCTURA
   ===================================================================== */

-- 1.1  La academia quiere registrar sus salas. Crear la tabla "salas" con:
--      id_sala (clave primaria autoincremental), nombre (obligatorio y
--      sin repetirse) y capacidad (obligatoria y mayor que cero, con una
--      restricción llamada chk_capacidad).


-- 1.2  Cada curso se dicta en una sala. Agregar a "cursos" la columna
--      id_sala y la clave foránea fk_curso_sala hacia salas.


-- 1.3  Agregar a "estudiantes" la columna acudiente (texto de hasta 80
--      caracteres), ubicada justo después de nombre.


-- 1.4  Hay instrumentos con nombres largos. Ampliar la columna
--      instrumento de "profesores" a 60 caracteres sin perder el NOT NULL.


-- 1.5  Crear la tabla "asistencias": id_asistencia, id_estudiante,
--      id_curso, fecha y presente (BOOLEAN, por defecto TRUE).
--      Reglas: un estudiante no puede tener dos registros del mismo curso
--      el mismo día, y solo se registra asistencia de quien esté
--      MATRICULADO en ese curso.
--      Pista: la clave foránea apunta a la clave primaria de matriculas.


-- 1.6  Al final se decidió no guardar el acudiente: eliminar esa columna.



/* =====================================================================
   PARTE 2 · DML — CAMBIAR LOS DATOS
   ===================================================================== */

-- 2.1  Registrar tres salas: 'Sala Beethoven' (6 personas),
--      'Sala Mozart' (10) y 'Auditorio' (20).


-- 2.2  Asignar salas: los cursos de piano a la Sala Beethoven, Teoría
--      Musical al Auditorio y todos los demás a la Sala Mozart.
--      ¿Cuántas filas afectó cada UPDATE?


-- 2.3  Registrar a la estudiante Camila Duarte: documento 1098013,
--      camila@mail.com, 3113334455, Aguachica, nacida el 2009-01-19.
--      No indicar id ni fecha de registro.
--      PREGUNTA: ¿qué valores tomaron esas dos columnas y por qué?


-- 2.4  Tomás Navarro (id 11) se matricula hoy en Violín Inicial (id 6) y
--      paga la cuota de ingreso (40000) y la primera mensualidad del curso.


-- 2.5  Ejecutar las tres instrucciones y explicar cada error:
--      a) Matricular de nuevo a Tomás en Violín Inicial.
--      b) Registrar un pago de Tomás de 50000 con concepto 'Donación'.
--      c) Matricular al estudiante 99 en el curso 1.


-- 2.6  Subir 5 % el precio de los cursos de nivel Intermedio.


-- 2.7  Asignar a Felipe Arango (profesor 6) el curso Teoría Musical.


-- 2.8  Daniela Torres (id 3) actualiza sus datos: correo
--      daniela@mail.com y teléfono 3150009988 (en un solo UPDATE).


-- 2.9  Isabel Romero (id 12) se retira de la academia: eliminarla.
--      PREGUNTA: ¿por qué falla el primer intento? ¿Qué hay que borrar
--      antes?


-- 2.10 Andrés Cárdenas (id 10) cancela Guitarra Eléctrica (id 4):
--      eliminar SOLO esa matrícula.


-- 2.11 Dejar la estructura como al principio: eliminar asistencias, la
--      columna id_sala de cursos y la tabla salas.
--      PREGUNTA: ¿en qué orden hay que hacerlo y por qué?



/* =====================================================================
   PARTE 3 · CONSULTAS
   ANTES: recargar la base con 01_esquema.sql y 02_datos.sql.
   ===================================================================== */

-- 3.1  Listar cada profesor con sus cursos: profesor, curso, cupo máximo
--      y precio.
--      PREGUNTA: hay 8 cursos, ¿cuál falta y por qué?


-- 3.2  Repetir 3.1 de modo que aparezcan TODOS los cursos.


-- 3.3  Obtener los 3 mayores pagos: nombre del estudiante, concepto y
--      valor.


-- 3.4  Obtener el total pagado por concepto.


-- 3.5  Igual que 3.4, agregando cuántos pagos hay de cada concepto y
--      ordenando de mayor a menor total.


-- 3.6  Listar los estudiantes con sus cursos matriculados: id y nombre
--      del estudiante, curso, precio, profesor y fecha de matrícula, de la
--      más reciente a la más antigua.
--      PREGUNTA: hay 17 matrículas, ¿por qué salen menos filas?


-- 3.7  Para cada matrícula, mostrar estudiante, curso, fecha de
--      matrícula y el total que ese estudiante ha pagado POR ESE CURSO.
--      Pista: el pago se relaciona con la matrícula por dos columnas.


-- 3.8  Para cada curso: cupo máximo, cantidad de matriculados y cupos
--      libres. Deben aparecer también los cursos sin estudiantes.


-- 3.9  Listar los estudiantes que no están matriculados en ningún curso.


-- 3.10 Total recaudado por cada profesor (pagos de sus cursos), de mayor
--      a menor.


-- 3.11 Ciudades con 3 o más estudiantes y cuántos tiene cada una.

