import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/controllers/doctor_offline_controller.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_sync_models.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/repositories/doctor_repository.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/services/doctor_connectivity_monitor.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/sync/doctor_sync_coordinator.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/ui/doctor_offline_screen.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/ui/widgets/doctor_list_card.dart';
import 'package:medicle_sales_rbsh/utils/theam/theme.dart';

import 'doctor_test_fixtures.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_area_assignment_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_area_assignment_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'saved area immediately updates doctor list and filters without download',
      (tester) async {
    final areas = _AreaRepository();
    addTearDown(areas.events.close);
    final harness = await _UiHarness.create(
        areas: areas,
        doctors: [fixtureDoctor().copyWith(areaId: null, areaName: null)]);
    addTearDown(harness.dispose);
    await tester.pumpWidget(_testApp(harness.controller));
    await tester.pumpAndSettle();
    expect(find.text('Assign Area'), findsOneWidget);
    final original = harness.controller.doctorsForSync.single;
    harness.controller.selectDoctor(original.localId);
    areas.assignments = [_area(original.localId, original.serverId)];
    areas.events.add('account-1');
    await tester.pumpAndSettle();
    expect(find.text('Assign Area'), findsNothing);
    expect(harness.controller.allDoctors.single.areaId, 'new-area');
    expect(harness.controller.selectedDoctor!.areaName, 'Updated area');
    expect(harness.controller.areaOptions.map((a) => a.value),
        contains('new-area'));
    harness.controller.setArea('new-area');
    expect(harness.controller.visibleDoctors, hasLength(1));
    // Local UI data must not make the uploader skip the area PUT.
    expect(harness.controller.doctorsForSync.single.areaId, original.areaId);
    expect(
        harness.controller.doctorsForSync.single.areaName, original.areaName);
    expect(tester.takeException(), isNull);
  });

  test(
      'stored uploaded area survives controller recreation and respects account scope',
      () async {
    final doctor = fixtureDoctor();
    final areas = _AreaRepository()
      ..assignments = [
        _area(doctor.localId, doctor.serverId, uploaded: true),
        PendingAreaAssignmentModel(
            localId: 'other',
            doctorLocalId: doctor.localId,
            userId: 'another-account',
            areaId: 'wrong-area',
            areaName: 'Wrong account',
            createdAt: DateTime.utc(2026, 10)),
      ];
    addTearDown(areas.events.close);
    final first = await _UiHarness.create(areas: areas);
    expect(first.controller.allDoctors.single.areaName, 'Updated area');
    await first.dispose();
    final reopened = await _UiHarness.create(areas: areas);
    addTearDown(reopened.dispose);
    expect(reopened.controller.allDoctors.single.areaId, 'new-area');
  });

  test('newer server area wins over an older completed assignment', () async {
    final doctor = fixtureDoctor().copyWith(
        areaId: 'server-new',
        areaName: 'Newer server area',
        updatedAt: DateTime.utc(2026, 10));
    final areas = _AreaRepository()
      ..assignments = [_area(doctor.localId, doctor.serverId, uploaded: true)];
    addTearDown(areas.events.close);
    final harness = await _UiHarness.create(areas: areas, doctors: [doctor]);
    addTearDown(harness.dispose);
    expect(harness.controller.allDoctors.single.areaId, 'server-new');
  });

  testWidgets('phone portrait opens a separate read-only detail screen', (
    tester,
  ) async {
    final harness = await _UiHarness.create();
    addTearDown(harness.dispose);
    await _setSurface(tester, const Size(430, 900));

    await tester.pumpWidget(_testApp(harness.controller));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DoctorListCard), findsOneWidget);

    await tester.tap(find.byType(DoctorListCard));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Offline'), findsWidgets);
    expect(find.text('Contact Information'), findsOneWidget);
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('No Geo Location Image available'), findsOneWidget);
    expect(find.text('Capture / Upload'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Samsung tablet landscape uses profile tabs', (
    tester,
  ) async {
    final harness = await _UiHarness.create();
    addTearDown(harness.dispose);
    await _setSurface(tester, const Size(1280, 800));

    await tester.pumpWidget(_testApp(harness.controller));
    await tester.pumpAndSettle();
    expect(find.text('View Profile'), findsOneWidget);

    await tester.tap(find.byType(DoctorListCard));
    await tester.pumpAndSettle();

    expect(find.text('Contact Information'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Location & Media'), findsOneWidget);
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    expect(find.text('Practice Details'), findsOneWidget);
    await tester.tap(find.text('Location & Media'));
    await tester.pumpAndSettle();
    expect(find.text('Geo Location Image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet portrait supports increased system text scale', (
    tester,
  ) async {
    final harness = await _UiHarness.create();
    addTearDown(harness.dispose);
    await _setSurface(tester, const Size(800, 1280));

    await tester.pumpWidget(
      _testApp(harness.controller, textScale: 1.8),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline Doctors'), findsOneWidget);
    expect(find.text('Dr. Offline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact landscape remains usable with larger text', (
    tester,
  ) async {
    final harness = await _UiHarness.create();
    addTearDown(harness.dispose);
    await _setSurface(tester, const Size(844, 390));

    await tester.pumpWidget(
      _testApp(harness.controller, textScale: 1.4),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline Doctors'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _testApp(
  DoctorOfflineController controller, {
  double textScale = 1,
}) {
  return MaterialApp(
    theme: SAppTheme.lightTheme,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      );
    },
    home: DoctorOfflineScreen(controller: controller),
  );
}

class _UiHarness {
  const _UiHarness({
    required this.repository,
    required this.coordinator,
    required this.controller,
  });

  final _StaticRepository repository;
  final DoctorSyncCoordinator coordinator;
  final DoctorOfflineController controller;

  static Future<_UiHarness> create(
      {_AreaRepository? areas, List<Doctor>? doctors}) async {
    final repository = _StaticRepository(doctors ??
        [
          fixtureDoctor().copyWith(geoImageUrl: null),
        ]);
    final coordinator = DoctorSyncCoordinator(
      repository: repository,
      scopeGuard: () async => true,
      maxRequestAttempts: 1,
      delay: (_) async {},
      log: (_) {},
    );
    final controller = DoctorOfflineController(
      accountId: areas == null ? null : 'account-1',
      areaAssignmentRepository: areas,
      repository: repository,
      syncCoordinator: coordinator,
      connectivityMonitor: const _OnlineConnectivityMonitor(),
    );
    await controller.initialize();
    return _UiHarness(
      repository: repository,
      coordinator: coordinator,
      controller: controller,
    );
  }

  Future<void> dispose() async {
    await controller.shutdown();
    await coordinator.dispose();
    await repository.close();
  }
}

PendingAreaAssignmentModel _area(String localId, String? serverId,
        {bool uploaded = false}) =>
    PendingAreaAssignmentModel(
      localId: 'area-assignment',
      doctorLocalId: localId,
      serverDoctorId: serverId,
      userId: 'account-1',
      areaId: 'new-area',
      areaName: 'Updated area',
      createdAt: DateTime.utc(2026, 9, 21),
      uploaded: uploaded,
    );

class _AreaRepository extends PendingAreaAssignmentRepository {
  final events = StreamController<String>.broadcast();
  List<PendingAreaAssignmentModel> assignments = [];
  @override
  Stream<String> get changes => events.stream;
  @override
  Future<List<PendingAreaAssignmentModel>> getForUser(String userId) async =>
      assignments;
}

class _OnlineConnectivityMonitor implements DoctorConnectivityMonitor {
  const _OnlineConnectivityMonitor();

  @override
  Stream<bool> get availabilityChanges => const Stream<bool>.empty();

  @override
  Future<bool> isNetworkAvailable() async => true;
}

class _StaticRepository implements DoctorRepository {
  _StaticRepository(this._doctors)
      : _checkpoint = DoctorSyncCheckpoint(
          bootstrapComplete: true,
          activeGeneration: 'active',
          bootstrapGeneration: null,
          bootstrapCursor: null,
          bootstrapSnapshotVersion: null,
          downloadedCount: _doctors.length,
          deltaVersion: BigInt.one,
          lastSuccessfulSyncUtc: DateTime.utc(2026, 9, 10),
        );

  final List<Doctor> _doctors;
  DoctorSyncCheckpoint _checkpoint;

  @override
  Future<DoctorSyncCheckpoint> applyDeltaPage({
    required DeltaPage page,
    required BigInt nextVersion,
    required bool isFinalPage,
    required DateTime appliedAtUtc,
  }) async {
    _checkpoint = _checkpoint.copyWith(
      deltaVersion: nextVersion,
      lastSuccessfulSyncUtc: appliedAtUtc,
    );
    return _checkpoint;
  }

  @override
  Future<DoctorSyncCheckpoint> beginBootstrap({bool restart = false}) {
    throw UnsupportedError('Bootstrap is not expected in this UI test.');
  }

  @override
  Future<void> close() async {}

  @override
  Future<DeltaPage> fetchDelta({
    required BigInt afterVersion,
    int limit = 500,
    String? headOfficeId,
  }) async {
    return fixtureDeltaPage(
      afterVersion: afterVersion,
      nextAfterVersion: afterVersion,
    );
  }

  @override
  Future<BootstrapPage> fetchBootstrap({
    String? cursor,
    int limit = 500,
  }) {
    throw UnsupportedError('Bootstrap is not expected in this UI test.');
  }

  @override
  Future<Doctor?> findByLocalId(String localId) async {
    for (final doctor in _doctors) {
      if (doctor.localId == localId) return doctor;
    }
    return null;
  }

  @override
  Future<DoctorSyncCheckpoint> promoteBootstrap({
    required String generation,
    required BigInt snapshotVersion,
    required DateTime completedAtUtc,
  }) {
    throw UnsupportedError('Bootstrap is not expected in this UI test.');
  }

  @override
  Future<List<Doctor>> readDoctors() async {
    return List<Doctor>.unmodifiable(_doctors);
  }

  @override
  Future<DoctorSyncCheckpoint> readCheckpoint() async => _checkpoint;

  @override
  Future<DoctorSyncCheckpoint> stageBootstrapPage({
    required String generation,
    required BootstrapPage page,
  }) {
    throw UnsupportedError('Bootstrap is not expected in this UI test.');
  }

  @override
  Stream<List<Doctor>> watchDoctors() {
    return Stream<List<Doctor>>.value(
      List<Doctor>.unmodifiable(_doctors),
    );
  }
}
