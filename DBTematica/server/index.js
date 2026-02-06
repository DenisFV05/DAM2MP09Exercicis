const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/images', express.static(path.join(__dirname, 'public/images')));

// Cargar datos
const dataPath = path.join(__dirname, 'private/data.json');
let data = { categories: [], items: [] };

try {
    data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
    console.log(`✅ Cargados ${data.categories.length} categorías y ${data.items.length} items`);
} catch (error) {
    console.error('❌ Error cargando datos:', error.message);
}

// ============================================
// ENDPOINTS POST 
// ============================================

// POST /api/categories - Obtener todas las categorías
app.post('/api/categories', (req, res) => {
    res.json({
        success: true,
        data: data.categories
    });
});

// POST /api/items - Obtener items de una categoría
app.post('/api/items', (req, res) => {
    const { categoryId } = req.body;

    if (!categoryId) {
        return res.status(400).json({
            success: false,
            error: 'Se requiere categoryId'
        });
    }

    const items = data.items.filter(item => item.categoryId === parseInt(categoryId));

    res.json({
        success: true,
        data: items
    });
});

// POST /api/item - Obtener información de un ítem específico
app.post('/api/item', (req, res) => {
    const { itemId } = req.body;

    if (!itemId) {
        return res.status(400).json({
            success: false,
            error: 'Se requiere itemId'
        });
    }

    const item = data.items.find(i => i.id === parseInt(itemId));

    if (!item) {
        return res.status(404).json({
            success: false,
            error: 'Item no encontrado'
        });
    }

    res.json({
        success: true,
        data: item
    });
});

// POST /api/search - Buscar items
app.post('/api/search', (req, res) => {
    const { query } = req.body;

    if (!query || query.trim() === '') {
        return res.json({
            success: true,
            data: []
        });
    }

    const searchTerm = query.toLowerCase().trim();

    const results = data.items.filter(item =>
        item.name.toLowerCase().includes(searchTerm) ||
        item.country.toLowerCase().includes(searchTerm) ||
        item.description.toLowerCase().includes(searchTerm) ||
        item.ingredients.some(ing => ing.toLowerCase().includes(searchTerm))
    );

    res.json({
        success: true,
        data: results
    });
});

// ============================================
// ENDPOINTS GET para imágenes
// ============================================

// GET /api/image/:filename - Obtener imagen
app.get('/api/image/:filename', (req, res) => {
    const { filename } = req.params;
    const imagePath = path.join(__dirname, 'public/images', filename);

    if (fs.existsSync(imagePath)) {
        res.sendFile(imagePath);
    } else {
        // Enviar imagen placeholder si no existe
        res.status(404).json({
            success: false,
            error: 'Imagen no encontrada',
            placeholder: `https://via.placeholder.com/300x200?text=${encodeURIComponent(filename.replace('.jpg', ''))}`
        });
    }
});

// Endpoint de prueba
app.get('/', (req, res) => {
    res.json({
        message: '🍽️ API de Comida Internacional',
        endpoints: {
            'POST /api/categories': 'Obtener todas las categorías',
            'POST /api/items': 'Obtener items de una categoría (body: { categoryId })',
            'POST /api/item': 'Obtener info de un item (body: { itemId })',
            'POST /api/search': 'Buscar items (body: { query })',
            'GET /api/image/:filename': 'Obtener imagen',
            'GET /images/:filename': 'Acceso directo a imágenes'
        }
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`
🍽️  API de Comida Internacional
================================
Servidor corriendo en: http://localhost:${PORT}
    `);
});
