import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/government_scheme.dart';

class SchemeService {
  SchemeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  
  // Use backend API
  static const String _baseUrl = 'http://localhost:3000/api/schemes';

  Future<List<GovernmentScheme>> getSchemes() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
          
          if (data.isNotEmpty) {
            return data
                .map((scheme) => GovernmentScheme.fromJson(scheme as Map<String, dynamic>))
                .toList();
          }
        }
      }
      
      // Return mock data if API fails or returns empty
      return _getMockSchemes();
    } catch (e) {
      // Return mock data on any error
      return _getMockSchemes();
    }
  }

  /// Get schemes by category
  Future<List<GovernmentScheme>> getSchemesByCategory(String category) async {
    try {
      final uri = Uri.parse('$_baseUrl/category/$category');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
          
          if (data.isNotEmpty) {
            return data
                .map((scheme) => GovernmentScheme.fromJson(scheme as Map<String, dynamic>))
                .toList();
          }
        }
      }
      
      // Return filtered mock data if API fails or returns empty
      return _getMockSchemes()
          .where((scheme) => scheme.category?.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      // Return filtered mock data on any error
      return _getMockSchemes()
          .where((scheme) => scheme.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }
  }

  /// Search schemes by title or description
  Future<List<GovernmentScheme>> searchSchemes(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {'q': query});
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
          
          if (data.isNotEmpty) {
            return data
                .map((scheme) => GovernmentScheme.fromJson(scheme as Map<String, dynamic>))
                .toList();
          }
        }
      }
      
      // Fallback to mock data search
      final lowerQuery = query.toLowerCase();
      return _getMockSchemes()
          .where((scheme) =>
              scheme.title.toLowerCase().contains(lowerQuery) ||
              scheme.description.toLowerCase().contains(lowerQuery) ||
              (scheme.eligibility?.toLowerCase().contains(lowerQuery) ?? false) ||
              (scheme.benefits?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    } catch (e) {
      // Fallback to mock data search on any error
      final lowerQuery = query.toLowerCase();
      return _getMockSchemes()
          .where((scheme) =>
              scheme.title.toLowerCase().contains(lowerQuery) ||
              scheme.description.toLowerCase().contains(lowerQuery) ||
              (scheme.eligibility?.toLowerCase().contains(lowerQuery) ?? false) ||
              (scheme.benefits?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    }
  }

  /// Get all available categories
  Future<List<String>> getCategories() async {
    try {
      final uri = Uri.parse('$_baseUrl/categories/list');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
          
          if (data.isNotEmpty) {
            return data.map((e) => e.toString()).toList();
          }
        }
      }
      
      // Return categories from mock data
      return _getMockSchemes()
          .map((scheme) => scheme.category)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      // Return categories from mock data on any error
      return _getMockSchemes()
          .map((scheme) => scheme.category)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    }
  }

  /// Get schemes that are currently active (not past deadline)
  Future<List<GovernmentScheme>> getActiveSchemes() async {
    try {
      final uri = Uri.parse('$_baseUrl/active/list');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
          
          if (data.isNotEmpty) {
            return data
                .map((scheme) => GovernmentScheme.fromJson(scheme as Map<String, dynamic>))
                .toList();
          }
        }
      }
      
      // Return active schemes from mock data
      final now = DateTime.now();
      return _getMockSchemes()
          .where((scheme) =>
              scheme.deadline == null || scheme.deadline!.isAfter(now))
          .toList();
    } catch (e) {
      // Return active schemes from mock data on any error
      final now = DateTime.now();
      return _getMockSchemes()
          .where((scheme) =>
              scheme.deadline == null || scheme.deadline!.isAfter(now))
          .toList();
    }
  }

  /// Get a specific scheme by ID
  Future<GovernmentScheme?> getSchemeById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true && body['data'] != null) {
          return GovernmentScheme.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      
      // Fallback to mock data
      try {
        return _getMockSchemes().firstWhere((scheme) => scheme.id == id);
      } catch (_) {
        return null;
      }
    } catch (e) {
      // Fallback to mock data on any error
      try {
        return _getMockSchemes().firstWhere((scheme) => scheme.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  List<GovernmentScheme> _getMockSchemes() {
    return [
      GovernmentScheme(
        id: '1',
        title: 'Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)',
        description:
            'Direct income support scheme providing ₹6,000 per year to all landholding farmer families.',
        eligibility: 'All landholding farmer families',
        benefits: '₹6,000 per year in three equal installments',
        applicationLink: 'https://pmkisan.gov.in',
        category: 'Income Support',
      ),
      GovernmentScheme(
        id: '2',
        title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
        description:
            'Crop insurance scheme to provide financial support to farmers in case of crop loss.',
        eligibility: 'All farmers growing notified crops',
        benefits: 'Premium subsidy and comprehensive risk coverage',
        applicationLink: 'https://pmfby.gov.in',
        category: 'Insurance',
      ),
      GovernmentScheme(
        id: '3',
        title: 'Kisan Credit Card (KCC)',
        description:
            'Credit facility for farmers to meet their short-term credit requirements.',
        eligibility: 'All farmers including tenant farmers and sharecroppers',
        benefits: 'Credit up to ₹3 lakh at subsidized interest rate',
        applicationLink: 'https://www.india.gov.in/kisan-credit-card-kcc',
        category: 'Credit',
      ),
      GovernmentScheme(
        id: '4',
        title: 'Soil Health Card Scheme',
        description:
            'Scheme to provide soil health cards to farmers to optimize use of fertilizers.',
        eligibility: 'All farmers',
        benefits: 'Free soil health cards every 3 years',
        applicationLink: 'https://soilhealth.dac.gov.in',
        category: 'Agricultural Support',
      ),
      GovernmentScheme(
        id: '5',
        title: 'Pradhan Mantri Krishi Sinchai Yojana (PMKSY)',
        description:
            'Scheme to improve farm productivity and ensure better utilization of water resources.',
        eligibility: 'All farmers',
        benefits: 'Subsidy up to 55% for small and marginal farmers',
        applicationLink: 'https://pmksy.gov.in',
        category: 'Irrigation',
      ),
      GovernmentScheme(
        id: '6',
        title: 'National Mission for Sustainable Agriculture (NMSA)',
        description:
            'Promotes sustainable agriculture practices and climate-resilient farming.',
        eligibility: 'All farmers practicing sustainable agriculture',
        benefits: 'Financial assistance for sustainable practices',
        applicationLink: 'https://nmsa.dac.gov.in',
        category: 'Agricultural Support',
      ),
      GovernmentScheme(
        id: '7',
        title: 'Pradhan Mantri Kisan Maan Dhan Yojana (PM-KMY)',
        description:
            'Pension scheme for small and marginal farmers to ensure financial security.',
        eligibility: 'Small and marginal farmers aged 18-40 years',
        benefits: 'Monthly pension of ₹3,000 after 60 years',
        applicationLink: 'https://maandhan.in',
        category: 'Pension',
      ),
      GovernmentScheme(
        id: '8',
        title: 'Paramparagat Krishi Vikas Yojana (PKVY)',
        description:
            'Promotes organic farming practices among farmers.',
        eligibility: 'Farmers willing to practice organic farming',
        benefits: 'Financial assistance of ₹50,000 per hectare',
        applicationLink: 'https://pgsindia-ncof.gov.in',
        category: 'Organic Farming',
      ),
      GovernmentScheme(
        id: '9',
        title: 'Micro Irrigation Fund (MIF)',
        description:
            'Provides financial assistance for micro-irrigation systems.',
        eligibility: 'All farmers',
        benefits: 'Subsidy for drip and sprinkler irrigation systems',
        applicationLink: 'https://pmksy.gov.in',
        category: 'Irrigation',
      ),
      GovernmentScheme(
        id: '10',
        title: 'National Agriculture Market (eNAM)',
        description:
            'Online trading platform for agricultural commodities to ensure better prices.',
        eligibility: 'All farmers and traders',
        benefits: 'Transparent pricing and direct market access',
        applicationLink: 'https://www.enam.gov.in',
        category: 'Market Access',
      ),
    ];
  }
}

