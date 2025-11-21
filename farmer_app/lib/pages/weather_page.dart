import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE7),
      appBar: AppBar(
        title: const Text('Weather Updates'),
        backgroundColor: const Color(0xFF617A2E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(weatherProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => weatherProvider.fetchWeatherData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final weather = weatherProvider.weatherData;
          if (weather == null) {
            return const Center(child: Text('No weather data available'));
          }

          return RefreshIndicator(
            onRefresh: () => weatherProvider.fetchWeatherData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main weather card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF617A2E), Color(0xFF8BC34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          weather.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        if (weather.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            weather.description!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: '${weather.humidity.toStringAsFixed(0)}%',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Agricultural tips based on weather
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agricultural Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTipItem(
                          'Ideal conditions for crop growth',
                          'Temperature and humidity are favorable for most crops.',
                        ),
                        const SizedBox(height: 8),
                        _buildTipItem(
                          'Irrigation recommendation',
                          'Moderate watering recommended based on current conditions.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF617A2E)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline, color: Color(0xFF8BC34A), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

