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
}

