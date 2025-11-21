import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/mandi_price.dart';

class MandiService {
  MandiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';
  static const String _baseUrl = 'https://api.data.gov.in/resource/$_resourceId';

  String get _apiKey {
    final apiKey = dotenv.env['DATA_GOV_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'DATA_GOV_API_KEY missing. Add it to your .env file to fetch live mandi data.',
      );
    }
    return apiKey;
  }

  String get _defaultState =>
      dotenv.env['BANGALORE_DEFAULT_STATE'] ?? 'Karnataka';

  String get _defaultDistrict =>
      dotenv.env['BANGALORE_DEFAULT_DISTRICT'] ?? 'Bengaluru Urban';

  Future<List<MandiPrice>> getMandiPrices({
    String? state,
    String? district,
    int limit = 50,
  }) async {
    final targetState = state ?? _defaultState;
    final targetDistrict = district ?? _defaultDistrict;

    final queryParameters = <String, String>{
      'api-key': _apiKey,
      'format': 'json',
      'limit': limit.toString(),
      'filters[state]': targetState,
      'filters[district]': targetDistrict,
      'sort[0]': 'arrival_date:desc',
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Mandi API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> records = body['records'] as List<dynamic>? ?? [];

    return records
        .map((record) => _mapRecord(record as Map<String, dynamic>))
        .whereType<MandiPrice>()
        .toList();
  }

  Future<List<MandiPrice>> searchCommodity(
    String query, {
    String? state,
    String? district,
  }) async {
    final prices =
        await getMandiPrices(state: state, district: district, limit: 100);
    return prices
        .where(
          (price) => price.commodity.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

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

