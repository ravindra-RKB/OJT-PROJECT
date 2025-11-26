// lib/pages/signin_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign in failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _textField(TextEditingController c, String label, {bool obscure = false, TextInputType k = TextInputType.text}) {
    return TextField(controller: c, obscureText: obscure, keyboardType: k, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _textField(_emailController, 'Email', k: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _textField(_passwordController, 'Password', obscure: true),
            const SizedBox(height: 20),
            _loading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _signIn, child: const Text('Sign In'))),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text("Don't have an account? Sign up")),
          ],
        ),
      ),
    );
  }
}
