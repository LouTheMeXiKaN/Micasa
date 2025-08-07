const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
console.log('DEBUG: Twilio SID from .env is:', process.env.TWILIO_ACCOUNT_SID);

const app = express();
const PORT = process.env.PORT || 3000;

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const eventRoutes = require('./routes/events');

// CORS configuration
const corsOptions = {
  origin: [
    'http://localhost:3000',
    'http://localhost:3001', 
    'http://localhost:3002',
    'http://localhost:3003',
    'https://micasa.events',
    'https://events.micasa.events'
  ],
  credentials: true,
  optionsSuccessStatus: 200
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());

// Serve static files for uploaded avatars
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'ok' });
});

// Routes
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/events', eventRoutes);
// Position routes are handled within the events router for /events/:eventId/positions
// and as standalone routes for /positions/:positionId
app.use('/', eventRoutes); // This allows the eventRoutes to handle both /events and /positions paths

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});