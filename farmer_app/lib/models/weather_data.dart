class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final String? description;
  final String? iconUrl;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    this.description,
    this.iconUrl,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] as String? ?? 'Unknown',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'Unknown',
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'iconUrl': iconUrl,
    };
  }
}

