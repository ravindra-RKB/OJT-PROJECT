import 'package:flutter/foundation.dart';
import '../models/farm_diary_entry.dart';
import '../services/diary_service.dart';

class DiaryProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  List<FarmDiaryEntry> _entries = [];
  bool _loading = false;
  bool _initialized = false;

  List<FarmDiaryEntry> get entries => _entries;
  bool get loading => _loading;

  Future<void> init() async {
    if (!_initialized) {
      await _diaryService.init();
      _initialized = true;
      await loadEntries();
    }
  }

  Future<void> loadEntries() async {
    _loading = true;
    notifyListeners();

    _entries = _diaryService.getAllEntries();
    _entries.sort((a, b) => b.date.compareTo(a.date));

    _loading = false;
    notifyListeners();
  }

  Future<void> addEntry(FarmDiaryEntry entry) async {
    await _diaryService.addEntry(entry);
    await loadEntries();
  }

  Future<void> updateEntry(FarmDiaryEntry entry) async {
    await _diaryService.updateEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _diaryService.deleteEntry(id);
    await loadEntries();
  }

  List<FarmDiaryEntry> getEntriesByDate(DateTime date) {
    return _diaryService.getEntriesByDate(date);
  }
}

