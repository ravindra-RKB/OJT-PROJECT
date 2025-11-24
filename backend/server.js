const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const axios = require('axios');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Import routes
const marketPricesRoutes = require('./routes/marketPrices');
const schemesRoutes = require('./routes/schemes');

// Routes
app.use('/api/market-prices', marketPricesRoutes);
app.use('/api/schemes', schemesRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Farmer App API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Farmer App API Server',
    version: '1.0.0',
    endpoints: {
      marketPrices: '/api/market-prices',
      schemes: '/api/schemes',
      health: '/api/health'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.path
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Farmer App API Server running on http://localhost:${PORT}`);
  console.log(`📊 Market Prices API: http://localhost:${PORT}/api/market-prices`);
  console.log(`📋 Government Schemes API: http://localhost:${PORT}/api/schemes`);
});

