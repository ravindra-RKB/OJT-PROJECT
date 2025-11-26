import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _loading = false;
  String? _error;
  String _location = 'Bengaluru'; // Default location - works for all India

  WeatherData? get weatherData => _weatherData;
  bool get loading => _loading;
  String? get error => _error;
  String get location => _location;

  Future<void> fetchWeatherData([String? city]) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getWeatherData(city ?? _location);
      if (city != null) {
        _location = city;
      }
    } catch (e) {
      _error = 'Failed to fetch weather data: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setLocation(String location) {
    _location = location;
    fetchWeatherData();
  }
}

