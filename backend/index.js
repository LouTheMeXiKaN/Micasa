const express = require('express');
const path = require('path');
require('dotenv').config();
console.log('DEBUG: Twilio SID from .env is:', process.env.TWILIO_ACCOUNT_SID);

const app = express();
const PORT = process.env.PORT || 3000;

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const eventRoutes = require('./routes/events');

// Middleware
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