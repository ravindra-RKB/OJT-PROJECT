import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not set in environment');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authCallbackUrlHostname: 'login-callback',
    );

    client = Supabase.instance.client;
  }

  // Auth helpers (use dynamic types to avoid strict coupling to package type names)
  dynamic get currentUser => client.auth.currentUser;

  Stream<dynamic> onAuthStateChange() => client.auth.onAuthStateChange;

  Future<dynamic> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<dynamic> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
