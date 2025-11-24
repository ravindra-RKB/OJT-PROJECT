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

  Future<List<MandiPrice>> getPricesByCommodity(
    String commodity, {
    String? state,
    String? district,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prices = await _mandiService.getPricesByCommodity(
        commodity,
        state: state,
        district: district,
      );
      _loading = false;
      notifyListeners();
      return prices;
    } catch (e) {
      _error = 'Failed to fetch prices: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, double>> getPriceTrends(
    String commodity, {
    String? state,
    String? district,
    int days = 30,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final trends = await _mandiService.getPriceTrends(
        commodity,
        state: state,
        district: district,
        days: days,
      );
      _loading = false;
      notifyListeners();
      return trends;
    } catch (e) {
      _error = 'Failed to fetch price trends: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return {};
    }
  }

  Future<List<String>> getAllStates() async {
    try {
      return await _mandiService.getAllStates();
    } catch (e) {
      _error = 'Failed to fetch states: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<List<String>> getDistrictsByState(String state) async {
    try {
      return await _mandiService.getDistrictsByState(state);
    } catch (e) {
      _error = 'Failed to fetch districts: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<List<MandiPrice>> getPricesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? commodity,
    String? state,
    String? district,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prices = await _mandiService.getPricesByDateRange(
        startDate: startDate,
        endDate: endDate,
        commodity: commodity,
        state: state,
        district: district,
      );
      _loading = false;
      notifyListeners();
      return prices;
    } catch (e) {
      _error = 'Failed to fetch prices: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return [];
    }
  }
}

