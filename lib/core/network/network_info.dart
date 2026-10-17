import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the device has any network interface up.
///
/// Note: "connected to Wi-Fi" does not guarantee internet access, so the app
/// still treats request failures as the source of truth. This only drives
/// the offline banner.
abstract interface class NetworkInfo {
  Future<bool> get isOnline;
  Stream<bool> get onStatusChange;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  const ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async =>
      _hasConnection(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
