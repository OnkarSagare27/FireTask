import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _initialize();
  }

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker.createInstance();

  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionChange => _connectionChangeController.stream;

  bool _hasConnection = false;
  bool get hasConnection => _hasConnection;

  void _initialize() async {
    _hasConnection = await _internetChecker.hasConnection;
    _connectionChangeController.add(_hasConnection);

    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    if (result == ConnectivityResult.none) {
      _hasConnection = false;
      _connectionChangeController.add(_hasConnection);
      return;
    }

    final hasInternet = await _internetChecker.hasConnection;

    if (_hasConnection != hasInternet) {
      _hasConnection = hasInternet;
      _connectionChangeController.add(_hasConnection);
    }
  }

  void dispose() {
    _connectionChangeController.close();
  }
}
