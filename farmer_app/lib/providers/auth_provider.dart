import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

/// Lightweight user model to preserve `.uid` usage across the codebase.
class SimpleUser {
  final String uid;
  final String? email;
  SimpleUser({required this.uid, this.email});

  String? get displayName => email; // keep compatibility with existing code expecting displayName
  String? get photoURL => null;
}

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  SimpleUser? _user;

  SimpleUser? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth changes
    _supabase.client.auth.onAuthStateChange.listen((event) {
      final u = _supabase.currentUser;
      if (u != null) {
        _user = SimpleUser(uid: u.id, email: u.email);
      } else {
        _user = null;
      }
      notifyListeners();
    });
    // initialize current state
    final u = _supabase.currentUser;
    if (u != null) _user = SimpleUser(uid: u.id, email: u.email);
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _supabase.signIn(email, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await _supabase.signUp(email, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.signOut();
  }
}

