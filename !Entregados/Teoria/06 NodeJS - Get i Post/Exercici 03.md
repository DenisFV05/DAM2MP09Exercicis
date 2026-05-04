<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2024</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

# Exercici 03, DB temàtica

Fes un servidor NodeJS que respongui a peticions per a l'aplicació de l'**"Exercici 04"** de *Desenvolupament d'interfícies*.

Com a mínim hi ha d'haver aquestes peticions:

- Demanar categories (POST)
- Demanar items d'una categoria (POST)
- Demanar informació d'un ítem (POST)
- Demanar items d'una cerca (POST)
- Retornar la imatge d'un ítem amb una crida GET

Les condicions:

- La informació ha d'estar guardada en un arxiu *.json* en una carpeta privada del servidor
- Les imatges han d'estar a la carpeta *public/images* i ser accessibles des d'una URL a través del navegador