"""
Ejercicios 2 a 4 · Matricular a un estudiante en un curso y registrar su pago.

Las dos operaciones forman UNA transacción: o se guardan las dos, o ninguna.

Ejecutar desde esta carpeta:   py 02_matricular.py
"""

import mysql.connector

# Datos de la matrícula (se cambian en cada ejercicio)
ID_ESTUDIANTE = 11      # Tomás Navarro
ID_CURSO = 6            # Violín Inicial
VALOR = 200000

conexion = mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    password="root",      # cambiar por la contraseña de root de MySQL
    database="academia",
)
cursor = conexion.cursor()

try:
    # Operación 1: la matrícula
    # Consulta parametrizada: cada %s se reemplaza por un valor de la tupla
    cursor.execute(
        "INSERT INTO matriculas (id_estudiante, id_curso) VALUES (%s, %s)",
        (ID_ESTUDIANTE, ID_CURSO),
    )
    print("1. Matrícula insertada")

    # Operación 2: el pago de la mensualidad
    cursor.execute(
        "INSERT INTO pagos (id_estudiante, id_curso, valor, concepto) "
        "VALUES (%s, %s, %s, 'Mensualidad')",
        (ID_ESTUDIANTE, ID_CURSO, VALOR),
    )
    print("2. Pago insertado")

    conexion.commit()       # todo salió bien: se guardan los cambios
    print("COMMIT: matrícula y pago guardados")

except mysql.connector.Error as error:
    conexion.rollback()     # algo falló: se deshace todo lo de la transacción
    print("ERROR:", error.msg)
    print("ROLLBACK: no se guardó nada")

cursor.close()
conexion.close()
