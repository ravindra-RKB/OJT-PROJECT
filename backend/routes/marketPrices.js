const express = require('express');
const router = express.Router();
const axios = require('axios');

const RESOURCE_ID = '9ef84268-d588-465a-a308-a864a43d0070';
const BASE_URL = `https://api.data.gov.in/resource/${RESOURCE_ID}`;

// Helper function to get API key
function getApiKey() {
  const apiKey = process.env.DATA_GOV_API_KEY;
  if (!apiKey) {
    throw new Error('DATA_GOV_API_KEY is not set in environment variables');
  }
  return apiKey;
}

// Helper function to parse date
function parseArrivalDate(dateString) {
  if (!dateString) return new Date().toISOString();
  
  try {
    if (dateString.includes('/')) {
      const parts = dateString.split('/');
      if (parts.length === 3) {
        const day = parseInt(parts[0]);
        const month = parseInt(parts[1]);
        const year = parseInt(parts[2]);
        return new Date(year, month - 1, day).toISOString();
      }
    }
    return new Date(dateString).toISOString();
  } catch (error) {
    return new Date().toISOString();
  }
}

// Helper function to map record
function mapRecord(record) {
  const commodity = record.commodity;
  const market = record.market;
  const modalPrice = record.modal_price || record.max_price;

  if (!commodity || !market || !modalPrice) {
    return null;
  }

  return {
    commodity,
    market,
    price: parseFloat(modalPrice) || 0.0,
    unit: record.unit_of_price || 'Quintal',
    date: parseArrivalDate(record.arrival_date),
    state: record.state,
    district: record.district,
  };
}

// GET /api/market-prices - Get all market prices
router.get('/', async (req, res) => {
  try {
    const { state = 'Karnataka', district = 'Bengaluru Urban', limit = 50 } = req.query;
    const apiKey = getApiKey();

    const response = await axios.get(BASE_URL, {
      params: {
        'api-key': apiKey,
        format: 'json',
        limit: limit.toString(),
        'filters[state]': state,
        'filters[district]': district,
        'sort[0]': 'arrival_date:desc',
      },
    });

    if (response.status !== 200) {
      throw new Error(`API returned status ${response.status}`);
    }

    const records = response.data.records || [];
    const prices = records
      .map(mapRecord)
      .filter(price => price !== null);

    res.json({
      success: true,
      count: prices.length,
      data: prices,
    });
  } catch (error) {
    console.error('Error fetching market prices:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch market prices',
      message: error.message,
    });
  }
});

// GET /api/market-prices/commodity/:commodity - Get prices by commodity
router.get('/commodity/:commodity', async (req, res) => {
  try {
    const { commodity } = req.params;
    const { state = 'Karnataka', district = 'Bengaluru Urban', limit = 50 } = req.query;
    const apiKey = getApiKey();

    const response = await axios.get(BASE_URL, {
      params: {
        'api-key': apiKey,
        format: 'json',
        limit: limit.toString(),
        'filters[state]': state,
        'filters[district]': district,
        'filters[commodity]': commodity,
        'sort[0]': 'arrival_date:desc',
      },
    });

    const records = response.data.records || [];
    const prices = records
      .map(mapRecord)
      .filter(price => price !== null);

    res.json({
      success: true,
      commodity,
      count: prices.length,
      data: prices,
    });
  } catch (error) {
    console.error('Error fetching commodity prices:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch commodity prices',
      message: error.message,
    });
  }
});

// GET /api/market-prices/search - Search commodities
router.get('/search', async (req, res) => {
  try {
    const { q, state = 'Karnataka', district = 'Bengaluru Urban' } = req.query;
    
    if (!q) {
      return res.status(400).json({
        success: false,
        error: 'Query parameter "q" is required',
      });
    }

    const apiKey = getApiKey();
    const response = await axios.get(BASE_URL, {
      params: {
        'api-key': apiKey,
        format: 'json',
        limit: '100',
        'filters[state]': state,
        'filters[district]': district,
        'sort[0]': 'arrival_date:desc',
      },
    });

    const records = response.data.records || [];
    const queryLower = q.toLowerCase();
    const prices = records
      .map(mapRecord)
      .filter(price => price !== null && price.commodity.toLowerCase().includes(queryLower));

    res.json({
      success: true,
      query: q,
      count: prices.length,
      data: prices,
    });
  } catch (error) {
    console.error('Error searching commodities:', error.message);
    res.status(500).json({
      success: false,
      error: 'Search failed',
      message: error.message,
    });
  }
});

// GET /api/market-prices/trends/:commodity - Get price trends
router.get('/trends/:commodity', async (req, res) => {
  try {
    const { commodity } = req.params;
    const { state = 'Karnataka', district = 'Bengaluru Urban', days = 30 } = req.query;
    const apiKey = getApiKey();

    const response = await axios.get(BASE_URL, {
      params: {
        'api-key': apiKey,
        format: 'json',
        limit: '200',
        'filters[state]': state,
        'filters[district]': district,
        'filters[commodity]': commodity,
        'sort[0]': 'arrival_date:desc',
      },
    });

    const records = response.data.records || [];
    const prices = records
      .map(mapRecord)
      .filter(price => price !== null);

    const trends = {};
    const now = new Date();
    const daysAgo = new Date(now.getTime() - days * 24 * 60 * 60 * 1000);

    prices.forEach(price => {
      const priceDate = new Date(price.date);
      if (priceDate >= daysAgo) {
        const dateKey = `${priceDate.getFullYear()}-${priceDate.getMonth() + 1}-${priceDate.getDate()}`;
        if (!trends[dateKey]) {
          trends[dateKey] = [];
        }
        trends[dateKey].push(price.price);
      }
    });

    // Calculate average price per day
    const averageTrends = {};
    Object.keys(trends).forEach(date => {
      const prices = trends[date];
      if (prices.length > 0) {
        averageTrends[date] = prices.reduce((a, b) => a + b, 0) / prices.length;
      }
    });

    res.json({
      success: true,
      commodity,
      days: parseInt(days),
      data: averageTrends,
    });
  } catch (error) {
    console.error('Error fetching price trends:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch price trends',
      message: error.message,
    });
  }
});

// GET /api/market-prices/states - Get all available states
router.get('/states', async (req, res) => {
  try {
    const apiKey = getApiKey();
    const response = await axios.get(BASE_URL, {
      params: {
        'api-key': apiKey,
        format: 'json',
        limit: '1000',
        fields: 'state',
      },
    });

    const records = response.data.records || [];
    const states = [...new Set(records.map(r => r.state).filter(Boolean))].sort();

    res.json({
      success: true,
      count: states.length,
      data: states,
    });
  } catch (error) {
    console.error('Error fetching states:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch states',
      message: error.message,
    });
  }
});

// GET /api/market-prices/districts/:state - Get districts by state
router.get('/districts/:state', async (req, res) => {
  try {
    const { state } = req.params;
    const apiKey = getApiKey();

    const response = await axios.get(BASE_URL, {
      params: {
        'api-key': apiKey,
        format: 'json',
        limit: '1000',
        'filters[state]': state,
        fields: 'district',
      },
    });

    const records = response.data.records || [];
    const districts = [...new Set(records.map(r => r.district).filter(Boolean))].sort();

    res.json({
      success: true,
      state,
      count: districts.length,
      data: districts,
    });
  } catch (error) {
    console.error('Error fetching districts:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch districts',
      message: error.message,
    });
  }
});

module.exports = router;

