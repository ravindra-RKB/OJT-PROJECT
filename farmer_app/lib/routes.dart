// lib/routes.dart
import 'package:flutter/material.dart';
import 'pages/onbording_login_page.dart';
import 'pages/signin_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/weather_page.dart';
import 'pages/market_prices_page.dart';
import 'pages/farm_diary_page.dart';
import 'pages/schemes_page.dart';
import 'pages/profile_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const OnboardingLoginPage(),
  '/signin': (context) => const SignInPage(),
  '/signup': (context) => const SignUpPage(),
  '/home': (context) => const HomePage(),
  '/weather': (context) => const WeatherPage(),
  '/market': (context) => const MarketPricesPage(),
  '/diary': (context) => const FarmDiaryPage(),
  '/schemes': (context) => const SchemesPage(),
  '/profile': (context) => const ProfilePage(),
};
