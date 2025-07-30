const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/posts', require('./routes/post'));
app.use('/api/users', require('./routes/user'));
app.use('/api/comments', require('./routes/comment'));
app.use('/api/reactions', require('./routes/reaction'));
app.use('/api/polls', require('./routes/poll'));
app.use('/api/notifications', require('./routes/notification'));
app.use('/api/communities', require('./routes/community'));
app.use('/api/questions', require('./routes/question'));
app.use('/api/attachments', require('./routes/attachment'));
app.use('/api/incidents', require('./routes/incident'));


// Default route
app.get('/', (req, res) => {
  res.send('✅ Viva API running');
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
