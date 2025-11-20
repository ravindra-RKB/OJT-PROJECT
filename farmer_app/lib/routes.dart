// lib/routes.dart
import 'package:flutter/material.dart';
import 'pages/onbording_login_page.dart';
import 'pages/signin_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const OnboardingLoginPage(),
  '/signin': (context) => const SignInPage(),
  '/signup': (context) => const SignUpPage(),
  '/home': (context) => const HomePage(),
};
