import 'package:flutter/foundation.dart';
import '../models/mandi_price.dart';
import '../services/mandi_service.dart';

class MandiProvider with ChangeNotifier {
  final MandiService _mandiService = MandiService();
  List<MandiPrice> _prices = [];
  bool _loading = false;
  String? _error;

  List<MandiPrice> get prices => _prices;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchPrices({String? state, String? district}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _prices = await _mandiService.getMandiPrices(state: state, district: district);
    } catch (e) {
      _error = 'Failed to fetch mandi prices: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> searchCommodity(String query) async {
    _loading = true;
    notifyListeners();

    try {
      _prices = await _mandiService.searchCommodity(query);
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

