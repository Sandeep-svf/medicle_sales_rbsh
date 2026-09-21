import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_schedule_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_visit_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_schedule_repository.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_visit_repository.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/doctor_schedule_service.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/pending_visit_sync_service.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/visit_confirmation_service.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

void main() {
  group('offline schedule outbox contract', () {
    test('round-trips cached area and server identity fields', () {
      final schedule = _schedule(
        localId: 'schedule-local-1',
        areaId: 'area-1',
        areaName: 'South Delhi',
        serverDoctorId: 'doctor-server-1',
        serverVisitId: 'visit-server-1',
      );

      final restored = PendingScheduleModel.fromMap(schedule.toMap());

      expect(restored.localId, 'schedule-local-1');
      expect(restored.areaId, 'area-1');
      expect(restored.areaName, 'South Delhi');
      expect(restored.serverDoctorId, 'doctor-server-1');
      expect(restored.serverVisitId, 'visit-server-1');
      expect(restored.isUploaded, isTrue);
    });

    test('schedule service persists the selected cached area with the draft',
        () async {
      final repository = _MemoryScheduleRepository();
      var syncTriggered = false;
      final service = DoctorScheduleService(repository: repository);

      await service.queueSchedule(
        doctorLocalId: 'doctor-local-1',
        serverDoctorId: null,
        userId: 'user-1',
        date: '21-09-2026',
        notes: 'Follow up',
        doctorName: 'Dr. Offline',
        areaId: 'area-1',
        areaName: 'South Delhi',
        syncTrigger: () async => syncTriggered = true,
      );

      expect(repository.schedules, hasLength(1));
      expect(repository.schedules.single.areaId, 'area-1');
      expect(repository.schedules.single.areaName, 'South Delhi');
      expect(syncTriggered, isTrue);
    });
  });

  group('offline visit confirmation contract', () {
    test('keeps a local schedule ID until schedule sync returns a server ID',
        () async {
      final repository = _MemoryVisitRepository();
      final service = VisitConfirmationService(
        repository: repository,
        authManager: _TestAuthManager(meterRange: 200),
        syncTrigger: () async {},
      );

      final response = await service.confirmVisit(
        visitId: 'schedule-local-1',
        localScheduleId: 'schedule-local-1',
        doctorLatitude: 28.6139,
        doctorLongitude: 77.2090,
        position: _position(28.6139, 77.2090),
        productIds: const ['product-1'],
        forceOffline: true,
      );

      expect(response.statusCode, 200);
      expect(repository.visits.single.localScheduleId, 'schedule-local-1');
      expect(repository.visits.single.serverVisitId, isNull);
      expect(repository.visits.single.uploadVisitId, 'schedule-local-1');
    });
  });

  group('bulk confirmation sync contract', () {
    test('uploads only confirmations whose schedule identity is resolved',
        () async {
      final repository = _MemoryVisitRepository()
        ..visits.addAll([
          _visit(
            visitId: 'schedule-local-1',
            localScheduleId: 'schedule-local-1',
          ),
          _visit(visitId: 'visit-server-1'),
        ]);
      final requestIds = <String>[];
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requestIds.addAll(
          (body['visits'] as List)
              .map((item) => (item as Map)['id'].toString()),
        );
        return http.Response(jsonEncode({'success': true}), 200);
      });
      final service = PendingVisitSyncService(
        repository: repository,
        scheduleRepository: _MemoryScheduleRepository(),
        authManager: _TestAuthManager(token: 'token'),
        client: client,
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(requestIds, ['visit-server-1']);
      expect(repository.visits.single.visitId, 'schedule-local-1');
      service.dispose();
    });

    test('deletes successful items and retains indexed server errors',
        () async {
      final repository = _MemoryVisitRepository()
        ..visits.addAll(
            List.generate(3, (index) => _visit(visitId: 'visit-$index')));
      final client = MockClient((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'id': 'server-visit-0'},
                {'id': 'server-visit-2'},
              ],
              'errors': [
                {'index': 1, 'error': 'Visit is already confirmed.'},
              ],
            }),
            201,
          ));
      final service = PendingVisitSyncService(
        repository: repository,
        authManager: _TestAuthManager(token: 'token'),
        client: client,
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(repository.visits.map((visit) => visit.visitId), ['visit-1']);
      service.dispose();
    });

    test('retains every item when a 2xx response reports rejection', () async {
      final repository = _MemoryVisitRepository()
        ..visits.addAll([
          _visit(visitId: 'visit-1'),
          _visit(visitId: 'visit-2'),
        ]);
      final service = PendingVisitSyncService(
        repository: repository,
        authManager: _TestAuthManager(token: 'token'),
        client: MockClient((_) async => http.Response(
              jsonEncode({'success': false, 'message': 'Rejected'}),
              201,
            )),
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(repository.visits.map((visit) => visit.visitId),
          ['visit-1', 'visit-2']);
      service.dispose();
    });

    test('accepts the all-success 201 response contract', () async {
      final repository = _MemoryVisitRepository()
        ..visits.add(_visit(visitId: 'visit-1'));
      final service = PendingVisitSyncService(
        repository: repository,
        authManager: _TestAuthManager(token: 'token'),
        client: MockClient((_) async => http.Response(
              jsonEncode({
                'success': true,
                'summary': {
                  'total': 1,
                  'confirmedCount': 1,
                  'errorCount': 0,
                },
                'data': [],
                'errors': [],
              }),
              201,
            )),
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(repository.visits, isEmpty);
      service.dispose();
    });

    test('retains pending visits when authentication is unavailable', () async {
      final repository = _MemoryVisitRepository()
        ..visits.add(_visit(visitId: 'visit-1'));
      var requestCount = 0;
      final service = PendingVisitSyncService(
        repository: repository,
        authManager: _TestAuthManager(),
        client: MockClient((_) async {
          requestCount++;
          return http.Response('{}', 200);
        }),
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(requestCount, 0);
      expect(repository.visits, hasLength(1));
      service.dispose();
    });
  });
}

PendingScheduleModel _schedule({
  required String localId,
  String? areaId,
  String? areaName,
  String? serverDoctorId,
  String? serverVisitId,
}) {
  return PendingScheduleModel(
    localId: localId,
    doctorLocalId: 'doctor-local-1',
    serverDoctorId: serverDoctorId,
    userId: 'user-1',
    date: '2026-09-21',
    notes: 'Follow up',
    remark: '',
    doctorName: 'Dr. Offline',
    doctorLatitude: 28.6139,
    doctorLongitude: 77.2090,
    createdAt: DateTime.utc(2026, 9, 21),
    areaId: areaId,
    areaName: areaName,
    serverVisitId: serverVisitId,
  );
}

PendingVisitModel _visit({
  required String visitId,
  String? localScheduleId,
  String? serverVisitId,
}) {
  return PendingVisitModel(
    visitId: visitId,
    localScheduleId: localScheduleId,
    serverVisitId: serverVisitId,
    userLatitude: 28.6139,
    userLongitude: 77.2090,
    notes: 'Offline note',
    productIds: const ['product-1'],
    createdAt: DateTime.utc(2026, 9, 21),
  );
}

Position _position(double latitude, double longitude) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.utc(2026, 9, 21),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _TestAuthManager extends AuthManager {
  _TestAuthManager({this.token, this.meterRange});

  final String? token;
  final double? meterRange;

  @override
  Future<String?> getAuthToken() async => token;

  @override
  Future<double?> getMeterRange() async => meterRange;
}

class _MemoryVisitRepository extends PendingVisitRepository {
  final List<PendingVisitModel> visits = <PendingVisitModel>[];

  @override
  Future<void> insertVisit(PendingVisitModel visit) async {
    visits.removeWhere((item) => item.visitId == visit.visitId);
    visits.add(visit);
  }

  @override
  Future<List<PendingVisitModel>> getPendingVisits() async =>
      List<PendingVisitModel>.of(visits);

  @override
  Future<void> deleteVisit(String visitId) async {
    visits.removeWhere((item) => item.visitId == visitId);
  }

  @override
  Future<void> resolveServerVisitId({
    required String localScheduleId,
    required String serverVisitId,
  }) async {
    final index =
        visits.indexWhere((item) => item.localScheduleId == localScheduleId);
    if (index < 0) return;
    visits[index] = visits[index].copyWith(
      visitId: serverVisitId,
      serverVisitId: serverVisitId,
    );
  }
}

class _MemoryScheduleRepository extends PendingScheduleRepository {
  final List<PendingScheduleModel> schedules = <PendingScheduleModel>[];

  @override
  Future<void> insert(PendingScheduleModel schedule) async {
    schedules.add(schedule);
  }

  @override
  Future<PendingScheduleModel?> findByLocalId(String localId) async => null;
}
