import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// A small singleton service that exposes current internet availability
/// and a broadcast stream for listeners.
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _controller.stream;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  /// Initialize the service and start listening for connectivity changes.
  Future<void> init() async {
    // Seed initial value
    try {
      _hasConnection = await _internetChecker.hasConnection;
      _controller.add(_hasConnection);
    } catch (_) {
      _hasConnection = false;
      _controller.add(false);
    }

    _connectivity.onConnectivityChanged.listen((_) async {
      try {
        final status = await _internetChecker.hasConnection;
        _hasConnection = status;
        _controller.add(status);
      } catch (_) {
        _hasConnection = false;
        _controller.add(false);
      }
    });
  }

  /// Quick actively-checked status
  Future<bool> checkConnection() async {
    try {
      final has = await _internetChecker.hasConnection;
      _hasConnection = has;
      _controller.add(has);
      return has;
    } catch (_) {
      _hasConnection = false;
      _controller.add(false);
      return false;
    }
  }

  void dispose() {
    _controller.close();
  }
}
