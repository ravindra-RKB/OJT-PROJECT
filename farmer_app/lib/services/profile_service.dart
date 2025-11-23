import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class ProfileService {
  static const String boxName = 'userProfileBox';
  Box? _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _box = await Hive.openBox(boxName);
      _isInitialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _ensureInitialized();
    if (_box == null) {
      throw Exception('Profile box not initialized');
    }
    final profileJson = profile.copyWith(updatedAt: DateTime.now()).toJson();
    await _box!.put(
      profile.userId,
      jsonEncode(profileJson),
    );
    // Verify the save was successful
    final saved = await getProfile(profile.userId);
    if (saved == null) {
      throw Exception('Failed to save profile - verification failed');
    }
  }

  Future<UserProfile?> getProfile(String userId) async {
    await _ensureInitialized();
    if (_box == null) {
      return null;
    }
    final value = _box!.get(userId);
    if (value != null) {
      try {
        final json = jsonDecode(value as String);
        return UserProfile.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> deleteProfile(String userId) async {
    await _ensureInitialized();
    if (_box != null) {
      await _box!.delete(userId);
    }
  }
}

