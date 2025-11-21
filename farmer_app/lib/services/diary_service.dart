import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/farm_diary_entry.dart';

class DiaryService {
  static const String boxName = 'farmDiaryBox';
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  Future<void> addEntry(FarmDiaryEntry entry) async {
    await _box?.put(entry.id, jsonEncode(entry.toJson()));
  }

  Future<void> updateEntry(FarmDiaryEntry entry) async {
    await _box?.put(entry.id, jsonEncode(entry.toJson()));
  }

  Future<void> deleteEntry(String id) async {
    await _box?.delete(id);
  }

  List<FarmDiaryEntry> getAllEntries() {
    final entries = <FarmDiaryEntry>[];
    if (_box != null) {
      for (var key in _box!.keys) {
        final value = _box!.get(key);
        if (value != null) {
          try {
            final json = jsonDecode(value as String);
            entries.add(FarmDiaryEntry.fromJson(json));
          } catch (e) {
            // Skip invalid entries
          }
        }
      }
    }
    return entries;
  }

  FarmDiaryEntry? getEntry(String id) {
    final value = _box?.get(id);
    if (value != null) {
      try {
        final json = jsonDecode(value as String);
        return FarmDiaryEntry.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  List<FarmDiaryEntry> getEntriesByDate(DateTime date) {
    return getAllEntries()
        .where((entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day)
        .toList();
  }

  Future<void> clearAll() async {
    await _box?.clear();
  }
}

