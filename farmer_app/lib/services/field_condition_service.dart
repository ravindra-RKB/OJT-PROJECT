import 'dart:convert';

import 'package:http/http.dart' as http;

class FieldConditionData {
  final double temperature;
  final double humidity;
  final double apparentTemperature;
  final double precipitation;
  final DateTime fetchedAt;

  FieldConditionData({
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.fetchedAt,
  });
}

class FieldConditionService {
  final http.Client _client;

  FieldConditionService({http.Client? client}) : _client = client ?? http.Client();

  Future<FieldConditionData> fetchConditions({
    double latitude = 28.6139,
    double longitude = 77.2090,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation',
        'forecast_days': '1',
        'timezone': 'auto',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Unable to fetch field conditions (code ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = (data['current'] ?? {}) as Map<String, dynamic>;

    return FieldConditionData(
      temperature: ((current['temperature_2m'] ?? 0) as num).toDouble(),
      humidity: ((current['relative_humidity_2m'] ?? 0) as num).toDouble(),
      apparentTemperature: ((current['apparent_temperature'] ?? 0) as num).toDouble(),
      precipitation: ((current['precipitation'] ?? 0) as num).toDouble(),
      fetchedAt: DateTime.tryParse(current['time'] ?? '') ?? DateTime.now(),
    );
  }
}

