# Guia d'Execució i Demostració: Base de Dades Temàtica

Aquest repte compta de dues capes tecnològiques comunicades entre elles: Una Web API i una eina Frontend de consum d'imatges i texts ("DB temàtica FTR").

## 🛠️ Requisits d'Instal·lació
1. **Node.js**: Per iniciar la part Express API on allotja l'arxiu `.json` i `assets` d'imatges.
2. **Flutter SDK**: A l'aplicació per veure els resultats directes per mòbil/web/desktop.

## 🚀 Com Executar-ho
Per donar suport a l'APP s'ha d'enllaçar la connexió al Server backend prèviament:

1. **Aixecar el Servidor Backend (NodeJS):**
   ```bash
   cd DAM2MP09-Exercicis00Processos/DBTematica/server
   npm install
   node index.js
   ```
   *Assegura't de visualitzar el seu inici exitós que reportarà córrer lliure pel port "3000"*

2. **Inicie l'aplicació Mobil/Desktop (Flutter):**
   *(Obre un altre terminal separat per a no tancar el primer NodeJS de fons!)*
   ```bash
   cd DAM2MP07Exercicis/DBTematica/comida_flutter
   flutter run -d windows  # (canvia -d pel SO de disseny visual preferint, com "chrome")
   ```

## 🎥 Com Demostrar el Seu Ús
1. **Inici Ràpid (Frontend Flutter):** Explica a l'auditori com acabes d'enllaçar les vistes amb una funció asíncrona real-time a l'host on hi tens allotjat el Node anterior. 
2. **Pantalla inicial**: Veuràs els tres grups temàtics que demanava el professor (Ex: Postres, Carns, Verdures - depenen el teu disseny). Obre una Llista.
3. **Navegació cap a detalls**: Ens agafarà, a mode *ListView*, cadascun dels integrants de la categoria elegida; punxa sobre un específic! Entra cap al costat amb detalls a cos sencer i posa atenció forta que hi consta **d'una fotografia extreta 100% de manera remota al Servidor a través d'una crida d'enllaç HTTP a l'imatge on s'indica el link local!**
4. Quan ho validi el professor atura un segon el Servidor `Ctrl+C` al node. Obre el client un altre cop: Veuràs que de sobte la Base De Dades petarà demostrant-li al avaluador el tractament autèntic sobre peticions Get de API Server desconnectat (`Connection Refused`).

## 🧠 Com Funciona Internament?
A diferència de petits projectes, s'abracen mètodes com els usats actualment a les indústries reals:
- **Part Servidor `index.js` (MP09):** Ha configurat i dividit l'enrutament amb l'eina `Express` de la dependència del package.json en Endpoint "POST" específics. A part, empra el procés pel Request local de `/api/image/:filename` com indica l'enunciat MP09 servint a la vista la via del fitxer en directe sense revelar la seguretat del Back.
- **Part Client `api_service.dart` (MP07):** Aquest directori incorpora les tasques pesades. Importa dependències del canal `dart:convert` i interpel·la via requests amb el connector "localhost" (configurat en fitxer d'assets per variables d'Entorn normalment), i mapeja respostes automàtiques en construcció del Canvas ListView.
