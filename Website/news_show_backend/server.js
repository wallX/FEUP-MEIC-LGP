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

// Function to find video file with or without extension
const findVideoFile = (baseName, directory) => {
    const possibleExtensions = ['.mp4', '.webm', '.mov', '.avi', ''];
    for (const ext of possibleExtensions) {
        const fileName = baseName + ext;
        const filePath = path.join(directory, fileName);
        if (fs.existsSync(filePath)) {
            return {
                actualName: fileName,
                displayName: baseName + '.mp4'
            };
        }
    }
    return null;
};

// Endpoint to list videos with their metadata
app.get('/api/videos', (req, res) => {
    try {
        // Get all items in the uploads directory
        const items = fs.readdirSync(UPLOADS_DIR);
        
        // Filter for analysis directories and process them
        const videos = items
            .filter(item => {
                const itemPath = path.join(UPLOADS_DIR, item);
                return fs.statSync(itemPath).isDirectory() && item.endsWith('_analysis');
            })
            .map(dir => {
                const dirPath = path.join(UPLOADS_DIR, dir);
                const baseFileName = dir.replace('_analysis', '');
                
                // Find the video file
                const videoFile = findVideoFile(baseFileName, UPLOADS_DIR);
                if (!videoFile) return null;

                // Read metadata files from the analysis directory
                const qualityData = readJsonFile(path.join(dirPath, `${baseFileName}_quality.json`));
                const transcriptionData = readJsonFile(path.join(dirPath, `${baseFileName}_transcription.json`));
                const descriptionData = readJsonFile(path.join(dirPath, `${baseFileName}_description.json`));

                return {
                    filename: videoFile.displayName,
                    actualFilename: videoFile.actualName,
                    directory: dir,
                    timestamp: fs.statSync(path.join(UPLOADS_DIR, videoFile.actualName)).mtime.toISOString(),
                    quality: qualityData,
                    transcription: transcriptionData?.transcription || '',
                    description: descriptionData?.summary || '',
                };
            })
            .filter(video => video !== null)
            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        res.json(videos);
    } catch (error) {
        console.error('Error listing videos:', error);
        res.status(500).json({ error: 'Failed to list videos' });
    }
});

// Serve video files directly from the uploads directory
app.get('/uploads/:filename', (req, res) => {
    const filename = req.params.filename;
    const filePath = path.join(UPLOADS_DIR, filename);
    
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
        res.sendFile(filePath);
    } else {
        res.status(404).send('File not found');
    }
});

// Serve files from analysis directories
app.get('/uploads/:analysisDir/:filename', (req, res) => {
    const { analysisDir, filename } = req.params;
    const dirPath = path.join(UPLOADS_DIR, analysisDir);
    const filePath = path.join(dirPath, filename);
    
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
        res.sendFile(filePath);
    } else {
        res.status(404).send('File not found');
    }
});

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Watching for videos in: ${UPLOADS_DIR}`);
}); 