const express = require('express');
const router = express.Router();

// Mock government schemes data
const mockSchemes = [
  {
    id: '1',
    title: 'Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)',
    description: 'Direct income support scheme providing ₹6,000 per year to all landholding farmer families.',
    eligibility: 'All landholding farmer families',
    benefits: '₹6,000 per year in three equal installments',
    applicationLink: 'https://pmkisan.gov.in',
    category: 'Income Support',
    deadline: null,
  },
  {
    id: '2',
    title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    description: 'Crop insurance scheme to provide financial support to farmers in case of crop loss.',
    eligibility: 'All farmers growing notified crops',
    benefits: 'Premium subsidy and comprehensive risk coverage',
    applicationLink: 'https://pmfby.gov.in',
    category: 'Insurance',
    deadline: null,
  },
  {
    id: '3',
    title: 'Kisan Credit Card (KCC)',
    description: 'Credit facility for farmers to meet their short-term credit requirements.',
    eligibility: 'All farmers including tenant farmers and sharecroppers',
    benefits: 'Credit up to ₹3 lakh at subsidized interest rate',
    applicationLink: 'https://www.india.gov.in/kisan-credit-card-kcc',
    category: 'Credit',
    deadline: null,
  },
  {
    id: '4',
    title: 'Soil Health Card Scheme',
    description: 'Scheme to provide soil health cards to farmers to optimize use of fertilizers.',
    eligibility: 'All farmers',
    benefits: 'Free soil health cards every 3 years',
    applicationLink: 'https://soilhealth.dac.gov.in',
    category: 'Agricultural Support',
    deadline: null,
  },
  {
    id: '5',
    title: 'Pradhan Mantri Krishi Sinchai Yojana (PMKSY)',
    description: 'Scheme to improve farm productivity and ensure better utilization of water resources.',
    eligibility: 'All farmers',
    benefits: 'Subsidy up to 55% for small and marginal farmers',
    applicationLink: 'https://pmksy.gov.in',
    category: 'Irrigation',
    deadline: null,
  },
  {
    id: '6',
    title: 'National Mission for Sustainable Agriculture (NMSA)',
    description: 'Promotes sustainable agriculture practices and climate-resilient farming.',
    eligibility: 'All farmers practicing sustainable agriculture',
    benefits: 'Financial assistance for sustainable practices',
    applicationLink: 'https://nmsa.dac.gov.in',
    category: 'Agricultural Support',
    deadline: null,
  },
  {
    id: '7',
    title: 'Pradhan Mantri Kisan Maan Dhan Yojana (PM-KMY)',
    description: 'Pension scheme for small and marginal farmers to ensure financial security.',
    eligibility: 'Small and marginal farmers aged 18-40 years',
    benefits: 'Monthly pension of ₹3,000 after 60 years',
    applicationLink: 'https://maandhan.in',
    category: 'Pension',
    deadline: null,
  },
  {
    id: '8',
    title: 'Paramparagat Krishi Vikas Yojana (PKVY)',
    description: 'Promotes organic farming practices among farmers.',
    eligibility: 'Farmers willing to practice organic farming',
    benefits: 'Financial assistance of ₹50,000 per hectare',
    applicationLink: 'https://pgsindia-ncof.gov.in',
    category: 'Organic Farming',
    deadline: null,
  },
  {
    id: '9',
    title: 'Micro Irrigation Fund (MIF)',
    description: 'Provides financial assistance for micro-irrigation systems.',
    eligibility: 'All farmers',
    benefits: 'Subsidy for drip and sprinkler irrigation systems',
    applicationLink: 'https://pmksy.gov.in',
    category: 'Irrigation',
    deadline: null,
  },
  {
    id: '10',
    title: 'National Agriculture Market (eNAM)',
    description: 'Online trading platform for agricultural commodities to ensure better prices.',
    eligibility: 'All farmers and traders',
    benefits: 'Transparent pricing and direct market access',
    applicationLink: 'https://www.enam.gov.in',
    category: 'Market Access',
    deadline: null,
  },
];

// GET /api/schemes - Get all schemes
router.get('/', (req, res) => {
  try {
    res.json({
      success: true,
      count: mockSchemes.length,
      data: mockSchemes,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch schemes',
      message: error.message,
    });
  }
});

// GET /api/schemes/:id - Get scheme by ID
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const scheme = mockSchemes.find(s => s.id === id);

    if (!scheme) {
      return res.status(404).json({
        success: false,
        error: 'Scheme not found',
      });
    }

    res.json({
      success: true,
      data: scheme,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch scheme',
      message: error.message,
    });
  }
});

// GET /api/schemes/category/:category - Get schemes by category
router.get('/category/:category', (req, res) => {
  try {
    const { category } = req.params;
    const filteredSchemes = mockSchemes.filter(
      scheme => scheme.category.toLowerCase() === category.toLowerCase()
    );

    res.json({
      success: true,
      category,
      count: filteredSchemes.length,
      data: filteredSchemes,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch schemes by category',
      message: error.message,
    });
  }
});

// GET /api/schemes/search?q=query - Search schemes
router.get('/search', (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        error: 'Query parameter "q" is required',
      });
    }

    const queryLower = q.toLowerCase();
    const filteredSchemes = mockSchemes.filter(
      scheme =>
        scheme.title.toLowerCase().includes(queryLower) ||
        scheme.description.toLowerCase().includes(queryLower) ||
        (scheme.eligibility && scheme.eligibility.toLowerCase().includes(queryLower)) ||
        (scheme.benefits && scheme.benefits.toLowerCase().includes(queryLower))
    );

    res.json({
      success: true,
      query: q,
      count: filteredSchemes.length,
      data: filteredSchemes,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Search failed',
      message: error.message,
    });
  }
});

// GET /api/schemes/categories - Get all categories
router.get('/categories/list', (req, res) => {
  try {
    const categories = [...new Set(mockSchemes.map(s => s.category).filter(Boolean))].sort();

    res.json({
      success: true,
      count: categories.length,
      data: categories,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch categories',
      message: error.message,
    });
  }
});

// GET /api/schemes/active - Get active schemes (not past deadline)
router.get('/active/list', (req, res) => {
  try {
    const now = new Date();
    const activeSchemes = mockSchemes.filter(
      scheme => !scheme.deadline || new Date(scheme.deadline) > now
    );

    res.json({
      success: true,
      count: activeSchemes.length,
      data: activeSchemes,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch active schemes',
      message: error.message,
    });
  }
});

module.exports = router;

