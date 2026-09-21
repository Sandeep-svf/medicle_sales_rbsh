import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../visit/Doctor/models/pending_area_assignment_model.dart';
import '../../visit/Doctor/repository/pending_area_assignment_repository.dart';

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/doctor.dart';

class PendingAreaDoctor {
  const PendingAreaDoctor({
    required this.id,
    required this.name,
    this.specialization,
    this.clinicName,
    this.areaId,
    this.headOfficeId,
    this.localDoctorId,
  });

  final String id;
  final String name;
  final String? specialization;
  final String? clinicName;
  final String? areaId;
  final String? headOfficeId;
  final String? localDoctorId;

  factory PendingAreaDoctor.fromDoctor(Doctor doctor) {
    return PendingAreaDoctor(
      id: doctor.serverId ?? doctor.localId,
      name: doctor.displayName,
      specialization: doctor.specialization,
      clinicName: doctor.clinicName,
      areaId: doctor.areaId,
      headOfficeId: doctor.headOfficeId,
      localDoctorId: doctor.localId,
    );
  }
}

class DoctorAreaOption {
  const DoctorAreaOption({required this.id, required this.name});

  final String id;
  final String name;
}

class DoctorAreaAssignmentService {
  DoctorAreaAssignmentService(
      {AuthManager? authManager,
      http.Client? client,
      PendingAreaAssignmentRepository? assignmentRepository})
      : _authManager = authManager ?? AuthManager(),
        _assignmentRepository =
            assignmentRepository ?? PendingAreaAssignmentRepository(),
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  final AuthManager _authManager;
  final PendingAreaAssignmentRepository _assignmentRepository;
  final http.Client _client;
  final bool _ownsClient;

  Future<List<PendingAreaDoctor>> fetchDoctorsWithoutArea() async {
    final response = await _get('/doctors/my-doctors');
    _ensureSuccess(response);
    final body = _decode(response);
    final rows = (body['data'] as List? ?? const <dynamic>[])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .where((row) =>
            row['is_assigned_to_area'] != true &&
            row['areaId'] == null &&
            row['area'] == null)
        .map((row) => PendingAreaDoctor(
              id: (row['_id'] ?? row['id']).toString(),
              name: (row['name'] ?? 'Unnamed doctor').toString(),
              specialization: row['specialization']?.toString(),
              clinicName: row['clinic_name']?.toString(),
              headOfficeId: _nestedId(row['headOfficeId'] ??
                  row['head_office_id'] ??
                  row['headOffice']),
            ))
        .where((doctor) => doctor.id.isNotEmpty && doctor.id != 'null')
        .toList();
    return rows;
  }

  Future<List<DoctorAreaOption>> fetchAreas() async {
    final response = await _get('/areas');
    _ensureSuccess(response);
    final body = _decode(response);
    return (body['data'] as List? ?? const <dynamic>[])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .map((row) => DoctorAreaOption(
              id: (row['id'] ?? row['_id']).toString(),
              name: (row['name'] ?? '').toString(),
            ))
        .where((area) =>
            area.id.isNotEmpty && area.id != 'null' && area.name.isNotEmpty)
        .toList();
  }

  /// Looks up the same post-office data used by the online add-doctor flow.
  /// This endpoint is public, so it intentionally does not use the app API
  /// base URL or authentication token.
  Future<List<Map<String, dynamic>>> fetchPostOffices(String pincode) async {
    final response = await _client
        .get(
          Uri.parse('https://api.postalpincode.in/pincode/${pincode.trim()}'),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw StateError('Unable to fetch pincode details.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
      throw const FormatException('Invalid pincode response.');
    }
    final result = Map<String, dynamic>.from(decoded.first as Map);
    final offices = result['PostOffice'];
    if (result['Status'] != 'Success' || offices is! List || offices.isEmpty) {
      throw StateError(
          result['Message']?.toString() ?? 'No post office found.');
    }
    return offices
        .whereType<Map>()
        .map((office) => Map<String, dynamic>.from(office))
        .toList();
  }

  Future<DoctorAreaOption> createArea({
    required String name,
    required String pincode,
    required String postOffice,
    required String headOfficeId,
  }) async {
    if (headOfficeId.trim().isEmpty) {
      throw StateError(
          'This doctor has no head office. Select an existing area instead.');
    }
    final token = await _authManager.getAuthToken();
    final response = await _client
        .post(
          Uri.parse('${THttpHelper.baseUrl}/areas'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'pincode': pincode,
            'post_office': postOffice,
            'head_office_id': headOfficeId,
          }),
        )
        .timeout(const Duration(seconds: 20));
    _ensureSuccess(response);
    final body = _decode(response);
    final row = body['data'];
    if (row is! Map) throw const FormatException('Area response is invalid.');
    final id = (row['id'] ?? row['_id']).toString();
    final areaName = (row['name'] ?? name).toString();
    if (id.isEmpty || id == 'null') {
      throw const FormatException('Area response has no id.');
    }
    return DoctorAreaOption(id: id, name: areaName);
  }

  Future<String?> assignArea(
      {required String doctorId,
      required String areaId,
      String? localDoctorId,
      String? areaName}) async {
    final userId = await _authManager.getUserId();
    final token = await _authManager.getAuthToken();
    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      throw StateError('Sign in again before assigning an area.');
    }
    final response = await _client
        .put(
          Uri.parse('${THttpHelper.baseUrl}/doctors/$doctorId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'areaId': areaId}),
        )
        .timeout(const Duration(seconds: 20));
    _ensureSuccess(response);
    final body = _decode(response);
    // The successful PUT is authoritative even if the delta endpoint still
    // returns an older doctor. Persist it and notify the live offline list.
    await _assignmentRepository.upsert(PendingAreaAssignmentModel(
      localId: const Uuid().v4(),
      doctorLocalId: localDoctorId ?? doctorId,
      serverDoctorId: doctorId,
      userId: userId,
      areaId: areaId,
      areaName: areaName ?? '',
      createdAt: DateTime.now().toUtc(),
      uploaded: true,
    ));
    return body['message']?.toString();
  }

  Future<http.Response> _get(String endpoint) async {
    final token = await _authManager.getAuthToken();
    return _client.get(
      Uri.parse('${THttpHelper.baseUrl}$endpoint'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 20));
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Invalid server response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Request failed with status ${response.statusCode}.');
    }
    final body = _decode(response);
    if (body['success'] == false) {
      throw StateError(body['message']?.toString() ?? 'Request failed.');
    }
  }

  Future<void> close() async {
    if (_ownsClient) _client.close();
  }

  static String? _nestedId(Object? value) {
    if (value is Map) {
      final id = value['id'] ?? value['_id'];
      return id?.toString();
    }
    final text = value?.toString();
    return text == null || text.isEmpty || text == 'null' ? null : text;
  }
}
