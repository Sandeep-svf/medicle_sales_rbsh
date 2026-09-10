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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('Samsung tablet landscape uses cards and separate profile', (
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
    expect(find.text('Practice Details'), findsOneWidget);
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

  static Future<_UiHarness> create() async {
    final repository = _StaticRepository([
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
