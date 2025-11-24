import 'package:flutter/foundation.dart';
import '../models/government_scheme.dart';
import '../services/scheme_service.dart';

class SchemeProvider with ChangeNotifier {
  final SchemeService _schemeService = SchemeService();
  List<GovernmentScheme> _schemes = [];
  bool _loading = false;
  String? _error;

  List<GovernmentScheme> get schemes => _schemes;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchSchemes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _schemes = await _schemeService.getSchemes();
    } catch (e) {
      _error = 'Failed to fetch schemes: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSchemesByCategory(String category) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _schemes = await _schemeService.getSchemesByCategory(category);
    } catch (e) {
      _error = 'Failed to fetch schemes: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> searchSchemes(String query) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _schemes = await _schemeService.searchSchemes(query);
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return await _schemeService.getCategories();
    } catch (e) {
      _error = 'Failed to fetch categories: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<void> fetchActiveSchemes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _schemes = await _schemeService.getActiveSchemes();
    } catch (e) {
      _error = 'Failed to fetch active schemes: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<GovernmentScheme?> getSchemeById(String id) async {
    try {
      return await _schemeService.getSchemeById(id);
    } catch (e) {
      _error = 'Failed to fetch scheme: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}

