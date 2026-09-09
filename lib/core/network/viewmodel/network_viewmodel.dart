import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../service/network_info.dart';

class NetworkViewModel extends ChangeNotifier {
  final NetworkInfo _networkInfo;

  NetworkViewModel({
    NetworkInfo? networkInfo,
  }) : _networkInfo = networkInfo ?? NetworkInfo();

  bool _isConnected = true;

  bool get isConnected => _isConnected;

  StreamSubscription<List<ConnectivityResult>>?
      _subscription;

  Future<void> initialize() async {
    _isConnected = await _networkInfo.isConnected;

    notifyListeners();

    _subscription =
        _networkInfo.onConnectivityChanged.listen(
      (results) {
        final connected = !results.contains(
          ConnectivityResult.none,
        );

        if (_isConnected != connected) {
          _isConnected = connected;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}