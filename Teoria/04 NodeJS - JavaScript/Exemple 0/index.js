const fs = require('fs').promises
const readline = require('readline').promises

// Funció per escriure un objecte en un arxiu .json
async function writeData(obj, file_path) {
    try {
        const txtData = JSON.stringify(obj, null, 2)
        await fs.writeFile(file_path, txtData, 'utf-8')
        console.log(`Dades escrites a ${file_path}`)
    } catch (error) {
        console.error("Error en escriure les dades:", error)
    }
}

// Funció per llegir un arxiu .json cap a un objecte
async function readData(file_path) {
    try {
        const txtData = await fs.readFile(file_path, 'utf-8')
        const data = JSON.parse(txtData)
        return data
    } catch (error) {
        console.error("Error en llegir les dades:", error)
    }
}

async function main() {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    })

    const path = await rl.question("Nom de l'arxiu a generar? ")

    const person = {
        name: "Maria",
        age: 25,
        city: "Barcelona"
    }

    await writeData(person, path)
    const json_data = await readData(path)
    console.log(json_data)

    rl.close() // Tancar la lectura 'readline'
}

main()