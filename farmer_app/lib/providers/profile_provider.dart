import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  UserProfile? _profile;
  bool _loading = false;
  bool _initialized = false;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    
    _loading = true;
    notifyListeners();

    try {
      await _profileService.init();
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        _profile = await _profileService.getProfile(supabaseUser.id);
        if (_profile == null) {
          // Create default profile from Supabase user
          final displayName = supabaseUser.userMetadata?['name'] ?? supabaseUser.email?.split('@')[0] ?? 'Farmer';
          _profile = UserProfile(
            userId: supabaseUser.id,
            name: displayName,
            email: supabaseUser.email ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _profileService.saveProfile(_profile!);
        }
      }
    } catch (e) {
      debugPrint('Error initializing profile: $e');
    } finally {
      _loading = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _loading = true;
    notifyListeners();

    try {
      final profileToSave = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
        createdAt: _profile?.createdAt ?? DateTime.now(),
      );
      await _profileService.saveProfile(profileToSave);
      _profile = profileToSave;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null) {
      _profile = await _profileService.getProfile(supabaseUser.id);
      notifyListeners();
    }
  }
}



