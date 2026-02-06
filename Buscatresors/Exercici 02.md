<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2024</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

# Exercici 02

L'objectiu d'aquest exercici és fer un joc de línia de comandes amb NodeJS, per practicar JavaScript i orientació a objectes.

Programa un dels següents jocs.

## Busca tresors

Es genera un tauler bidimensional (matriu) de 8x6.

```text
 01234567
A········
B········
C········
D········
E········
F········
Escriu una comanda: 
```

S’amaguen 16 tresors en diverses coordenades aleatòries del tauler.

L'usuari té les següents comandes textuals:

- **ajuda**: paraules *help* o *ajuda*, mostren la llista de comandes
* **carregar partida "nom_arxiu.json"**: carrega una partida guardada
* **guardar partida "nom_guardar.json"**: guarda la partida actual
* **activar/desactivar trampa**: a la dreta del tauler, mostra o amaga un segon tauler amb les caselles destapades
* **destapar x,y**: on x,y són una casella (ex: B3) **i diu a quina distància està el tresor més proper**
* **puntuació**: mostra la puntuació actual i les tirades restants. Originalment l'usuari té 32 tirades, que es gasten cada vegada que NO encerta un tresor (és a dir trobar un tresor no gasta tirada). 
  
La puntuació és la quantitat de tresors que ha trobat del total, per exemple: Z/32

La partida s'acaba quan:

- L'usuari **acaba les tirades**, que surt el missatge: "Has perdut, queden Z tresors"
- L'usuari **destapa tots els tresors**, que surt el missatge: "Has guanyat amb només Y tirades"

## Floor is lava

Es genera un tauler bidimensional (matriu) de 8x6.

```text
 01234567
A········
B········
C········
D········
E········
F········
Escriu una comanda: 
```

S'amaguen 16 caselles de lava en diverses coordenades aleatòries del tauler. Excepte la *A0* on hi ha l'usuari "T" i la *F7* on hi ha el destí "*".

L'usuari té les següents comandes textuals:

- **ajuda**: paraules *help* o *ajuda*, mostren la llista de comandes
* **carregar partida "nom_arxiu.json"**: carrega una partida guardada
* **guardar partida "nom_guardar.json"**: guarda la partida actual
* **activar/desactivar trampa**: a la dreta del tauler, mostra o amaga un segon tauler amb les caselles destapades
* **caminar "direcció"**: on *"direcció"* pot ser "amunt", "avall", "dreta", "esquerra". 

  - Si s'intenta sortir del tauler, es veu el missatge: "Has perdut, has caigut per un penyasegat"
  - Si es cau en una casella de lava "l", es destapa i es veu el missatge: "Has trepitjat lava, perds un punt"
  - Si es va a una casella lliure, es veu el missatge: "Vas per bon camí, tens lava a x caselles de distància"

* **puntuació**: mostra la puntuació actual que correspòn a la distància des de la sortida i les passes actuals. Originalment l'usuari té 32 passes, que es gasten cada vegada que trepitja lava. 

La partida s'acaba quan:

- L'usuari **acaba els punts**, que surt el missatge: "Has perdut, ja no tens més passes"
- L'usuari **arriba a la casella F7**, que surt el missatge: "Has guanyat, has trobat el tresor"