const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;

const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.pdf': 'application/pdf',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ttf': 'font/ttf',
    '.eot': 'application/vnd.ms-fontobject',
    '.mp4': 'video/mp4',
    '.webm': 'video/webm',
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav'
};

const server = http.createServer((req, res) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    
    // Handle root URL - serve index.html
    let filePath = req.url === '/' 
        ? path.join(__dirname, 'public', 'index.html')
        : path.join(__dirname, 'public', req.url);
    
    // Get file extension
    const extname = path.extname(filePath);
    
    // Set content type
    const contentType = MIME_TYPES[extname] || 'application/octet-stream';
    
    // Read file
    fs.readFile(filePath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                // Page not found - try serving 404.html
                fs.readFile(path.join(__dirname, 'public', '404.html'), (err, content) => {
                    if (err) {
                        // Fallback 404 message
                        res.writeHead(404, { 'Content-Type': 'text/html' });
                        res.end(`
                            <!DOCTYPE html>
                            <html>
                            <head>
                                <title>404 Not Found</title>
                                <style>
                                    body {
                                        font-family: 'Poppins', sans-serif;
                                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                                        height: 100vh;
                                        margin: 0;
                                        display: flex;
                                        justify-content: center;
                                        align-items: center;
                                        color: white;
                                        text-align: center;
                                    }
                                    .error-container {
                                        background: rgba(255,255,255,0.1);
                                        padding: 50px;
                                        border-radius: 20px;
                                        backdrop-filter: blur(10px);
                                    }
                                    h1 { font-size: 72px; margin: 0; }
                                    p { font-size: 24px; }
                                    a {
                                        color: white;
                                        text-decoration: none;
                                        border: 2px solid white;
                                        padding: 10px 30px;
                                        border-radius: 50px;
                                        display: inline-block;
                                        margin-top: 20px;
                                        transition: all 0.3s;
                                    }
                                    a:hover {
                                        background: white;
                                        color: #764ba2;
                                    }
                                </style>
                            </head>
                            <body>
                                <div class="error-container">
                                    <h1>404</h1>
                                    <p>Page Not Found</p>
                                    <a href="/">Go Back Home</a>
                                </div>
                            </body>
                            </html>
                        `);
                    } else {
                        res.writeHead(404, { 'Content-Type': 'text/html' });
                        res.end(content, 'utf8');
                    }
                });
            } else {
                // Server error
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
            }
        } else {
            // Success - serve the file
            res.writeHead(200, { 
                'Content-Type': contentType,
                'Cache-Control': 'public, max-age=31536000' // Cache static assets for 1 year
            });
            res.end(content, 'utf8');
        }
    });
});

server.listen(PORT, () => {
    console.log(`
    ╔═══════════════════════════════════════════════╗
    ║                                               ║
    ║   🎉 ELEGANT EVENTS SERVER RUNNING! 🎉       ║
    ║                                               ║
    ║   ➜ Local: http://localhost:${PORT}           ║
    ║   ➜ Press Ctrl+C to stop                      ║
    ║                                               ║
    ╚═══════════════════════════════════════════════╝
    `);
});