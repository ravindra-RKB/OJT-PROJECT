import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agriculture Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const OnboardingLoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingLoginPage extends StatelessWidget {
  const OnboardingLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top image (covering about 60% of height)
          SizedBox(
            height: size.height * 0.60,
            width: double.infinity,
            child: Image.asset(
              'assets/farm.jpg', // <-- add your image here
              fit: BoxFit.cover,
            ),
          ),

          // Bottom rounded panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.46, // overlap a bit with image
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF454545), // dark grey
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Title
                    const Text(
                      'Agriculture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'Agriculture is a marketplace where you can find the best fruits and vegetable in Bangladesh',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFCECECE),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),

                    // Buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: sign-in action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8BC34A), // green-ish
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: sign-up action
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBDBDBD)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFFEEEEEE),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // small text link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: handle sign up link
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Dot(isActive: false),
                        const SizedBox(width: 8),
                        _Dot(isActive: false),
                        const SizedBox(width: 8),
                        _Dot(isActive: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // optional small top-left leaf overlay to mimic image cropping
          // You can add additional positioned widgets if you want more complex overlapping
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
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFBDBDBD),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
