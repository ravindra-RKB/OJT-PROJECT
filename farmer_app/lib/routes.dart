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
import 'pages/disease_detection_screen.dart';
import 'pages/market/product_list.dart';
import 'pages/market/checkout_page.dart';
import 'pages/market/order_tracking_page.dart';
import 'pages/seller/add_product.dart';
import 'pages/seller/seller_orders_page.dart';
import 'pages/market/cart_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const OnboardingLoginPage(),
  '/signin': (context) => const SignInPage(),
  '/signup': (context) => const SignUpPage(),
  '/home': (context) => const HomePage(),
  '/weather': (context) => const WeatherPage(),
  '/market': (context) => const MarketPricesPage(),
  '/marketplace': (context) => const ProductListPage(),
  '/seller/add-product': (context) => const AddProductPage(),
  '/seller/orders': (context) => const SellerOrdersPage(),
  '/cart': (context) => const CartPage(),
  '/checkout': (context) => const CheckoutPage(),
  '/my-orders': (context) => const OrderTrackingPage(),
  '/diary': (context) => const FarmDiaryPage(),
  '/schemes': (context) => const SchemesPage(),
  '/profile': (context) => const ProfilePage(),
  '/disease-detection': (context) => const DiseaseDetectionScreen(),
};
