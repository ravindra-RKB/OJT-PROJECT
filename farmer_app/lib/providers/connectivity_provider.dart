import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _status = [ConnectivityResult.none];

  List<ConnectivityResult> get status => _status;
  bool get isConnected => !_status.contains(ConnectivityResult.none);

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    _status = await _connectivity.checkConnectivity();
    notifyListeners();

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _status = result;
      notifyListeners();
    });
  }

  Future<void> checkConnectivity() async {
    _status = await _connectivity.checkConnectivity();
    notifyListeners();
  }
}
