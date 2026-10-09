/* =====================================================================
   LABORATORIO 09 · RETO INTEGRADOR — PROGRAMA DE PUNTOS
   DDL + DML + consultas + TCL + DCL en un solo encargo
   ---------------------------------------------------------------------
   Requisito: base tienda recién cargada con 00_preparacion.

   La tienda lanza un programa de fidelización: cada compra entregada
   da puntos, y los puntos se canjean por productos. No hay guía: cada
   etapa se resuelve con lo aprendido en los laboratorios 01 a 08. Las
   etapas se resuelven EN ORDEN y cada una indica el resultado que debe
   obtenerse para poder continuar.

   Reglas del programa:
     - 1 punto por cada 10.000 pesos del total de un pedido (sin
       decimales, redondeando hacia abajo).
     - Solo dan puntos los pedidos en estado 'Entregado'.
     - Niveles:  Oro (3.000 puntos o más) · Plata (1.000 o más) ·
       Bronce (más de 0) · Sin puntos.
     - El saldo de puntos de un cliente nunca puede ser negativo.
   ===================================================================== */

USE tienda;
SET SQL_SAFE_UPDATES = 0;


/* ETAPA 1 · DDL: preparar la estructura
   a) Agregar a clientes la columna puntos: entero, obligatorio, 0 por
      defecto, con una restricción que impida valores negativos.
   b) Crear la tabla movimientos_puntos, que registra cada vez que un
      cliente gana o gasta puntos:
        - id_movimiento  clave primaria autoincremental
        - id_cliente     obligatorio, clave foránea
        - id_pedido      opcional (los canjes no tienen pedido), clave
                         foránea
        - puntos         entero, positivo si gana y negativo si canjea;
                         nunca cero
        - motivo         texto obligatorio de hasta 60 caracteres
        - fecha          fecha y hora; por defecto, el momento actual
   c) Crear un índice sobre la fecha de los movimientos.
*/
-- Solución:



/* ETAPA 2 · DML: cargar los puntos históricos
   Con UN solo INSERT … SELECT, generar un movimiento por cada pedido
   entregado: los puntos según la regla, motivo 'Compra' y como fecha la
   del pedido. No se insertan movimientos de 0 puntos.
   Resultado esperado: 138 movimientos que suman 48.178 puntos.
*/
-- Solución:



/* ETAPA 3 · DML: calcular el saldo de cada cliente
   Con UN solo UPDATE, dejar en clientes.puntos la suma de los
   movimientos de cada cliente.
   Resultado esperado: 27 clientes actualizados.
*/
-- Solución:



/* ETAPA 4 · Consultas
   a) Ranking de clientes: nombre, ciudad, puntos, nivel y puesto (con
      una función de ventana), del que más puntos tiene al que menos.
      Resultado esperado: 30 filas; el primer puesto tiene 8.084 puntos.
   b) Cantidad de clientes y total de puntos por nivel.
      Resultado esperado: 5 Oro, 6 Plata, 16 Bronce y 3 Sin puntos.
   c) Clientes cuyos puntos superan el promedio de los clientes que
      tienen puntos.
*/
-- Solución:



/* ETAPA 5 · Vista
   Crear la vista v_puntos_clientes con: id_cliente, nombre, ciudad,
   puntos, nivel, cantidad de movimientos y fecha del último movimiento.
   Deben aparecer los 30 clientes. Usarla para listar los clientes Oro.
*/
-- Solución:



/* ETAPA 6 · Transacciones: canjear puntos
   Un canje toca tres tablas: se registra el movimiento (negativo), se
   descuenta el saldo del cliente y sale una unidad del inventario.
   a) Santiago Ardila (cliente 7) canjea 190 puntos por unos audífonos
      de diadema (producto 23). Escribir la transacción y confirmarla.
      Resultado esperado: el cliente pasa de 1.859 a 1.669 puntos y el
      producto de 22 a 21 unidades.
   b) Nicolás Barbosa (cliente 25) intenta canjear 5.000 puntos, que no
      tiene. Escribir la misma transacción, ejecutarla paso a paso y
      resolver el error como corresponde. Comprobar que no quedó ningún
      movimiento suyo con puntos negativos.
*/
-- Solución:



/* ETAPA 7 · Control de consistencia
   Escribir una consulta que muestre los clientes cuyo saldo
   (clientes.puntos) NO coincide con la suma de sus movimientos.
   Resultado esperado: cero filas. Si aparece alguna, hay un error en
   una etapa anterior.
*/
-- Solución:



/* ETAPA 8 · DCL: la cuenta del área de fidelización
   a) Crear el rol rol_fidelizacion con estos permisos y ninguno más:
        - consultar la vista v_puntos_clientes;
        - consultar e insertar en movimientos_puntos;
        - de la tabla clientes: consultar solo id_cliente, nombre y
          puntos, y modificar solo puntos.
   b) Crear la cuenta 'tienda_fidelizacion'@'localhost' con ese rol
      activo por defecto.
   c) Conectarse con la cuenta y demostrar con seis instrucciones qué
      puede hacer (dos) y qué no (cuatro), anotando cada código de error.
      Si alguna prueba modifica datos, dejarlos como estaban.
*/
-- Solución:



/* ETAPA 9 · Limpieza
   Dejar la base exactamente como estaba antes de la etapa 1, sin volver
   a ejecutar 00_preparacion: sin la cuenta, el rol, la vista, la tabla
   y la columna nuevas, y con el stock del producto 23 en su valor
   original.
*/
-- Solución:



/* ETAPA 10 · Informe (responder en el cuaderno)
   a) Clasificar cada etapa según el sublenguaje que usó: DDL, DML, DCL
      o TCL.
   b) El saldo se guarda en clientes.puntos, pero también se puede
      calcular sumando movimientos_puntos. ¿Qué ventaja y qué riesgo
      tiene guardar un dato que se puede calcular? ¿Qué etapas existen
      precisamente para controlar ese riesgo?
   c) ¿Por qué el canje debe ser una transacción? Describir un estado
      inconsistente que podría quedar sin ella.
*/
