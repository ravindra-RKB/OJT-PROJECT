# Farmer App API Backend

REST API server for Market Prices and Government Schemes.

## Features

### Market Prices API
- Get all market prices
- Get prices by commodity
- Search commodities
- Get price trends
- Get all states
- Get districts by state

### Government Schemes API
- Get all schemes
- Get scheme by ID
- Get schemes by category
- Search schemes
- Get all categories
- Get active schemes

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

3. Add your API key to `.env`:
```
DATA_GOV_API_KEY=your_api_key_here
PORT=3000
```

## Running the Server

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

The server will run on `http://localhost:3000`

## API Endpoints

### Market Prices

- `GET /api/market-prices` - Get all market prices
  - Query params: `state`, `district`, `limit`
  - Example: `/api/market-prices?state=Karnataka&district=Bengaluru Urban&limit=50`

- `GET /api/market-prices/commodity/:commodity` - Get prices by commodity
  - Example: `/api/market-prices/commodity/Rice`

- `GET /api/market-prices/search?q=query` - Search commodities
  - Example: `/api/market-prices/search?q=wheat`

- `GET /api/market-prices/trends/:commodity` - Get price trends
  - Query params: `days` (default: 30)
  - Example: `/api/market-prices/trends/Rice?days=30`

- `GET /api/market-prices/states` - Get all states

- `GET /api/market-prices/districts/:state` - Get districts by state
  - Example: `/api/market-prices/districts/Karnataka`

### Government Schemes

- `GET /api/schemes` - Get all schemes

- `GET /api/schemes/:id` - Get scheme by ID
  - Example: `/api/schemes/1`

- `GET /api/schemes/category/:category` - Get schemes by category
  - Example: `/api/schemes/category/Income Support`

- `GET /api/schemes/search?q=query` - Search schemes
  - Example: `/api/schemes/search?q=insurance`

- `GET /api/schemes/categories/list` - Get all categories

- `GET /api/schemes/active/list` - Get active schemes

### Health Check

- `GET /api/health` - Health check endpoint

## Response Format

All endpoints return JSON in the following format:

```json
{
  "success": true,
  "count": 10,
  "data": [...]
}
```

Error responses:

```json
{
  "success": false,
  "error": "Error message",
  "message": "Detailed error message"
}
```

## Testing

You can test the API using:
- Postman
- curl
- Browser (for GET requests)
- Flutter app (update service URLs to point to this backend)

Example curl commands:

```bash
# Get all market prices
curl http://localhost:3000/api/market-prices

# Search commodities
curl http://localhost:3000/api/market-prices/search?q=wheat

# Get all schemes
curl http://localhost:3000/api/schemes

# Search schemes
curl http://localhost:3000/api/schemes/search?q=insurance
```

