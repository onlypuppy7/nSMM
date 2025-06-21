import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 1985;

const staticPath = path.join(__dirname, '..', '..', 'dist', 'html');
console.log('Serving static files from:', staticPath);

app.get(['/lovejs/index.html', '/player/index.html'], (req, res, next) => {
  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
  res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
  next();
});

app.use(express.static(staticPath));

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});