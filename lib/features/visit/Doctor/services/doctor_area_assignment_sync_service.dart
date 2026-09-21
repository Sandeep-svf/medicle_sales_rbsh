import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../../../doctor_offline/models/doctor.dart';
import '../repository/pending_area_assignment_repository.dart';

class DoctorAreaAssignmentSyncService {
  DoctorAreaAssignmentSyncService({
    PendingAreaAssignmentRepository? repository,
    AuthManager? authManager,
    http.Client? client,
    String? baseUrl,
  })  : _repository = repository ?? PendingAreaAssignmentRepository(),
        _authManager = authManager ?? AuthManager(),
        _client = client ?? http.Client(),
        _ownsClient = client == null,
        _baseUrl = baseUrl ?? THttpHelper.baseUrl;

  final PendingAreaAssignmentRepository _repository;
  final AuthManager _authManager;
  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;

  void dispose() {
    if (_ownsClient) _client.close();
  }

  /// Uploads each assignment independently. A failed doctor does not prevent
  /// another doctor's assignment from being uploaded.
  Future<Map<String, String>> syncPendingAssignments({
    required String userId,
    required List<Doctor> doctors,
  }) async {
    final byLocalId = <String, Doctor>{};
    final byClientId = <String, Doctor>{};
    final byServerId = <String, Doctor>{};
    final assignedAreas = <String, String>{};

    for (final doctor in doctors) {
      byLocalId[doctor.localId] = doctor;
      if (_hasText(doctor.clientGeneratedId)) {
        byClientId[doctor.clientGeneratedId!] = doctor;
      }
      if (_hasText(doctor.serverId)) byServerId[doctor.serverId!] = doctor;
      if (_hasText(doctor.areaId)) {
        _addDoctorKeys(assignedAreas, doctor, doctor.areaId!);
      }
    }

    final allAssignments = await _repository.getForUser(userId);
    for (final assignment in allAssignments.where((item) => item.uploaded)) {
      _addAssignmentKeys(assignedAreas, assignment.doctorLocalId,
          assignment.serverDoctorId, assignment.areaId);
    }

    final pending = await _repository.getPendingForUser(userId);
    if (pending.isEmpty) return assignedAreas;

    final token = await _authManager.getAuthToken();
    if (!_hasText(token)) {
      for (final assignment in pending) {
        await _repository.markError(
          localId: assignment.localId,
          message: 'Authentication required before area upload.',
        );
      }
      return assignedAreas;
    }

    for (final assignment in pending) {
      final doctor = byLocalId[assignment.doctorLocalId] ??
          byClientId[assignment.doctorLocalId] ??
          (_hasText(assignment.serverDoctorId)
              ? byServerId[assignment.serverDoctorId!]
              : null);
      final serverDoctorId = assignment.serverDoctorId ?? doctor?.serverId;

      if (!_hasText(serverDoctorId)) {
        await _repository.markError(
          localId: assignment.localId,
          message: 'Waiting for doctor synchronization.',
        );
        continue;
      }

      // A doctor downloaded from the server can already have the requested
      // area. In that case no duplicate PUT is needed.
      if (doctor?.areaId == assignment.areaId) {
        await _repository.markUploaded(
          localId: assignment.localId,
          serverDoctorId: serverDoctorId,
        );
        _addAssignmentKeys(assignedAreas, assignment.doctorLocalId,
            serverDoctorId, assignment.areaId);
        continue;
      }

      try {
        final response = await _client
            .put(
              Uri.parse('$_baseUrl/doctors/$serverDoctorId'),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'areaId': assignment.areaId}),
            )
            .timeout(const Duration(seconds: 30));

        final body = _decode(response.body);
        final accepted = response.statusCode >= 200 &&
            response.statusCode < 300 &&
            body['success'] != false &&
            body['status'] != false;
        if (!accepted) {
          await _repository.markError(
            localId: assignment.localId,
            message: 'Area upload failed (${response.statusCode}).',
          );
          continue;
        }

        await _repository.markUploaded(
          localId: assignment.localId,
          serverDoctorId: serverDoctorId,
        );
        _addAssignmentKeys(assignedAreas, assignment.doctorLocalId,
            serverDoctorId, assignment.areaId);
      } catch (error) {
        await _repository.markError(
          localId: assignment.localId,
          message: 'Area upload could not reach the server: $error',
        );
      }
    }

    return assignedAreas;
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
    } catch (_) {
      return const {};
    }
  }

  static void _addDoctorKeys(
    Map<String, String> result,
    Doctor doctor,
    String areaId,
  ) {
    result[doctor.localId] = areaId;
    if (_hasText(doctor.clientGeneratedId)) {
      result[doctor.clientGeneratedId!] = areaId;
    }
    if (_hasText(doctor.serverId)) result[doctor.serverId!] = areaId;
  }

  static void _addAssignmentKeys(
    Map<String, String> result,
    String doctorLocalId,
    String? serverDoctorId,
    String areaId,
  ) {
    result[doctorLocalId] = areaId;
    if (_hasText(serverDoctorId)) result[serverDoctorId!] = areaId;
  }

  static bool _hasText(String? value) => value?.trim().isNotEmpty == true;
}
