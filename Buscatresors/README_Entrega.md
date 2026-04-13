# Guia d'Execució i Demostració: Buscatresors (Node.js)

Dins d'aquest directori trobem l'Exercici "Joc JS cmd" per a la cerca i control d'estats.

## 🛠️ Requisits d'Instal·lació
1. **Node.js** instal·lat a la màquina.

## 🚀 Com Executar-ho
1. Obre la terminal i navega fins al directori que conté l'arxiu principal (`index.js`):
   ```bash
   cd DAM2MP09-Exercicis00Processos/Buscatresors/buscatresors
   ```
2. Executa el script de node:
   ```bash
   node index.js
   ```

## 🎥 Com Demostrar el Seu Ús
Quan s'iniciï, veuràs l'*ASCII Art* i el *tauler d'interrogrants* a la mateixa terminal.
1. Demostra el funcionament general posant primer `help` per a llistar els comandaments.
2. Comença la recerca teclejant: `destapar <fila> <columna>` (exemple: `destapar 1 1`).
   - L'script processarà si has trobat el tresor (una mica irreal si és la casella de test), o calcularà mitjançant **Distància de Manhattan** quina altra lletra s'imprimirà per informar de la llunyania al tresor més preuat.
3. Prem les instruccions `trampa`, la qual descobrirà automàticament on estan tots ells al taulel ocult.
4. Escriu `guardarProva` (o `sortir` depenent si salta el quadre de Save en tancar).
5. Mostra l'arxiu local generat temporalment amb extensió JSON a la carpeta arrel demostrant que l'estat perdura al reinici si prems `carregar`.

## 🧠 Com Funciona Internament?
- Usa el mòdul de paquets primaris `readline` de Node per la captació `stdin/stdout` i generar el format iteratiu síncron sobre l'esquema matricial de dades on col·loquem el contingut per coordenada 2D.
- Al generar el taulell original es fa un rand() escampant "16" ítems `X` abans de començar per les `N*M` files x columnes.
- El Guardat s'encarrega d'escriure massius strings usant estructures del mòdul File system natiu combinant el mètode paral·lel de lectura d'`fs.writeFileSync` / `readFileSync` en tipologies `.json`.
