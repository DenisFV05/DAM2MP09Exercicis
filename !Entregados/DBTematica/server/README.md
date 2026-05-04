# DBTematica - Servidor (Node.js)

## 🚀 Cómo Ejecutar

```powershell
npm install
node index.js
```

---

## 🏗️ Análisis del Código y Flujo

Este proyecto implementa una **API RESTful** básica utilizando **Express.js**. Su función es actuar como backend, centralizando los datos para que clientes (como la app Flutter) los consuman.

### Arquitectura Servidor

1.  **Instanciación (`express`):**
    *   Se crea la app `const app = express()`.
    *   Se define el puerto (ej. 3000).

2.  **Middleware:**
    *   **CORS (`cors()`):** Crítico. Por defecto, los navegadores y algunas apps bloquean peticiones a dominios diferentes por seguridad. Este middleware añade cabeceras HTTP (`Access-Control-Allow-Origin`) para permitir que la app Flutter (que corre en "otro lugar") pueda pedir datos.

3.  **Enrutamiento (`Routes`):**
    *   Se definen "endpoints" URL. Ej: `app.get('/api/comidas', ...)`.
    *   Cuando llega una petición a esa URL, se ejecuta una función callback `(req, res)`.

4.  **Gestión de Datos:**
    *   En este ejemplo académico, los datos probablemente están en un array en memoria o un archivo JSON local (mock database).
    *   La función envía los datos usando `res.json(datos)`. Esto automáticamente pone la cabecera `Content-Type: application/json` y convierte el objeto JS a texto JSON.

### Flujo de una Petición
1.  **Request:** Cliente Flutter hace GET `/api/comidas`.
2.  **Express:** Recibe la petición, pasa por el middleware CORS.
3.  **Handler:** Ejecuta la función de la ruta.
4.  **Query:** (Opcional) Consulta DB/Archivo.
5.  **Response:** Envía JSON al cliente.

Es el modelo estándar de la web moderna (Backend API + Frontend Client).
