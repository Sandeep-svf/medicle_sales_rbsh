import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/services/doctor_area_assignment_service.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_area_assignment_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_area_assignment_repository.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

class _Auth extends AuthManager {
  @override
  Future<String?> getUserId() async => 'user-1';
  @override
  Future<String?> getAuthToken() async => 'token';
}

class _Assignments extends PendingAreaAssignmentRepository {
  PendingAreaAssignmentModel? saved;
  @override
  Future<void> upsert(PendingAreaAssignmentModel assignment) async =>
      saved = assignment;
}

void main() {
  test(
      'direct area assignment stores confirmed area and both doctor identities',
      () async {
    final repository = _Assignments();
    final service = DoctorAreaAssignmentService(
        authManager: _Auth(),
        assignmentRepository: repository,
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect(request.url.path, endsWith('/doctors/server-doctor'));
          expect(request.headers['Authorization'], 'Bearer token');
          expect(jsonDecode(request.body), {'areaId': 'area-1'});
          return http.Response('{"success":true,"message":"Updated"}', 200);
        }));
    await service.assignArea(
        doctorId: 'server-doctor',
        localDoctorId: 'local-doctor',
        areaId: 'area-1',
        areaName: 'Central');
    expect(repository.saved!.uploaded, isTrue);
    expect(repository.saved!.doctorLocalId, 'local-doctor');
    expect(repository.saved!.serverDoctorId, 'server-doctor');
    expect(repository.saved!.areaName, 'Central');
    expect(repository.saved!.userId, 'user-1');
  });

  test(
      'failed assignment does not hide the assign-area action with false local success',
      () async {
    final repository = _Assignments();
    final service = DoctorAreaAssignmentService(
        authManager: _Auth(),
        assignmentRepository: repository,
        client:
            MockClient((_) async => http.Response('{"success":false}', 200)));
    await expectLater(
        service.assignArea(doctorId: 'doctor-1', areaId: 'area-1'),
        throwsStateError);
    expect(repository.saved, isNull);
  });
}
