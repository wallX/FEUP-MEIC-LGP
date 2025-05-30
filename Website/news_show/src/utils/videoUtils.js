// Function to get video URL from the uploads directory
export const getVideoUrl = (filename) => {
    return `http://localhost:3001/uploads/${filename}`;
};

// Function to check if a file is a video
export const isVideoFile = (filename) => {
    const videoExtensions = ['.mp4', '.webm', '.mov', '.avi'];
    const ext = filename.toLowerCase().slice(filename.lastIndexOf('.'));
    return videoExtensions.includes(ext);
}; 