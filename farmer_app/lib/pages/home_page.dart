// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/mandi_provider.dart';
import '../providers/connectivity_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherData();
      context.read<MandiProvider>().fetchPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final connectivityProvider = context.watch<ConnectivityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF617A2E),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.email?.split('@')[0] ?? 'Farmer'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              color: Color(0xFFDFE6C8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<WeatherProvider>().fetchWeatherData();
                          context.read<MandiProvider>().fetchPrices();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                  if (!connectivityProvider.isConnected)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Offline Mode',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Dashboard content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.cloud,
                            title: 'Weather',
                            color: Colors.blue,
                            onTap: () => Navigator.pushNamed(context, '/weather'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.shopping_bag,
                            title: 'Market Prices',
                            color: Colors.green,
                            onTap: () => Navigator.pushNamed(context, '/market'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.book,
                            title: 'Farm Diary',
                            color: Colors.orange,
                            onTap: () => Navigator.pushNamed(context, '/diary'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.assignment,
                            title: 'Schemes',
                            color: Colors.purple,
                            onTap: () => Navigator.pushNamed(context, '/schemes'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weather widget
                    const Text(
                      'Weather Update',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<WeatherProvider>(
                      builder: (context, weatherProvider, child) {
                        if (weatherProvider.loading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final weather = weatherProvider.weatherData;
                        if (weather == null) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No weather data available'),
                            ),
                          );
                        }
                        return _buildWeatherCard(weather);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Market prices widget
                    const Text(
                      'Today\'s Market Prices',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<MandiProvider>(
                      builder: (context, mandiProvider, child) {
                        if (mandiProvider.loading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final prices = mandiProvider.prices.take(3).toList();
                        if (prices.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No price data available'),
                            ),
                          );
                        }
                        return Column(
                          children: prices
                              .map((price) => _buildPriceListItem(price))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/market'),
                        child: const Text('View All Prices'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(weather) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF617A2E), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C - ${weather.condition}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/weather'),
            child: const Text(
              'View Details',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceListItem(price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            price.commodity,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '₹${price.price.toStringAsFixed(2)}/${price.unit}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF617A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(Icons.home, 0, () => setState(() => _currentIndex = 0)),
              const SizedBox(width: 8),
              _buildNavItem(Icons.cloud, 1, () => Navigator.pushNamed(context, '/weather')),
              const SizedBox(width: 8),
              _buildNavItem(Icons.book, 2, () => Navigator.pushNamed(context, '/diary')),
              const SizedBox(width: 8),
              _buildNavItem(Icons.person, 3, () => Navigator.pushNamed(context, '/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, VoidCallback onTap) {
    final isSelected = _currentIndex == index;
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
        size: isSelected ? 28 : 24,
      ),
    );
  }
}
