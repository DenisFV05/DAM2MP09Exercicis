# Guia d'Execució i Demostració: Encriptació RSA

Aquest document explica com executar, validar i demostrar l'aplicació d'encriptació RSA.

## 🛠️ Requisits d'Instal·lació

Per compilar i executar aquest projecte necessites:
1.  **Flutter SDK** (versió 3.19 o superior) instal·lat i configurat al `PATH`.
2.  **Dart SDK** (ja inclòs amb Flutter).
3.  Eines de desenvolupament per a la plataforma objectiu (ex: Visual Studio per a Windows, Xcode per a macOS).
4.  *(Opcional però recomanat)* Un parell de claus SSH existents (una clau pública i una privada a `~/.ssh/`).

## 🚀 Com Executar-ho

Troba't dins del directori del projecte (`DAM2MP09-Exercicis00Processos/Encriptacio_app`) i segueix aquests passos:

1.  **Baixar dependències:** Instal·la els paquets necessaris executant:
    ```bash
    flutter pub get
    ```
2.  **Executar en mode desenvolupament:** Per obrir l'aplicació directament a l'escriptori:
    ```bash
    flutter run -d windows  # Canvia "windows" per "macos" o "linux" segons el teu SO
    ```
3.  **Compilar per a producció (Release):** Per generar l'executable final (requisit de l'exercici):
    ```bash
    flutter build windows
    ```
    Trobaràs l'executable final a `build/windows/x64/runner/Release/encriptacio_app.exe`. (Aquest és l'arxiu que usaràs per crear l'instal·lador .msi amb Inno Setup o eines similars).

## 🎥 Com Demostrar el Seu Ús

Per demostrar-li a algú (o al professor) com funciona l'aplicació, segueix aquest flux:

### 1. Demostrar l'Encriptació:
1. Obre l'aplicació i queda't a la primera pestanya "Encriptar".
2. Fes clic a **"🔓 Clau Pública RSA"** i selecciona una clau pública real (per exemple, `id_rsa.pub` de la teva carpeta `~/.ssh`).
3. Fes clic a **"📄 Arxiu per encriptar"** i tria un arxiu qualsevol (un document de text petit o una imatge).
4. Fes clic al botó **"Encriptar"**.
5. *Efecte:* Es generarà un nou arxiu al costat de l'original amb l'extensió `.encrypted`. Intenta obrir aquest nou arxiu per demostrar que el seu contingut ara és completament inintel·ligible.

### 2. Demostrar la Desencriptació:
1. Canvia a la pestanya de sota **"Desencriptar"**.
2. Observa com l'app ja suggereix per defecte la teva clau privada local (ex: `C:\Users\Denis\.ssh\id_rsa`). Si no en tens, selecciona'n la teva.
3. Fes clic a **"📄 Arxiu encriptat"** i selecciona precisament el fitxer `.encrypted` que has generat en el pas anterior.
4. Fes clic a **"💾 Arxiu destí"** per elegir el nom final (per defecte et proposarà `.decrypted`).
5. Fes clic a **"Desencriptar"**.
6. *Efecte:* Mostra com el fitxer resultant torna a ser l'original completament llegible i sense danys.

## 🧠 Com Funciona Internament?

L'aplicació no utilitza encriptació simètrica bàsica, sinó **RSA de Clau Pública/Privada** assistida per **pointycastle**.

1.  **Parseig ASN.1**: Les claus `.pem` o `.pub` sovint venen codificades en PKCS#8 o formats estranys. L'arxiu `crypto_service.dart` conté una lògica que fa una dissecció a nivell de bytes ASN.1 per extreure'n el `Modulus` i l'`Exponent`.
2.  **Padding OAEP**: S'utilitza el farciment segur `OAEPEncoding` per evitar atacs matemàtics de predictibilitat a l'hora d'encriptar blocs iguals.
3.  **Processament per Blocs ("Chuncking")**: Si un fitxer ocupa més del que permet el xifrat d'una clau de 2048-bit (uns pocs centenars de bytes), RSA col·lapsa directament. Així doncs, l'escript per encriptar divideix l'arxiu gegant en *chunks* petits (màxim teòric per 2048-bit menys el pes de l'OAEP), encripta un per un i els va empaquetant al fitxer `.encrypted` precedits per un bloc d'informació de 4 bytes que conté la mida de dades xifrada, de manera que al moment de desxifrar sàpiga llegir exactament el buffer original de la memòria sense donar errors.
