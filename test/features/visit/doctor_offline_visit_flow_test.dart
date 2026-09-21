import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicle_sales_rbsh/features/authentication/models/UserModel.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/pending_doctor_location_request.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_visit_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_schedule_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/visitSalesData.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_schedule_repository.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_visit_repository.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/pending_visit_sync_service.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/visit_confirmation_service.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

void main() {
  group('login meter range', () {
    test('preserves the server meter_range in both response shapes', () {
      final model = UserModel.fromJson({
        'token': 'token',
        'meter_range': 200,
        'user': {
          'id': 'user-1',
          'name': 'User',
          'email': 'user@example.test',
          'role': 'User',
          'emailVerified': true,
          'meter_range': 350,
          'headOffices': <Object>[],
        },
      });

      expect(model.meterRange, 200);
      expect(model.user!.meterRange, 350);
      expect(model.toJson()['meter_range'], 200);
      expect(model.user!.toJson()['meter_range'], 350);
    });
  });

  group('VisitConfirmationService', () {
    late FakePendingVisitRepository repository;
    late FakeAuthManager auth;

    setUp(() {
      repository = FakePendingVisitRepository();
      auth = FakeAuthManager(meterRange: 200);
    });

    test('rejects a visit outside the configured range and reports km',
        () async {
      final service = VisitConfirmationService(
        repository: repository,
        authManager: auth,
      );

      final response = await service.confirmVisit(
        visitId: 'visit-1',
        doctorLatitude: 28.6139,
        doctorLongitude: 77.2090,
        position: testPosition(28.6200, 77.2090),
        productIds: const [],
        forceOffline: true,
      );

      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['message'], contains('km'));
      expect(repository.visits, isEmpty);
    });

    test('stores a valid offline confirmation before returning success',
        () async {
      final service = VisitConfirmationService(
        repository: repository,
        authManager: auth,
      );

      final response = await service.confirmVisit(
        visitId: 'visit-2',
        doctorLatitude: 28.6139,
        doctorLongitude: 77.2090,
        position: testPosition(28.6139, 77.2090),
        productIds: const ['product-1'],
        notes: 'Offline note',
        forceOffline: true,
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(response.statusCode, 200);
      expect(body['queued'], true);
      expect(repository.visits.single.visitId, 'visit-2');
      expect(repository.visits.single.productIds, ['product-1']);
      expect(repository.visits.single.notes, 'Offline note');
    });

    test('triggers background sync only after the local insert', () async {
      var syncTriggered = false;
      final service = VisitConfirmationService(
        repository: repository,
        authManager: auth,
        syncTrigger: () async {
          expect(repository.visits, isNotEmpty);
          syncTriggered = true;
        },
      );

      await service.confirmVisit(
        visitId: 'visit-3',
        doctorLatitude: 28.6139,
        doctorLongitude: 77.2090,
        position: testPosition(28.6139, 77.2090),
        productIds: const [],
      );
      await Future<void>.delayed(Duration.zero);

      expect(syncTriggered, isTrue);
    });
  });

  group('PendingVisitSyncService', () {
    test('sends pending visits in chunks of ten and deletes synced rows',
        () async {
      final repository = FakePendingVisitRepository()
        ..visits.addAll(List.generate(25, (index) => pendingVisit(index)));
      final batchSizes = <int>[];
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.headers['authorization'], 'Bearer test-token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        batchSizes.add((body['visits'] as List).length);
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final service = PendingVisitSyncService(
        repository: repository,
        authManager: FakeAuthManager(token: 'test-token'),
        client: client,
        baseUrl: 'https://example.test/api',
      );
      await service.syncPendingVisits();

      expect(batchSizes, [10, 10, 5]);
      expect(repository.visits, isEmpty);
      service.dispose();
    });

    test('retains the whole batch when the network fails', () async {
      final repository = FakePendingVisitRepository()
        ..visits.addAll(List.generate(3, pendingVisit));
      final service = PendingVisitSyncService(
        repository: repository,
        authManager: FakeAuthManager(token: 'test-token'),
        client: MockClient((_) async => throw const SocketException('offline')),
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(repository.visits, hasLength(3));
      service.dispose();
    });

    test(
        'resolves a pending confirmation from an uploaded schedule before sync',
        () async {
      final repository = FakePendingVisitRepository()
        ..visits.add(
          PendingVisitModel(
            visitId: 'local-schedule-1',
            localScheduleId: 'local-schedule-1',
            userLatitude: 28.6139,
            userLongitude: 77.2090,
            notes: '',
            productIds: const [],
            createdAt: DateTime.utc(2026, 9, 19),
          ),
        );
      final scheduleRepository = FakePendingScheduleRepository(
        PendingScheduleModel(
          localId: 'local-schedule-1',
          doctorLocalId: 'doctor-1',
          serverDoctorId: 'server-doctor-1',
          userId: 'user-1',
          date: '2026-09-19',
          notes: '',
          remark: '',
          doctorName: 'Dr. Offline',
          doctorLatitude: 28.6139,
          doctorLongitude: 77.2090,
          createdAt: DateTime.utc(2026, 9, 19),
          serverVisitId: 'server-visit-1',
        ),
      );
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final visits = body['visits'] as List<dynamic>;
        expect(visits.single['id'], 'server-visit-1');
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final service = PendingVisitSyncService(
        repository: repository,
        scheduleRepository: scheduleRepository,
        authManager: FakeAuthManager(token: 'test-token'),
        client: client,
        baseUrl: 'https://example.test/api',
      );

      await service.syncPendingVisits();

      expect(repository.visits, isEmpty);
      expect(scheduleRepository.deleted, contains('local-schedule-1'));
      service.dispose();
    });
  });

  test('offline location request round-trips all durable fields', () {
    final original = PendingDoctorLocationRequest(
      requestKey: 'account:doctor',
      accountId: 'account',
      localDoctorId: 'doctor',
      requestedDoctorId: 'server-doctor',
      latitude: 28.6139,
      longitude: 77.2090,
      createdAt: DateTime.parse('2026-09-19T10:00:00Z'),
    );

    final restored = PendingDoctorLocationRequest.fromMap(original.toMap());

    expect(restored.requestKey, original.requestKey);
    expect(restored.accountId, original.accountId);
    expect(restored.localDoctorId, original.localDoctorId);
    expect(restored.requestedDoctorId, original.requestedDoctorId);
    expect(restored.latitude, original.latitude);
    expect(restored.longitude, original.longitude);
    expect(restored.createdAt, original.createdAt);
  });

  test('visit doctor keeps an area id from the server area object', () {
    final visit = VisitSalesLogModel.fromJson({
      'id': 'visit-1',
      'doctor_id': 'doctor-1',
      'user_id': 'user-1',
      'doctor': {
        'id': 'doctor-1',
        'name': 'Dr. Offline',
        'area': {'id': 'area-1', 'name': 'South Delhi'},
      },
    });

    expect(visit.doctor?.areaId, 'area-1');
  });
}

Position testPosition(double latitude, double longitude) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.utc(2026, 9, 19),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}

PendingVisitModel pendingVisit(int index) {
  return PendingVisitModel(
    visitId: 'visit-$index',
    userLatitude: 28.6139,
    userLongitude: 77.2090,
    notes: '',
    productIds: const [],
    createdAt: DateTime.utc(2026, 9, 19),
  );
}

class FakeAuthManager extends AuthManager {
  FakeAuthManager({this.token, this.meterRange});

  final String? token;
  final double? meterRange;

  @override
  Future<String?> getAuthToken() async => token;

  @override
  Future<double?> getMeterRange() async => meterRange;
}

class FakePendingVisitRepository extends PendingVisitRepository {
  final List<PendingVisitModel> visits = [];

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

class FakePendingScheduleRepository extends PendingScheduleRepository {
  FakePendingScheduleRepository(this.schedule);

  final PendingScheduleModel schedule;
  final List<String> deleted = <String>[];

  @override
  Future<PendingScheduleModel?> findByLocalId(String localId) async {
    return localId == schedule.localId ? schedule : null;
  }

  @override
  Future<void> delete(String localId) async {
    deleted.add(localId);
  }
}
