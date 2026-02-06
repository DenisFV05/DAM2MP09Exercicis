# Buscatresors (Node.js)

## 🚀 Cómo Ejecutar

```powershell
node index.js
```

---

## 🏗️ Análisis del Código y Flujo

Este juego es un excelente ejemplo de **programación asíncrona interactiva** en Node.js sin usar frameworks externos.

### Componentes Clave

1.  **`readline` (Módulo Nativo):**
    *   Node.js es asíncrono por naturaleza. No tiene un `input()` bloqueante simple como Python o Dart.
    *   Usamos `readline.createInterface`. Esto crea un *listener* que espera eventos de la entrada estándar (`stdin`).
    *   **Recursividad Asíncrona:** La función `preguntar()` no es un bucle `while`. Se llama a sí misma dentro del callback de `rl.question`. Esto mantiene el programa vivo esperando input infinitamente hasta que decidimos cerrar.

2.  **Lógica del Tablero:**
    *   Doble matriz: `this.tauler` (lo que ve el usuario, caracteres) y `this.tresors` (booleans ocultos, true=hay tesoro).
    *   **Distancia Manhattan:** La mecánica central es la pista de "frío/caliente".
    ```javascript
    Math.abs(fila1 - fila2) + Math.abs(col1 - col2)
    ```
    *   Esta fórmula calcula cuántos pasos (verticales + horizontales) necesitas para llegar al tesoro más cercano, sin diagonales.

3.  **Persistencia (File System `fs`):**
    *   `guardarPartida`: Serializa todo el objeto de estado (`JSON.stringify`) y lo escribe a disco.
    *   `carregarPartida`: Lee el texto, lo parsea (`JSON.parse`) y **hidrata** el estado del objeto `joc` actual sobrescribiendo sus variables (`this.tauler`, etc.).

### Flujo de Comandos (`processarComanda`)

Implementa un patrón de **Intérprete de Comandos**:
1.  Recibe string: "destapar A5".
2.  Normaliza: `trim()`, `toLowerCase()`.
3.  Tokeniza (`split`): Separa el verbo ("destapar") del argumento ("A5").
4.  Switch Case: Decide qué método llamar.
5.  Si el comando no es un verbo conocido, intenta parsearlo como coordenada directa (atajo de usabilidad).
