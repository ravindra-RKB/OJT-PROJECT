import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  
  // Open-Meteo API - Free, no API key required, works for all India locations
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  // Indian cities mapping for better search
  static const Map<String, Map<String, double>> _indianCities = {
    'Bengaluru': {'lat': 12.9716, 'lon': 77.5946},
    'Bangalore': {'lat': 12.9716, 'lon': 77.5946},
    'Mumbai': {'lat': 19.0760, 'lon': 72.8777},
    'Delhi': {'lat': 28.6139, 'lon': 77.2090},
    'Kolkata': {'lat': 22.5726, 'lon': 88.3639},
    'Chennai': {'lat': 13.0827, 'lon': 80.2707},
    'Hyderabad': {'lat': 17.3850, 'lon': 78.4867},
    'Pune': {'lat': 18.5204, 'lon': 73.8567},
    'Ahmedabad': {'lat': 23.0225, 'lon': 72.5714},
    'Jaipur': {'lat': 26.9124, 'lon': 75.7873},
    'Surat': {'lat': 21.1702, 'lon': 72.8311},
    'Lucknow': {'lat': 26.8467, 'lon': 80.9462},
    'Kanpur': {'lat': 26.4499, 'lon': 80.3319},
    'Nagpur': {'lat': 21.1458, 'lon': 79.0882},
    'Indore': {'lat': 22.7196, 'lon': 75.8577},
    'Thane': {'lat': 19.2183, 'lon': 72.9781},
    'Bhopal': {'lat': 23.2599, 'lon': 77.4126},
    'Visakhapatnam': {'lat': 17.6868, 'lon': 83.2185},
    'Patna': {'lat': 25.5941, 'lon': 85.1376},
    'Vadodara': {'lat': 22.3072, 'lon': 73.1812},
    'Ghaziabad': {'lat': 28.6692, 'lon': 77.4538},
    'Ludhiana': {'lat': 30.9010, 'lon': 75.8573},
    'Agra': {'lat': 27.1767, 'lon': 78.0081},
    'Nashik': {'lat': 19.9975, 'lon': 73.7898},
    'Faridabad': {'lat': 28.4089, 'lon': 77.3178},
    'Meerut': {'lat': 28.9845, 'lon': 77.7064},
    'Rajkot': {'lat': 22.3039, 'lon': 70.8022},
    'Varanasi': {'lat': 25.3176, 'lon': 82.9739},
    'Srinagar': {'lat': 34.0837, 'lon': 74.7973},
    'Amritsar': {'lat': 31.6340, 'lon': 74.8723},
    'Chandigarh': {'lat': 30.7333, 'lon': 76.7794},
    'Coimbatore': {'lat': 11.0168, 'lon': 76.9558},
    'Kochi': {'lat': 9.9312, 'lon': 76.2673},
    'Mysore': {'lat': 12.2958, 'lon': 76.6394},
    'Mysuru': {'lat': 12.2958, 'lon': 76.6394},
  };

  Future<Map<String, double>> _getCoordinates(String city) async {
    // First check our Indian cities database
    final cityKey = city.trim();
    if (_indianCities.containsKey(cityKey)) {
      return _indianCities[cityKey]!;
    }

    // Try with common variations
    final variations = [
      cityKey,
      '$cityKey, India',
      '$cityKey, Karnataka',
      '$cityKey, Maharashtra',
      '$cityKey, Tamil Nadu',
      '$cityKey, West Bengal',
      '$cityKey, Uttar Pradesh',
    ];

    for (final query in variations) {
      try {
        final uri = Uri.parse(_geocodingUrl).replace(
          queryParameters: {
            'name': query,
            'count': '1',
            'language': 'en',
            'format': 'json',
          },
        );

        final response = await _client.get(uri).timeout(
          const Duration(seconds: 5),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final results = data['results'] as List<dynamic>?;
          
          if (results != null && results.isNotEmpty) {
            final result = results.first as Map<String, dynamic>;
            final lat = (result['latitude'] as num?)?.toDouble();
            final lon = (result['longitude'] as num?)?.toDouble();
            
            if (lat != null && lon != null) {
              return {'lat': lat, 'lon': lon};
            }
          }
        }
      } catch (e) {
        // Continue to next variation
        continue;
      }
    }

    // Default to Bengaluru if not found
    return _indianCities['Bengaluru']!;
  }

  String _getWeatherCondition(int weatherCode) {
    // WMO Weather interpretation codes
    if (weatherCode == 0) return 'Clear Sky';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 57) return 'Drizzle';
    if (weatherCode <= 67) return 'Rain';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain Showers';
    if (weatherCode <= 86) return 'Snow Showers';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  String _getWeatherDescription(int weatherCode) {
    if (weatherCode == 0) return 'Clear and sunny day';
    if (weatherCode <= 3) return 'Partly cloudy conditions';
    if (weatherCode <= 48) return 'Foggy weather';
    if (weatherCode <= 57) return 'Light drizzle';
    if (weatherCode <= 67) return 'Rainy conditions';
    if (weatherCode <= 77) return 'Snowy weather';
    if (weatherCode <= 82) return 'Heavy rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    if (weatherCode <= 99) return 'Thunderstorm with rain';
    return 'Good weather for farming';
  }

  Future<WeatherData> getWeatherData(String city) async {
    try {
      // Get coordinates for the city
      final coords = await _getCoordinates(city);
      final lat = coords['lat']!;
      final lon = coords['lon']!;

      // Fetch current weather
      final uri = Uri.parse(_weatherUrl).replace(
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'timezone': 'Asia/Kolkata',
          'forecast_days': '1',
        },
      );

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>? ?? {};

      final temperature = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
      final humidity = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0.0;
      final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
      final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

      final condition = _getWeatherCondition(weatherCode);
      final description = _getWeatherDescription(weatherCode);

      return WeatherData(
        location: city,
        temperature: temperature,
        condition: condition,
        humidity: humidity,
        windSpeed: windSpeed * 3.6, // Convert m/s to km/h
        description: description,
        iconUrl: null,
      );
    } catch (e) {
      // Return default data for Bengaluru on error
      return WeatherData(
        location: city,
        temperature: 28.5,
        condition: 'Partly Cloudy',
        humidity: 65.0,
        windSpeed: 12.5,
        description: 'Weather data temporarily unavailable',
        iconUrl: null,
      );
    }
  }
}
