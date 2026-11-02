"""
Ejercicio 1 · Comprobar que Python se conecta a MySQL.

Ejecutar desde esta carpeta:   py 01_conexion.py
"""

import mysql.connector

# Abrir la conexión con el servidor
conexion = mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    password="root",      # cambiar por la contraseña de root de MySQL
    database="academia",
)

# El cursor ejecuta el SQL y recorre los resultados
cursor = conexion.cursor()
cursor.execute("SELECT nombre, ciudad FROM estudiantes")
for nombre, ciudad in cursor:
    print(nombre, "-", ciudad)

print("autocommit:", conexion.autocommit)

# Cerrar el cursor y la conexión
cursor.close()
conexion.close()
