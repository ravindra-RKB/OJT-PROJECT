// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Simple top greeting + search + weather stub (you can replace with the full widget later)
            Container(
              decoration: const BoxDecoration(color: Color(0xFF617A2E), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Hello, Farmers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Sunday, 01 Dec 2024', style: TextStyle(color: Color(0xFFDFE6C8), fontSize: 12)),
                      ]),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.refresh, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 44, decoration: BoxDecoration(color: const Color(0xFF6F8C37), borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: const [Icon(Icons.search, color: Color(0xFFDDE6C8)), SizedBox(width: 8), Expanded(child: Text('Search here...', style: TextStyle(color: Color(0xFFDDE6C8))))])),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('My Fields', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(onPressed: () => _signOut(context), icon: const Icon(Icons.logout)),
              ]),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(color: Colors.white, child: Center(child: Text(user != null ? 'Welcome, ${user.email}' : 'Welcome!', style: const TextStyle(fontSize: 18)))),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            height: 56,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0,4))]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.home, color: Colors.white)),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.cloud, color: Colors.white)),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.white)),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_today, color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }
}
