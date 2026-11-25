/* =====================================================================
   CASO ACADEMIA · 08_triggers.sql
   TRIGGERS, LO MÍNIMO
   ---------------------------------------------------------------------
   Requisito: recargar la base con 01_esquema.sql y 02_datos.sql justo
   antes de empezar. Recargar también borra los triggers y las tablas
   que cree este archivo.

     PARTE 1 · BEFORE INSERT: corregir los datos con NEW    (1.1 y 1.2)
     PARTE 2 · Validar reglas con SIGNAL                     (2.1 y 2.2)
     PARTE 3 · AFTER: guardar un historial                   (3.1 y 3.2)
     PARTE 4 · Revisar y eliminar triggers                   (4.1 y 4.2)

   Cómo trabajar:
     - Cada parte empieza con un EJEMPLO ya resuelto. Ejecutarlo primero
       y comparar con el resultado que aparece en el comentario.
     - Después vienen dos ejercicios: el primero usa el trigger del
       ejemplo; el segundo pide crear uno parecido.
     - Los ejercicios se hacen EN ORDEN: unos usan los triggers y los
       datos que dejaron los anteriores.
     - En el 1.1 cada estudiante se registra a sí mismo en la tabla
       estudiantes. Donde dice TU_DOCUMENTO, se escribe ese documento.
     - LO QUE VAS A VER explica qué debe pasar y por qué. Si no
       coincide, revisar el SQL o recargar la base y repetir.
     - Los ejercicios marcados con [CAPTURA] van en la entrega: una
       captura de DBeaver (o Workbench) donde se vea el SQL ejecutado y
       el resultado o el mensaje de error.
     - En DBeaver: Ctrl+Enter ejecuta la instrucción donde está el
       cursor; Alt+X ejecuta las seleccionadas o el archivo completo.
       Para los triggers con BEGIN … END, ver la PARTE 2.
     - Cuando hay varias instrucciones seguidas, ejecutarlas una por una
       con Ctrl+Enter: así se ve el resultado o el error de cada una.

   Tablas: profesores, estudiantes, cursos, matriculas, pagos.
   ===================================================================== */

SET NAMES utf8mb4;
USE academia;
SET SQL_SAFE_UPDATES = 0;



/* =====================================================================
   ¿QUÉ ES UN TRIGGER?
   ---------------------------------------------------------------------
   Es un bloque de SQL guardado en la base que MySQL ejecuta SOLO,
   cada vez que ocurre un INSERT, un UPDATE o un DELETE en una tabla.
   Nadie lo llama: se "dispara".

   CREATE TRIGGER nombre
   BEFORE | AFTER  INSERT | UPDATE | DELETE  ON tabla
   FOR EACH ROW
   instrucción;

     BEFORE   se ejecuta ANTES de guardar la fila: sirve para corregir
              o rechazar los datos.
     AFTER    se ejecuta DESPUÉS de guardar la fila: sirve para hacer
              algo más, como dejar un registro en otra tabla.
     FOR EACH ROW   se ejecuta una vez por cada fila afectada.

   Dentro del trigger, la fila se lee con NEW y OLD:

     Evento    NEW (valores nuevos)       OLD (valores anteriores)
     INSERT    sí                         no existe
     UPDATE    sí                         sí
     DELETE    no existe                  sí

   En un BEFORE se puede cambiar NEW (SET NEW.columna = …) y lo que se
   guarda es el valor cambiado.
   ===================================================================== */



/* =====================================================================
   PARTE 1 · BEFORE INSERT: CORREGIR LOS DATOS CON NEW
   ---------------------------------------------------------------------
   Si el trigger tiene una sola instrucción, se escribe directamente
   después de FOR EACH ROW.
   LOWER(texto) lo pasa a minúsculas; TRIM(texto) quita los espacios
   del inicio y del final.
   ===================================================================== */

-- EJEMPLO  Guardar el email de los estudiantes nuevos en minúsculas y
-- sin espacios.
CREATE TRIGGER trg_estudiantes_email
BEFORE INSERT ON estudiantes
FOR EACH ROW
SET NEW.email = LOWER(TRIM(NEW.email));

INSERT INTO estudiantes (documento, nombre, email, ciudad)
VALUES ('1099001', 'Prueba Uno', '  Prueba.Uno@MAIL.com  ', 'Ocaña');

SELECT nombre, email FROM estudiantes WHERE documento = '1099001';
-- Prueba Uno | prueba.uno@mail.com


-- 1.1  [CAPTURA] Registrarse a sí mismo en estudiantes con el documento,
--      el nombre y la ciudad propios, y el email escrito con mayúsculas
--      y con espacios al inicio y al final. Después consultar la fila.
--        INSERT INTO estudiantes (documento, nombre, email, ciudad)
--        VALUES ('TU_DOCUMENTO', 'Tu Nombre', '  Tu.Correo@MAIL.com ', 'Tu Ciudad');
--      LO QUE VAS A VER: el email queda en minúsculas y sin espacios,
--      aunque lo escribiste distinto: el trigger cambió NEW.email antes
--      de guardar la fila.


-- 1.2  Crear el mismo trigger del ejemplo, ahora para la tabla
--      profesores (solo cambian el nombre del trigger y la tabla):
--        CREATE TRIGGER trg_profesores_email
--        BEFORE INSERT ON profesores
--        FOR EACH ROW
--        SET NEW.email = LOWER(TRIM(NEW.email));
--      Probarlo con este profesor y consultar su email:
--        INSERT INTO profesores (nombre, instrumento, email, fecha_ingreso)
--        VALUES ('Andrés Peña', 'Contrabajo', ' APena@Academia.CO ', CURRENT_DATE);
--        SELECT nombre, email FROM profesores WHERE nombre = 'Andrés Peña';
--      LO QUE VAS A VER: Andrés Peña queda con el email
--      apena@academia.co. Del ejemplo solo cambian el nombre del
--      trigger y la tabla.



/* =====================================================================
   PARTE 2 · VALIDAR REGLAS CON SIGNAL
   ---------------------------------------------------------------------
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'mensaje';
       lanza un error con ese mensaje (error 1644). Si lo hace un
       trigger BEFORE, la fila NO se guarda.

   Cuando el trigger tiene varias instrucciones, van entre BEGIN y END,
   cada una terminada en ;. La herramienta corta las instrucciones en
   cada ; y enviaría el CREATE TRIGGER partido en pedazos, así que hay
   que indicarle que todo el bloque es una sola instrucción:

   En DBeaver: seleccionar con el ratón TODO el bloque, desde
   CREATE TRIGGER hasta el END; final, y pulsar Ctrl+Enter. Con el
   texto seleccionado, DBeaver lo envía como una sola instrucción. Si
   sale el error 1064 cerca de un ;, no estaba todo seleccionado.

   En Workbench (o en la consola mysql): escribir DELIMITER // antes del
   bloque, terminarlo con END // en lugar de END; y escribir
   DELIMITER ; después. Seleccionar todo y ejecutar con el rayo.
   ===================================================================== */

-- EJEMPLO  No matricular a nadie en un curso que llegó a su cupo.
CREATE TRIGGER trg_matricula_cupo
BEFORE INSERT ON matriculas
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM matriculas WHERE id_curso = NEW.id_curso)
       >= (SELECT cupo_maximo FROM cursos WHERE id_curso = NEW.id_curso) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El curso está lleno';
    END IF;
END;

-- Piano Avanzado (id 9) tiene cupo 3 y 3 inscritos.
INSERT INTO matriculas (id_estudiante, id_curso)
VALUES (11, 9);
-- Error 1644: El curso está lleno. La matrícula no se guarda.


-- 2.1  Piano Básico tiene cupo 6 y 5 inscritos. Matricularse a sí mismo
--      en ese curso y después intentar matricular a Isabel Romero en el
--      mismo curso:
--        INSERT INTO matriculas (id_estudiante, id_curso)
--        VALUES ((SELECT id_estudiante FROM estudiantes WHERE documento = 'TU_DOCUMENTO'),
--                (SELECT id_curso FROM cursos WHERE nombre = 'Piano Básico'));
--      (y lo mismo con WHERE nombre = 'Isabel Romero').
--      LO QUE VAS A VER: tu matrícula se guarda y el curso llega a 6
--      inscritos. La de Isabel sale con el error El curso está lleno.


-- 2.2  [CAPTURA] Crear el trigger trg_pagos_curso (BEFORE INSERT en
--      pagos) que rechace una Mensualidad sin curso. Es el mismo
--      esquema del ejemplo: cambian el nombre, la tabla, la condición
--      del IF y el mensaje. Se selecciona el bloque completo:
--        CREATE TRIGGER trg_pagos_curso
--        BEFORE INSERT ON pagos
--        FOR EACH ROW
--        BEGIN
--            IF NEW.concepto = 'Mensualidad' AND NEW.id_curso IS NULL THEN
--                SIGNAL SQLSTATE '45000'
--                    SET MESSAGE_TEXT = 'La mensualidad debe indicar el curso';
--            END IF;
--        END;
--      Probarlo con dos Mensualidades de 180000 a tu nombre: una sin
--      curso (id_curso NULL) y otra de Piano Básico.
--      LO QUE VAS A VER: la primera sale con el error La mensualidad
--      debe indicar el curso y no se guarda. La segunda se guarda.



/* =====================================================================
   PARTE 3 · AFTER: GUARDAR UN HISTORIAL
   ---------------------------------------------------------------------
   Un trigger AFTER se ejecuta cuando la fila ya se guardó. Se usa, por
   ejemplo, para AUDITORÍA: dejar en otra tabla qué cambió, quién lo
   cambió y cuándo.
     CURRENT_USER()   el usuario de MySQL que hizo el cambio.
     NOW()            la fecha y la hora actuales.
   ===================================================================== */

-- EJEMPLO  Guardar cada cambio de precio de un curso.
CREATE TABLE historial_precios (
    id_historial     INT            PRIMARY KEY AUTO_INCREMENT,
    id_curso         INT            NOT NULL,
    precio_anterior  DECIMAL(10,2)  NOT NULL,
    precio_nuevo     DECIMAL(10,2)  NOT NULL,
    usuario          VARCHAR(100)   NOT NULL,
    fecha            DATETIME       NOT NULL
);

CREATE TRIGGER trg_cursos_precio
AFTER UPDATE ON cursos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO historial_precios
            (id_curso, precio_anterior, precio_nuevo, usuario, fecha)
        VALUES
            (NEW.id_curso, OLD.precio, NEW.precio, CURRENT_USER(), NOW());
    END IF;
END;

UPDATE cursos SET precio = 95000 WHERE nombre = 'Teoría Musical';
SELECT * FROM historial_precios;
-- 1 fila: curso 8, de 90000.00 a 95000.00, con el usuario y la fecha.


-- 3.1  Subir el precio de Piano Básico a 190000 y consultar el
--      historial.
--      LO QUE VAS A VER: 2 filas: la de Teoría Musical (del ejemplo) y
--      la de Piano Básico, de 180000 a 190000. Nadie escribió en
--      historial_precios: lo hizo el trigger.


-- 3.2  [CAPTURA] Crear la tabla estudiantes_retirados:
--        CREATE TABLE estudiantes_retirados (
--            id_estudiante  INT           NOT NULL,
--            nombre         VARCHAR(100)  NOT NULL,
--            fecha_retiro   DATETIME      NOT NULL
--        );
--      Crear el trigger trg_estudiantes_retiro (AFTER DELETE en
--      estudiantes). Como en la PARTE 1, tiene una sola instrucción (un
--      INSERT), así que no necesita BEGIN … END:
--        CREATE TRIGGER trg_estudiantes_retiro
--        AFTER DELETE ON estudiantes
--        FOR EACH ROW
--        INSERT INTO estudiantes_retirados (id_estudiante, nombre, fecha_retiro)
--        VALUES (OLD.id_estudiante, OLD.nombre, NOW());
--      Probarlo eliminando a Tomás Navarro y consultar la tabla.
--      LO QUE VAS A VER: Tomás Navarro aparece en estudiantes_retirados
--      con la fecha de hoy. Se usa OLD porque en un DELETE no hay
--      valores nuevos: solo los que tenía la fila antes de borrarse.



/* =====================================================================
   PARTE 4 · REVISAR Y ELIMINAR TRIGGERS
   ---------------------------------------------------------------------
   SHOW TRIGGERS;                   lista los triggers de la base, con su
                                    evento, su tabla y su momento.
   SHOW CREATE TRIGGER nombre;      muestra cómo se creó.
   DROP TRIGGER nombre;             lo elimina. La tabla no se toca.
   Un trigger no se puede modificar: se elimina y se crea de nuevo.
   ===================================================================== */

-- EJEMPLO
SHOW TRIGGERS;
SHOW CREATE TRIGGER trg_cursos_precio;
DROP TRIGGER trg_profesores_email;


-- 4.1  Ejecutar SHOW TRIGGERS y mirar las columnas Trigger, Event,
--      Table y Timing.
--      LO QUE VAS A VER: 5 triggers: 2 en estudiantes, 1 en matriculas,
--      1 en pagos y 1 en cursos. profesores ya no aparece, porque el
--      ejemplo eliminó trg_profesores_email.


-- 4.2  [CAPTURA] Eliminar trg_matricula_cupo, matricular a Isabel Romero
--      en Piano Intermedio (cupo 4, ya lleno) y ejecutar SHOW TRIGGERS.
--      LO QUE VAS A VER: la matrícula de Isabel se guarda aunque el
--      curso estaba lleno: sin el trigger, nada impide pasar el cupo.
--      SHOW TRIGGERS muestra 4 triggers.
