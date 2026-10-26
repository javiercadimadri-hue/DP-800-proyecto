# Proyecto DP-800: DevPortal Inteligente con SQL Server 2025

> **Nota:** *Nexar Payments* es una **empresa ficticia** creada exclusivamente como caso de estudio práctico para la evaluación y demostración de competencias en la certificación **Microsoft DP-800**.

Este proyecto implementa un portal interno de desarrolladores (DevPortal) para la empresa ficticia **Nexar Payments**. Modifica una base de datos relacional tradicional para transformarla en una base de datos vectorial utilizando las capacidades nativas de **SQL Server 2025**, lo que permite realizar búsquedas semánticas y habilitar un flujo **RAG (Retrieval-Augmented Generation)** junto con **GitHub Copilot**.


## 📁 Estructura del Proyecto

```text
Proyecto DP-800/
├── ai/
│   └── vectorizar_microservicios.py
├── database/
│   ├── ConversionABDDVectorial.sql
│   ├── CreacionBBDDRelacional.sql
│   ├── Optimizacion.sql
│   ├── procedimientoAlmacenado.sql
│   └── SeguridadYPermisos.sql
├── test/
│   ├── ValidarCargaYVolumen.sql
│   ├── ValidarIntegridadVectorial.sql
│   ├── ValidarLaBusquedaSemantica.sql
│   ├── ValidarOptimizacion.sql
│   └── ValidarSeguridadYRoles.sql
└── README.md
```
---

## Orden de Ejecución de los Scripts

Para desplegar el proyecto correctamente en un entorno local, sigue el orden estricto de ejecución de cada archivo:

### 1. `database/CreacionBBDDRelacional.sql`
* **Qué hace:** Crea la base de datos `NexarDevPortal` y define la estructura relacional inicial (tablas `Equipos`, `Microservicios`, `EndpointsAPI`) con sus claves primarias, foráneas y datos de prueba (*mocks*).


### 2. `database/SeguridadYPermisos.sql`
* **Qué hace:** Aplica el principio de mínimo privilegio. Define roles de base de datos (`AdminDevPortal`, `DeveloperUser`) y configura los permisos de lectura y escritura mediante sentencias `GRANT` y `DENY`.


### 3. `database/ConversionABDDVectorial.sql`
* **Qué hace:** Evoluciona las tablas `Microservicios` y `EndpointsAPI` añadiendo columnas nativas del tipo `VECTOR(1536)` propias de SQL Server 2025.


### 4. `ai/vectorizar_microservicios.py`
* **Qué hace:** Script en Python (desarrollado con asistencia de IA) que se conecta mediante `pyodbc`, toma las descripciones en texto plano, genera *embeddings* simulados de 1536 dimensiones y guarda los vectores en la base de datos.


### 5. `database/procedimientoAlmacenado.sql`
* **Qué hace:** Implementa el procedimiento almacenado `BuscarMicroservicioSemantico`. Recibe un vector de búsqueda y ejecuta una consulta comparativa utilizando la función nativa `VECTOR_DISTANCE` (métrica del coseno) para devolver los resultados semánticamente más cercanos.


### 6. `database/Optimizacion.sql`
* **Qué hace:** Corrige la limitación de tipos de datos antiguos pasando la columna de la tabla de endpoints de `TEXT` a `VARCHAR(MAX)` y crea un **Índice No Clúster Cubriente (Covering Index)** en `EndpointsAPI` para sustituir un *Table Scan* por un *Index Seek*.


---

## Ejemplos de Consultas en Lenguaje Natural (Flujo RAG con Copilot)

Gracias al almacenamiento de vectores y a la función `VECTOR_DISTANCE`, el desarrollador no necesita redactar preguntas complejas. Basta con hacer consultas cortas y directas en el chat de GitHub Copilot:

### Consulta 1: Módulo de Pagos
* **Pregunta del desarrollador:** `¿Dónde hago un cobro con tarjeta?`
* **Contexto recuperado por SQL:** `PaymentGateway` | `/api/v1/payments/charge` (POST)
* **Respuesta de Copilot:** 
  > Debes utilizar el servicio **PaymentGateway** mediante la ruta `POST /api/v1/payments/charge`.

### Consulta 2: Módulo de Autenticación
* **Pregunta del desarrollador:** `¿Cómo renuevo un token expirado?`
* **Contexto recuperado por SQL:** `AuthService` | `/api/v1/auth/refresh` (POST)
* **Respuesta de Copilot:** 
  > Llama al endpoint `POST /api/v1/auth/refresh` perteneciente al servicio **AuthService**.

### Consulta 3: Módulo de Notificaciones
* **Pregunta del desarrollador:** `¿Qué API manda un email o mensaje?`
* **Contexto recuperado por SQL:** `NotificationWorker` | `/api/v1/notifications/send` (POST)
* **Respuesta de Copilot:** 
  > Usa el microservicio **NotificationWorker** en la ruta `POST /api/v1/notifications/send`.