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

// Function to read JSON file safely
const readJsonFile = (filePath) => {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        return JSON.parse(content);
    } catch (error) {
        console.error(`Error reading JSON file ${filePath}:`, error);
        return null;
    }
};

// Endpoint to list videos with their metadata
app.get('/api/videos', (req, res) => {
    try {
        const directories = fs.readdirSync(UPLOADS_DIR)
            .filter(item => {
                const itemPath = path.join(UPLOADS_DIR, item);
                return fs.statSync(itemPath).isDirectory() && item.endsWith('_analysis');
            });

        const videos = directories.map(dir => {
            const dirPath = path.join(UPLOADS_DIR, dir);
            const baseFileName = dir.replace('_analysis', '');
            const files = fs.readdirSync(UPLOADS_DIR);

            // Find the video file
            const videoFileName = `${baseFileName}.mp4`;
            const videoPath = path.join(UPLOADS_DIR, videoFileName);

            if (!fs.existsSync(videoPath)) {
                return null;
            }

            // Read metadata files
            const qualityData = readJsonFile(path.join(dirPath, `${baseFileName}_quality.json`));
            const transcriptionData = readJsonFile(path.join(dirPath, `${baseFileName}_transcription.json`));
            const descriptionData = readJsonFile(path.join(dirPath, `${baseFileName}_description.json`));

            return {
                filename: videoFileName,
                directory: dir,
                timestamp: fs.statSync(videoPath).mtime.toISOString(),
                quality: qualityData,
                transcription: transcriptionData?.transcription || '',
                description: descriptionData?.summary || '',
            };
        }).filter(video => video !== null)
          .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        res.json(videos);
    } catch (error) {
        console.error('Error listing videos:', error);
        res.status(500).json({ error: 'Failed to list videos' });
    }
});

// Serve files from analysis directories
app.use('/uploads', (req, res, next) => {
    const filePath = req.path;
    if (filePath.includes('_analysis/')) {
        express.static(UPLOADS_DIR)(req, res, next);
    } else {
        res.status(404).send('Not found');
    }
});

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Watching for videos in: ${UPLOADS_DIR}`);
}); 