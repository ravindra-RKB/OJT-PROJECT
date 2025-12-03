// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/mandi_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/profile_provider.dart';
import '../models/weather_data.dart';
import '../models/mandi_price.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WeatherProvider>().fetchWeatherData();
        context.read<MandiProvider>().fetchPrices();
        context.read<ProfileProvider>().init();
      }
    });

    // Initialize animations
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimationController.forward();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final connectivityProvider = context.watch<ConnectivityProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF617A2E),
              const Color(0xFF8BC34A).withValues(alpha: 0.3),
              const Color(0xFFF3EFE7),
            ],
            stops: const [0.0, 0.15, 0.15],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Modern Header with Animation
              FadeTransition(
                opacity: _headerAnimation,
                child: _buildModernHeader(user, connectivityProvider, profileProvider),
              ),
              // Dashboard content with animation
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _cardAnimationController,
                    child: _buildDashboardContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  Widget _buildModernHeader(User? user, ConnectivityProvider connectivityProvider, ProfileProvider profileProvider) {
    // Get user name from profile, fallback to email or default
    String userName = 'Farmer';
    if (profileProvider.profile != null && profileProvider.profile!.name.isNotEmpty) {
      userName = profileProvider.profile!.name;
    } else if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      userName = user.displayName!;
    } else if (user != null && user.email != null) {
      userName = user.email!.split('@')[0];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF617A2E),
            const Color(0xFF8BC34A).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName! 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    context.read<WeatherProvider>().fetchWeatherData();
                    context.read<MandiProvider>().fetchPrices();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ],
          ),
          if (!connectivityProvider.isConnected)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Offline Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions with modern cards
          _buildSectionTitle('Quick Actions', Icons.dashboard),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(),
          const SizedBox(height: 32),
          _buildSectionTitle(
            'Plant Disease Detection',
            Icons.biotech_outlined,
          ),
          const SizedBox(height: 16),
          _buildDiseaseDetectionSection(),
          const SizedBox(height: 32),
          // Weather Update
          _buildSectionTitle('Weather Update', Icons.wb_sunny),
          const SizedBox(height: 16),
          _buildWeatherSection(),
          const SizedBox(height: 32),
          // Market Prices
          _buildSectionTitle('Today\'s Market Prices', Icons.trending_up),
          const SizedBox(height: 16),
          _buildMarketPricesSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDiseaseDetectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF617A2E), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.biotech, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Plant Disease Detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Scan crop leaves, get instant diagnosis and pesticide guidance.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Camera/gallery image support with live preview.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TFLite powered disease detection with confidence score.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Organic & chemical pesticide guide with dosage and precautions.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF617A2E),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/disease-detection'),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              label: const Text(
                'Open Detector',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF617A2E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF617A2E), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2C3E1F),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnimatedActionCard(
                icon: Icons.cloud,
                title: 'Weather',
                subtitle: 'Forecast',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/weather'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedActionCard(
                icon: Icons.shopping_bag,
                title: 'Marketplace',
                subtitle: 'Buy & Sell',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/marketplace'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedActionCard(
                icon: Icons.book,
                title: 'Farm',
                subtitle: 'Diary',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/diary'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedActionCard(
                icon: Icons.biotech,
                title: 'Disease',
                subtitle: 'Detection',
                color: Colors.red,
                onTap: () =>
                    Navigator.pushNamed(context, '/disease-detection'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Spacer(),
            Expanded(
              child: _buildAnimatedActionCard(
                icon: Icons.assignment,
                title: 'Govt',
                subtitle: 'Schemes',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/schemes'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E1F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherSection() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.loading) {
          return _buildLoadingCard();
        }
        final weather = weatherProvider.weatherData;
        if (weather == null) {
          return _buildEmptyCard('No weather data available');
        }
        return _buildModernWeatherCard(weather);
      },
    );
  }

  Widget _buildModernWeatherCard(WeatherData weather) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF617A2E),
            const Color(0xFF8BC34A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.temperature.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '°C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weather.condition,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/weather'),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPricesSection() {
    return Consumer<MandiProvider>(
      builder: (context, mandiProvider, child) {
        if (mandiProvider.loading) {
          return _buildLoadingCard();
        }
        final prices = mandiProvider.prices.take(3).toList();
        if (prices.isEmpty) {
          return _buildEmptyCard('No price data available');
        }
        return Column(
          children: [
            ...prices.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: entry.key < prices.length - 1 ? 12 : 0),
                child: _buildModernPriceCard(entry.value),
              );
            }),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/market'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View All Prices'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF617A2E),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernPriceCard(MandiPrice price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF617A2E).withValues(alpha: 0.2),
                  const Color(0xFF8BC34A).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Color(0xFF617A2E),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.commodity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price.market,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${price.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF617A2E),
                ),
              ),
              Text(
                '/${price.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF617A2E)),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNavBar() {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, 'Home'),
          _buildNavItem(Icons.cloud, 1, 'Weather'),
          _buildNavItem(Icons.book, 2, 'Diary'),
          _buildNavItem(Icons.person, 3, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) Navigator.pushNamed(context, '/weather');
        if (index == 2) Navigator.pushNamed(context, '/diary');
        if (index == 3) Navigator.pushNamed(context, '/profile');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF617A2E).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF617A2E) : Colors.grey,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF617A2E) : Colors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
