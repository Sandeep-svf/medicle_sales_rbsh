import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../../../utils/local_storage/auth_manager.dart';
import '../../../utils/sqlite_helper/GenericDatabaseHelper.dart';
import '../models/DoctorOfflineModel.dart';

class DoctorService {
  final _dbHelper = GenericDatabaseHelper<DoctorOfflineModel>();

  // API endpoint only for bulk sync
  final String bulkAddUrl = "${THttpHelper.baseUrl}/doctors/bulk";

  // Centralized debug logger
  void _debug(String message) {
    // ignore: avoid_print
    print('[DoctorService] $message');
  }

  /// Save doctor data locally when offline
  Future<void> saveOfflineDoctor(DoctorOfflineModel doctor) async {
    _debug('Saving doctor offline: ${doctor.name}');
    await _dbHelper.insert(doctor);
    _debug('Doctor saved locally → ${doctor.toJson()}');
  }

  /// Try syncing offline doctors when connection is available
  Future<void> syncOfflineDoctors() async {
    _debug('Checking connectivity before syncing...');

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _debug('No internet connection. Sync skipped.');
      return;
    }

    final offlineDoctors = await _dbHelper.getAll('doctors', DoctorOfflineModel.fromJson);
    _debug('Found ${offlineDoctors.length} offline doctors to sync.');

    if (offlineDoctors.isEmpty) {
      _debug('No offline data found. Nothing to sync.');
      return;
    }

    try {
      _debug('Starting bulk sync to $bulkAddUrl');

      final token = await AuthManager().getAuthToken();


      final payload = jsonEncode({
        "doctors": offlineDoctors.map((e) => e.toJson()).toList(),
      });

      final response = await http.post(
        Uri.parse(bulkAddUrl),
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer $token",},
        body: payload,
      );

      _debug('Bulk sync response: ${response.statusCode}');
      _debug('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _debug('Bulk sync successful. Clearing local database...');
        await _dbHelper.deleteAll('doctors');
      } else {
        _debug('Bulk sync failed. Local data retained for retry.');
      }
    } catch (e) {
      _debug('Error during bulk sync: $e');
    }
  }
}
