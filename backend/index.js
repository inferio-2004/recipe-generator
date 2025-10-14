require('dotenv').config({path: '../.env'});
const express = require('express');
const cors = require('cors');

const authRouter = require('./routes/auth');
const recipesRouter = require('./routes/recipes');
const recognizeRouter = require('./routes/recognize');
const recommendRouter = require('./routes/recommend');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));
// Simple health check endpoint for Render
app.get('/health', (req, res) => res.send('ok'));
app.use('/auth', authRouter);
app.use('/api/recipes', recipesRouter);
app.use('/api/recognize', recognizeRouter);
app.use('/api/recommend', recommendRouter);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server listening on ${PORT}`);
});
