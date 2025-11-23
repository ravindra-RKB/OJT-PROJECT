import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  UserProfile? _profile;
  bool _loading = false;
  bool _initialized = false;
  String? _currentUserId;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get initialized => _initialized;

  ProfileProvider() {
    // Listen to auth state changes to reload profile when user changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out - clear profile
        _profile = null;
        _currentUserId = null;
        _initialized = false;
        notifyListeners();
      } else if (user.uid != _currentUserId) {
        // New user logged in - reload profile
        _currentUserId = user.uid;
        _initialized = false;
        init();
      }
    });
  }

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _profile = null;
      _initialized = true;
      notifyListeners();
      return;
    }

    // If already initialized for this user, don't reinitialize
    if (_initialized && _currentUserId == user.uid) {
      return;
    }
    
    _loading = true;
    _currentUserId = user.uid;
    notifyListeners();

    try {
      await _profileService.init();
      _profile = await _profileService.getProfile(user.uid);
      if (_profile == null) {
        // Create default profile from Firebase user only if no profile exists
        _profile = UserProfile(
          userId: user.uid,
          name: user.displayName ?? user.email?.split('@')[0] ?? 'Farmer',
          email: user.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _profileService.saveProfile(_profile!);
        debugPrint('Created new profile for user: ${user.uid}');
      } else {
        debugPrint('Loaded existing profile for user: ${user.uid}');
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
      // Ensure service is initialized
      await _profileService.init();
      
      final profileToSave = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
        createdAt: _profile?.createdAt ?? DateTime.now(),
      );
      debugPrint('Saving profile for user: ${profileToSave.userId}');
      await _profileService.saveProfile(profileToSave);
      _profile = profileToSave;
      debugPrint('Profile saved successfully');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _profileService.init();
      _profile = await _profileService.getProfile(user.uid);
      notifyListeners();
    }
  }
}

