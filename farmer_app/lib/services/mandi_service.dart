import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/mandi_price.dart';

class MandiService {
  MandiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Use backend API instead of direct data.gov.in API
  static const String _baseUrl = 'http://localhost:3000/api/market-prices';

  String get _defaultState =>
      dotenv.env['BANGALORE_DEFAULT_STATE'] ?? 'Karnataka';

  String get _defaultDistrict =>
      dotenv.env['BANGALORE_DEFAULT_DISTRICT'] ?? 'Bengaluru Urban';

  Future<List<MandiPrice>> getMandiPrices({
    String? state,
    String? district,
    int limit = 50,
  }) async {
    try {
      final targetState = state ?? _defaultState;
      final targetDistrict = district ?? _defaultDistrict;

      final queryParameters = <String, String>{
        'state': targetState,
        'district': targetDistrict,
        'limit': limit.toString(),
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Return mock data on API error
        return _getMockPrices();
      }

      final Map<String, dynamic> body =
          json.decode(response.body) as Map<String, dynamic>;
      
      if (!body['success'] as bool? ?? false) {
        // Return mock data on API error
        return _getMockPrices();
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];

      if (data.isEmpty) {
        // Return mock data if API returns empty
        return _getMockPrices();
      }

      return data
          .map((record) => _mapRecordFromBackend(record as Map<String, dynamic>))
          .whereType<MandiPrice>()
          .toList();
    } catch (e) {
      // Return mock data on any error
      return _getMockPrices();
    }
  }

  Future<List<MandiPrice>> searchCommodity(
    String query, {
    String? state,
    String? district,
  }) async {
    try {
      final targetState = state ?? _defaultState;
      final targetDistrict = district ?? _defaultDistrict;

      final queryParameters = <String, String>{
        'q': query,
        'state': targetState,
        'district': targetDistrict,
      };

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParameters);
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Return filtered mock data on API error
        return _getMockPrices().where((p) => 
          p.commodity.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      final Map<String, dynamic> body =
          json.decode(response.body) as Map<String, dynamic>;
      
      if (!body['success'] as bool? ?? false) {
        // Return filtered mock data on API error
        return _getMockPrices().where((p) => 
          p.commodity.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];

      if (data.isEmpty) {
        // Return filtered mock data if API returns empty
        return _getMockPrices().where((p) => 
          p.commodity.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      return data
          .map((record) => _mapRecordFromBackend(record as Map<String, dynamic>))
          .whereType<MandiPrice>()
          .toList();
    } catch (e) {
      // Return filtered mock data on any error
      return _getMockPrices().where((p) => 
        p.commodity.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  /// Get market prices for a specific commodity
  Future<List<MandiPrice>> getPricesByCommodity(
    String commodity, {
    String? state,
    String? district,
    int limit = 50,
  }) async {
    final targetState = state ?? _defaultState;
    final targetDistrict = district ?? _defaultDistrict;

    final uri = Uri.parse('$_baseUrl/commodity/$commodity').replace(queryParameters: {
      'state': targetState,
      'district': targetDistrict,
      'limit': limit.toString(),
    });
    
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Mandi API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    
    if (!body['success'] as bool? ?? false) {
      throw Exception(body['error'] as String? ?? 'Unknown error');
    }

    final List<dynamic> data = body['data'] as List<dynamic>? ?? [];

    return data
        .map((record) => _mapRecordFromBackend(record as Map<String, dynamic>))
        .whereType<MandiPrice>()
        .toList();
  }

  /// Get price trends for a commodity over time
  Future<Map<String, double>> getPriceTrends(
    String commodity, {
    String? state,
    String? district,
    int days = 30,
  }) async {
    final targetState = state ?? _defaultState;
    final targetDistrict = district ?? _defaultDistrict;

    final uri = Uri.parse('$_baseUrl/trends/$commodity').replace(queryParameters: {
      'state': targetState,
      'district': targetDistrict,
      'days': days.toString(),
    });
    
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Trends API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    
    if (!body['success'] as bool? ?? false) {
      throw Exception(body['error'] as String? ?? 'Unknown error');
    }

    final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? {};
    
    // Convert string keys to double values
    final trends = <String, double>{};
    data.forEach((key, value) {
      if (value is num) {
        trends[key] = value.toDouble();
      }
    });

    return trends;
  }

  /// Get all available states
  Future<List<String>> getAllStates() async {
    final uri = Uri.parse('$_baseUrl/states');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'States API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    
    if (!body['success'] as bool? ?? false) {
      throw Exception(body['error'] as String? ?? 'Unknown error');
    }

    final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => e.toString()).toList();
  }

  /// Get all districts for a state
  Future<List<String>> getDistrictsByState(String state) async {
    final uri = Uri.parse('$_baseUrl/districts/$state');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Districts API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    
    if (!body['success'] as bool? ?? false) {
      throw Exception(body['error'] as String? ?? 'Unknown error');
    }

    final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => e.toString()).toList();
  }

  /// Get prices within a date range
  Future<List<MandiPrice>> getPricesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? commodity,
    String? state,
    String? district,
    int limit = 100,
  }) async {
    final prices = commodity != null
        ? await getPricesByCommodity(
            commodity,
            state: state,
            district: district,
            limit: limit * 2,
          )
        : await getMandiPrices(
            state: state,
            district: district,
            limit: limit * 2,
          );

    return prices
        .where((price) =>
            price.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            price.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // _mapRecord is intentionally kept for compatibility with older backends.
  // ignore: unused_element
  MandiPrice? _mapRecord(Map<String, dynamic> record) {
    final commodity = record['commodity'] as String?;
    final market = record['market'] as String?;
    final modalPrice = record['modal_price'] as String? ?? record['max_price'] as String?;

    if (commodity == null || market == null || modalPrice == null) {
      return null;
    }

    return MandiPrice(
      commodity: commodity,
      market: market,
      price: double.tryParse(modalPrice) ?? 0.0,
      unit: record['unit_of_price'] as String? ?? 'Quintal',
      date: _parseArrivalDate(record['arrival_date'] as String?),
      state: record['state'] as String?,
      district: record['district'] as String?,
    );
  }

  MandiPrice? _mapRecordFromBackend(Map<String, dynamic> record) {
    final commodity = record['commodity'] as String?;
    final market = record['market'] as String?;
    final price = record['price'];

    if (commodity == null || market == null || price == null) {
      return null;
    }

    return MandiPrice(
      commodity: commodity,
      market: market,
      price: (price is num) ? price.toDouble() : double.tryParse(price.toString()) ?? 0.0,
      unit: record['unit'] as String? ?? 'Quintal',
      date: record['date'] != null 
          ? DateTime.tryParse(record['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      state: record['state'] as String?,
      district: record['district'] as String?,
    );
  }

  List<MandiPrice> _getMockPrices() {
    final now = DateTime.now();
    return [
      MandiPrice(
        commodity: 'Rice',
        market: 'Yeshwanthpur APMC',
        price: 2850.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Wheat',
        market: 'Yeshwanthpur APMC',
        price: 2450.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Tomato',
        market: 'Yeshwanthpur APMC',
        price: 3200.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Onion',
        market: 'Yeshwanthpur APMC',
        price: 2800.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Potato',
        market: 'Yeshwanthpur APMC',
        price: 1800.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Coconut',
        market: 'Yeshwanthpur APMC',
        price: 8500.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Sugarcane',
        market: 'Yeshwanthpur APMC',
        price: 320.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
      MandiPrice(
        commodity: 'Maize',
        market: 'Yeshwanthpur APMC',
        price: 2100.0,
        unit: 'Quintal',
        date: now.subtract(const Duration(days: 1)),
        state: 'Karnataka',
        district: 'Bengaluru Urban',
      ),
    ];
  }

  DateTime _parseArrivalDate(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.now();
    }
    try {
      if (value.contains('/')) {
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }
}

