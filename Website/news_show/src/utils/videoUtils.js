// Function to get video URL from the uploads directory
export const getVideoUrl = (directory, filename) => {
    return `http://localhost:3001/uploads/${directory}/${filename}`;
};

// Function to check if a file is a video
export const isVideoFile = (filename) => {
    const videoExtensions = ['.mp4', '.webm', '.mov', '.avi'];
    const ext = filename.toLowerCase().slice(filename.lastIndexOf('.'));
    return videoExtensions.includes(ext);
};

// Function to get quality color based on category
export const getQualityColor = (category) => {
    const colors = {
        'Excellent': '#28a745',
        'Good': '#17a2b8',
        'Fair': '#ffc107',
        'Poor': '#dc3545'
    };
    return colors[category] || '#6c757d';
}; 