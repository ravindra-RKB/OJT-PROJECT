// lib/pages/onboarding_login_page.dart
import 'package:flutter/material.dart';

class OnboardingLoginPage extends StatelessWidget {
  const OnboardingLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: size.height * 0.60,
            width: double.infinity,
            child: Image.asset('assets/farm.jpg', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.46,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF454545),
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const Text(
                      'Agriculture',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Agriculture is a marketplace where you can find the best fruits and vegetables in India',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFCECECE), fontSize: 13),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/signin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8BC34A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: const Text('Sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, '/signup'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBDBDBD)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFEEEEEE))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 12)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text('Sign up', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                      _Dot(isActive: false),
                      SizedBox(width: 8),
                      _Dot(isActive: false),
                      SizedBox(width: 8),
                      _Dot(isActive: true),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(color: isActive ? Colors.white : const Color(0xFFBDBDBD), borderRadius: BorderRadius.circular(8)),
    );
  }
}
