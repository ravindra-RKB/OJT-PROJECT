import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  String get _apiKey {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'OPENWEATHER_API_KEY missing. Add it to your .env file to fetch live weather data.',
      );
    }
    return apiKey;
  }

  Future<WeatherData> getWeatherData(String city) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': city,
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Weather API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    final weatherList = data['weather'] as List<dynamic>? ?? [];
    final mainWeather = weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : {};
    final mainData = data['main'] as Map<String, dynamic>? ?? {};
    final windData = data['wind'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      location: (data['name'] as String?) ?? city,
      temperature: (mainData['temp'] as num?)?.toDouble() ?? 0.0,
      condition: (mainWeather['main'] as String?) ?? 'Unknown',
      humidity: (mainData['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (windData['speed'] as num?)?.toDouble() ?? 0.0,
      description: mainWeather['description'] as String?,
      iconUrl: mainWeather['icon'] != null
          ? 'https://openweathermap.org/img/wn/${mainWeather['icon']}@2x.png'
          : null,
    );
  }
}

