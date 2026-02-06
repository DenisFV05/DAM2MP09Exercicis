const readline = require('readline');
const fs = require('fs');

class BuscaTresors {
    constructor() {
        this.ROWS = 6;
        this.COLS = 8;
        this.TOTAL_TRESORS = 16;
        this.MAX_TIRADES = 32;
        this.initGame();
    }

    initGame() {
        // Tauler visible: '·' = per descobrir, ' ' = buit (sense tresor), 'T' = tresor trobat
        this.tauler = Array.from({ length: this.ROWS }, () => 
            Array.from({ length: this.COLS }, () => '·')
        );
        
        // Tauler secret amb els tresors
        this.tresors = Array.from({ length: this.ROWS }, () => 
            Array.from({ length: this.COLS }, () => false)
        );
        
        this.tirades = this.MAX_TIRADES;
        this.tresorsTrobats = 0;
        this.trampaActiva = false;
        this.partidaAcabada = false;
        
        // Col·locar tresors aleatòriament
        this.colocarTresors();
    }

    colocarTresors() {
        let colocats = 0;
        while (colocats < this.TOTAL_TRESORS) {
            const fila = Math.floor(Math.random() * this.ROWS);
            const col = Math.floor(Math.random() * this.COLS);
            if (!this.tresors[fila][col]) {
                this.tresors[fila][col] = true;
                colocats++;
            }
        }
    }

    mostrarTauler() {
        const lletres = 'ABCDEF';
        let output = '\n 01234567';
        
        if (this.trampaActiva) {
            output += '      01234567';
        }
        output += '\n';
        
        for (let i = 0; i < this.ROWS; i++) {
            output += lletres[i] + this.tauler[i].join('');
            
            if (this.trampaActiva) {
                output += '     ' + lletres[i];
                for (let j = 0; j < this.COLS; j++) {
                    if (this.tresors[i][j]) {
                        output += this.tauler[i][j] === 'T' ? 'T' : '*';
                    } else {
                        output += this.tauler[i][j] === '·' ? '·' : ' ';
                    }
                }
            }
            output += '\n';
        }
        
        console.log(output);
    }

    parseCasella(input) {
        const match = input.toUpperCase().match(/^([A-F])([0-7])$/);
        if (!match) return null;
        
        const fila = match[1].charCodeAt(0) - 'A'.charCodeAt(0);
        const col = parseInt(match[2]);
        return { fila, col };
    }

    calcularDistancia(fila1, col1, fila2, col2) {
        // Distància Manhattan
        return Math.abs(fila1 - fila2) + Math.abs(col1 - col2);
    }

    trobarTresorMesProper(fila, col) {
        let minDist = Infinity;
        
        for (let i = 0; i < this.ROWS; i++) {
            for (let j = 0; j < this.COLS; j++) {
                if (this.tresors[i][j] && this.tauler[i][j] !== 'T') {
                    const dist = this.calcularDistancia(fila, col, i, j);
                    if (dist < minDist) {
                        minDist = dist;
                    }
                }
            }
        }
        
        return minDist === Infinity ? 0 : minDist;
    }

    destapar(input) {
        const casella = this.parseCasella(input);
        if (!casella) {
            console.log('Casella no vàlida. Usa format: A0, B3, etc.');
            return;
        }
        
        const { fila, col } = casella;
        
        if (this.tauler[fila][col] !== '·') {
            console.log('Aquesta casella ja està destapada.');
            return;
        }
        
        if (this.tresors[fila][col]) {
            // Trobat un tresor!
            this.tauler[fila][col] = 'T';
            this.tresorsTrobats++;
            console.log(`🎉 Has trobat un tresor! (${this.tresorsTrobats}/${this.TOTAL_TRESORS})`);
            
            if (this.tresorsTrobats === this.TOTAL_TRESORS) {
                const tiradesUsades = this.MAX_TIRADES - this.tirades;
                console.log(`\n🏆 Has guanyat amb només ${tiradesUsades} tirades!`);
                this.partidaAcabada = true;
            }
        } else {
            // No hi ha tresor, gastar tirada
            this.tauler[fila][col] = ' ';
            this.tirades--;
            const distancia = this.trobarTresorMesProper(fila, col);
            console.log(`El tresor més proper està a ${distancia} caselles de distància.`);
            
            if (this.tirades <= 0) {
                const restants = this.TOTAL_TRESORS - this.tresorsTrobats;
                console.log(`\n💀 Has perdut, queden ${restants} tresors`);
                this.partidaAcabada = true;
            }
        }
    }

    mostrarPuntuacio() {
        console.log(`\n📊 Puntuació: ${this.tresorsTrobats}/${this.TOTAL_TRESORS} tresors trobats`);
        console.log(`🎯 Tirades restants: ${this.tirades}/${this.MAX_TIRADES}`);
    }

    activarTrampa() {
        this.trampaActiva = !this.trampaActiva;
        console.log(`Trampa ${this.trampaActiva ? 'activada' : 'desactivada'}.`);
    }

    guardarPartida(nomArxiu) {
        const partida = {
            tauler: this.tauler,
            tresors: this.tresors,
            tirades: this.tirades,
            tresorsTrobats: this.tresorsTrobats,
            trampaActiva: this.trampaActiva
        };
        
        try {
            const filename = nomArxiu.endsWith('.json') ? nomArxiu : `${nomArxiu}.json`;
            fs.writeFileSync(filename, JSON.stringify(partida, null, 2));
            console.log(`💾 Partida guardada a: ${filename}`);
        } catch (error) {
            console.log(`❌ Error guardant la partida: ${error.message}`);
        }
    }

    carregarPartida(nomArxiu) {
        try {
            const filename = nomArxiu.endsWith('.json') ? nomArxiu : `${nomArxiu}.json`;
            const data = fs.readFileSync(filename, 'utf8');
            const partida = JSON.parse(data);
            
            this.tauler = partida.tauler;
            this.tresors = partida.tresors;
            this.tirades = partida.tirades;
            this.tresorsTrobats = partida.tresorsTrobats;
            this.trampaActiva = partida.trampaActiva || false;
            
            console.log(`📂 Partida carregada des de: ${filename}`);
        } catch (error) {
            console.log(`❌ Error carregant la partida: ${error.message}`);
        }
    }

    mostrarAjuda() {
        console.log(`
╔══════════════════════════════════════════════════════════╗
║                    🗺️  BUSCA TRESORS                      ║
╠══════════════════════════════════════════════════════════╣
║  Comandes disponibles:                                   ║
║                                                          ║
║  destapar <casella>  - Destapa una casella (ex: B3)      ║
║  <casella>           - Atajo per destapar (ex: A0)       ║
║  trampa              - Activa/desactiva trampa           ║
║  puntuacio           - Mostra puntuació actual           ║
║  guardar <arxiu>     - Guarda la partida                 ║
║  carregar <arxiu>    - Carrega una partida               ║
║  ajuda / help        - Mostra aquesta ajuda              ║
║  sortir              - Surt del joc                      ║
╚══════════════════════════════════════════════════════════╝
`);
    }

    processarComanda(input) {
        const parts = input.trim().toLowerCase().split(/\s+/);
        const comanda = parts[0];
        
        if (!comanda) return true;
        
        if (this.partidaAcabada) {
            if (comanda === 'sortir' || comanda === 'exit') {
                return false;
            }
            console.log('La partida ha acabat. Escriu "sortir" per tancar.');
            return true;
        }
        
        switch (comanda) {
            case 'help':
            case 'ajuda':
                this.mostrarAjuda();
                break;
                
            case 'trampa':
                this.activarTrampa();
                break;
                
            case 'puntuacio':
            case 'puntuación':
                this.mostrarPuntuacio();
                break;
                
            case 'guardar':
                if (parts[1]) {
                    this.guardarPartida(parts[1].replace(/"/g, ''));
                } else {
                    console.log('Indica el nom de l\'arxiu: guardar nom_arxiu.json');
                }
                break;
                
            case 'carregar':
                if (parts[1]) {
                    this.carregarPartida(parts[1].replace(/"/g, ''));
                } else {
                    console.log('Indica el nom de l\'arxiu: carregar nom_arxiu.json');
                }
                break;
                
            case 'destapar':
                if (parts[1]) {
                    this.destapar(parts[1]);
                } else {
                    console.log('Indica la casella: destapar B3');
                }
                break;
                
            case 'sortir':
            case 'exit':
                console.log('Adéu! 👋');
                return false;
                
            default:
                // Intentar interpretar com a casella directa
                const casella = this.parseCasella(comanda);
                if (casella) {
                    this.destapar(comanda);
                } else {
                    console.log('Comanda no reconeguda. Escriu "ajuda" per veure les opcions.');
                }
        }
        
        return true;
    }

    async iniciar() {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });

        console.log('\n🗺️  BUSCA TRESORS - Joc de línia de comandes');
        console.log('Escriu "ajuda" per veure les comandes disponibles.\n');
        
        this.mostrarTauler();
        
        const preguntar = () => {
            rl.question('Escriu una comanda: ', (answer) => {
                const continuar = this.processarComanda(answer);
                
                if (continuar) {
                    this.mostrarTauler();
                    preguntar();
                } else {
                    rl.close();
                }
            });
        };
        
        preguntar();
    }
}

// Iniciar el joc
const joc = new BuscaTresors();
joc.iniciar();
