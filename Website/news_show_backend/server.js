const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());

// Define the uploads directory path
const UPLOADS_DIR = path.join(__dirname, '..', '..', 'Backend', 'uploads');

// Create uploads directory if it doesn't exist
if (!fs.existsSync(UPLOADS_DIR)) {
    fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

// Endpoint to list videos
app.get('/api/videos', (req, res) => {
    try {
        const files = fs.readdirSync(UPLOADS_DIR);
        const videos = files
            .filter(file => ['.mp4', '.webm', '.mov', '.avi'].includes(path.extname(file).toLowerCase()))
            .map(file => ({
                filename: file,
                timestamp: fs.statSync(path.join(UPLOADS_DIR, file)).mtime.toISOString()
            }))
            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        res.json(videos);
    } catch (error) {
        console.error('Error listing videos:', error);
        res.status(500).json({ error: 'Failed to list videos' });
    }
});

// Serve video files
app.use('/uploads', express.static(UPLOADS_DIR));

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Watching for videos in: ${UPLOADS_DIR}`);
}); 