import { useState, useEffect, useRef } from 'react';
import { getVideoUrl, getQualityColor } from '../utils/videoUtils';
import './NewsDisplay.css';

// Simulated news articles
const simulatedNews = [
    {
        id: 1,
        title: "Avanços na Tecnologia Verde",
        content: "Novas descobertas em energia renovável prometem revolucionar o setor energético. Cientistas afirmam que as novas tecnologias podem reduzir em até 50% o consumo de energia.",
        category: "Tecnologia",
        image: "https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=500"
    },
    {
        id: 2,
        title: "Descoberta Científica Importante",
        content: "Cientistas fazem breakthrough em pesquisa sobre sustentabilidade. Novo método de reciclagem promete transformar 95% do lixo plástico em material reutilizável.",
        category: "Ciência",
        image: "https://images.unsplash.com/photo-1507413245164-6160d8298b31?w=500"
    },
    {
        id: 3,
        title: "Inovações em Mobilidade Urbana",
        content: "Novos projetos de transporte público são anunciados para grandes cidades. Sistema integrado de transporte promete reduzir tempo de deslocamento em até 40%.",
        category: "Urbanismo",
        image: "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=500"
    },
    {
        id: 4,
        title: "Avanços na Medicina Digital",
        content: "Inteligência artificial revoluciona diagnósticos médicos com precisão de 99%. Nova tecnologia pode detectar doenças em estágios iniciais.",
        category: "Saúde",
        image: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=500"
    },
    {
        id: 5,
        title: "Economia Sustentável em Alta",
        content: "Empresas que adotam práticas sustentáveis registram aumento de 30% em lucros. Investidores priorizam negócios com compromisso ambiental.",
        category: "Economia",
        image: "https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=500"
    }
];

const NewsDisplay = () => {
    const [breakingNews, setBreakingNews] = useState(null);
    const [showBreaking, setShowBreaking] = useState(false);
    const [videos, setVideos] = useState([]);
    const previousVideosRef = useRef([]);

    // Function to fetch videos from the server
    const fetchVideos = async () => {
        try {
            const response = await fetch('http://localhost:3001/api/videos');
            const data = await response.json();
            
            // Check for new videos by comparing with previous state
            const previousVideos = previousVideosRef.current;
            const newVideos = data.filter(video => 
                !previousVideos.some(prevVideo => 
                    prevVideo.filename === video.filename && 
                    prevVideo.timestamp === video.timestamp
                )
            );

            // If there are new videos, show the most recent one as breaking news
            if (newVideos.length > 0) {
                const latestVideo = newVideos[0];
                setBreakingNews({
                    title: "Nova Transmissão Recebida",
                    description: latestVideo.description,
                    filename: latestVideo.filename,
                    actualFilename: latestVideo.actualFilename,
                    directory: latestVideo.directory,
                    quality: latestVideo.quality,
                    transcription: latestVideo.transcription,
                    url: getVideoUrl(null, latestVideo.filename, latestVideo.actualFilename)
                });
                setShowBreaking(true);
            }

            // Update the videos state and previous videos ref
            setVideos(data);
            previousVideosRef.current = data;
        } catch (error) {
            console.error('Error fetching videos:', error);
        }
    };

    // Fetch videos initially and then every 2 seconds
    useEffect(() => {
        fetchVideos();
        const interval = setInterval(fetchVideos, 2000);
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="news-container">
            <header className="news-header">
                <h1>Kwik Report News</h1>
                <div className="news-ticker">
                    <span>Últimas atualizações: </span>
                    <marquee>
                        {simulatedNews.map(news => `${news.title} | `).join('')}
                    </marquee>
                </div>
            </header>

            {showBreaking && breakingNews && (
                <div className="breaking-news-overlay">
                    <div className="breaking-news">
                        <div className="breaking-header">
                            <div className="breaking-title">
                                <div className="breaking-badge">BREAKING NEWS</div>
                                <h2>{breakingNews.title}</h2>
                                {breakingNews.quality && (
                                    <div 
                                        className="quality-badge"
                                        style={{ backgroundColor: getQualityColor(breakingNews.quality.category) }}
                                    >
                                        Qualidade: {breakingNews.quality.category} ({Math.round(breakingNews.quality.score * 100)}%)
                                    </div>
                                )}
                            </div>
                            <button onClick={() => setShowBreaking(false)}>×</button>
                        </div>
                        <video
                            controls
                            autoPlay
                            muted
                            src={breakingNews.url}
                        />
                        {breakingNews.transcription && (
                            <div className="breaking-transcription">
                                <h3>Transcrição:</h3>
                                <p>{breakingNews.transcription}</p>
                            </div>
                        )}
                        {breakingNews.description && (
                            <div className="breaking-description">
                                <h3>Descrição:</h3>
                                <p>{breakingNews.description}</p>
                            </div>
                        )}
                    </div>
                </div>
            )}
            
            <main className="regular-news">
                <section className="videos-section">
                    <h2>Vídeos Recentes</h2>
                    <div className="videos-grid">
                        {videos.map((video) => (
                            <div key={video.filename} className="video-card" onClick={() => {
                                setBreakingNews({
                                    title: "Visualizando Transmissão",
                                    description: video.description,
                                    filename: video.filename,
                                    actualFilename: video.actualFilename,
                                    directory: video.directory,
                                    quality: video.quality,
                                    transcription: video.transcription,
                                    url: getVideoUrl(null, video.filename, video.actualFilename)
                                });
                                setShowBreaking(true);
                            }}>
                                <video
                                    muted
                                    poster={`${getVideoUrl(null, video.filename, video.actualFilename)}#t=0.1`}
                                >
                                    <source src={getVideoUrl(null, video.filename, video.actualFilename)} type="video/mp4" />
                                </video>
                                <div className="video-info">
                                    <h3>{video.filename}</h3>
                                    {video.quality && (
                                        <div 
                                            className="quality-badge"
                                            style={{ backgroundColor: getQualityColor(video.quality.category) }}
                                        >
                                            {video.quality.category}
                                        </div>
                                    )}
                                    <span className="video-timestamp">{new Date(video.timestamp).toLocaleString()}</span>
                                </div>
                            </div>
                        ))}
                        {videos.length === 0 && (
                            <div className="no-videos">
                                <p>Nenhum vídeo disponível</p>
                            </div>
                        )}
                    </div>
                </section>

                {/* News Section */}
                <section className="news-section">
                    <h2>Últimas Notícias</h2>
                    <div className="news-grid">
                        {simulatedNews.map(news => (
                            <article key={news.id} className="news-card">
                                <div className="news-card-image" style={{ backgroundImage: `url(${news.image})` }} />
                                <div className="news-card-content">
                                    <span className="category">{news.category}</span>
                                    <h3>{news.title}</h3>
                                    <p>{news.content}</p>
                                </div>
                            </article>
                        ))}
                    </div>
                </section>
            </main>
        </div>
    );
};

export default NewsDisplay; 