import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class ProfileService {
  static const String boxName = 'userProfileBox';
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box?.put(
      profile.userId,
      jsonEncode(profile.copyWith(updatedAt: DateTime.now()).toJson()),
    );
  }

  Future<UserProfile?> getProfile(String userId) async {
    final value = _box?.get(userId);
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
    await _box?.delete(userId);
  }
}



