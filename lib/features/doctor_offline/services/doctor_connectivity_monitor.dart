import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class DoctorConnectivityMonitor {
  Future<bool> isNetworkAvailable();

  Stream<bool> get availabilityChanges;
}

class ConnectivityPlusDoctorConnectivityMonitor
    implements DoctorConnectivityMonitor {
  ConnectivityPlusDoctorConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isNetworkAvailable() async {
    return _hasNetwork(await _connectivity.checkConnectivity());
  }

  @override
  Stream<bool> get availabilityChanges {
    return _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
