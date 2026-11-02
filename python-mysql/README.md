# Python y MySQL · Actividad investigativa sobre transacciones

**Bases de Datos I** — Actividad investigativa para hacer en casa; lo aprendido se pone en práctica en la clase de transacciones. Se instala Python con una librería de conexión a MySQL y, con un programa ya escrito, se observa cómo funcionan `COMMIT` y `ROLLBACK` cuando una operación tiene varios pasos.

---

## 1. Preparar el equipo (Windows)

**Paso 1. Instalar Python.** Abrir una terminal (tecla **Windows**, escribir `cmd`, **Enter**) y ejecutar `py --version`. Si no aparece una versión, descargar Python desde https://www.python.org/downloads/ e instalarlo. **En la primera pantalla del instalador, marcar "Add python.exe to PATH".** Luego cerrar la terminal y abrir otra.

**Paso 2. Instalar la librería:**

```
py -m pip install mysql-connector-python
```

**Paso 3. Preparar MySQL.**
- El servicio **MySQL80** debe estar en marcha (*Servicios* de Windows).
- La base `academia` debe estar cargada (`academia/01_esquema.sql` y `academia/02_datos.sql`).
- En `01_conexion.py` y `02_matricular.py`, cambiar `password="root"` por la contraseña de root que se definió al instalar MySQL.

**Paso 4. Probar:**

```
cd C:\ruta\donde\esta\practicas-sql\python-mysql
py 01_conexion.py
```

Si aparece la lista de estudiantes, el equipo está listo. Se recomienda abrir la carpeta `python-mysql` en VS Code y usar su terminal (*Terminal → New Terminal*).

---

## 2. Los archivos

| Archivo | Qué hace |
|---|---|
| `01_conexion.py` | Se conecta a `academia` y lista los estudiantes |
| `02_matricular.py` | Matricula a un estudiante y registra su pago dentro de una transacción |
| `ejercicios.md` | 5 ejercicios y 3 preguntas de investigación. **Es la entrega** |

**Entrega:** `ejercicios.md` con todos los `✏️` completos.

**Al terminar**, recargar la base `academia`: los ejercicios agregan una matrícula y un pago.

---

## 3. Problemas frecuentes

| Mensaje | Qué hacer |
|---|---|
| *"py" no se reconoce como un comando...* | Reinstalar Python marcando **"Add python.exe to PATH"**. |
| `ModuleNotFoundError: No module named 'mysql'` | Falta el paso 2. Ejecutar siempre con `py`, no con `python`. |
| `can't open file ...` | La terminal no está en la carpeta `python-mysql`: revisar el `cd`. |
| `Can't connect to MySQL server on '127.0.0.1:3306'` | El servicio MySQL80 está detenido: iniciarlo en *Servicios* de Windows. |
| `Access denied for user 'root'` | La contraseña del programa no es la correcta (paso 3). |
| `Unknown database 'academia'` | Falta cargar la base (paso 3). |
