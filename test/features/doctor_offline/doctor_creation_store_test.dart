import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/controllers/offline_doctor_create_controller.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/ui/offline_doctor_create_screen.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/ui/widgets/doctor_list_card.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/services/doctor_creation_store.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  late Directory directory;
  late File photo;
  late _MemoryDatabase db;
  late DoctorCreationStore store;
  late http.Client client;
  var allowed = true;
  final key = List<int>.generate(32, (i) => i);
  final photoBytes = [137, 80, 78, 71, 13, 10, 26, 10, 11, 22, 33];
  const payload = {
    'name': 'Dr. Local',
    'clinic_name': 'Local Clinic',
    'clinic_address': 'Street 4',
    'location': 'Kanpur',
    'latitude': 26.4721,
    'longitude': 80.3182,
    'headOfficeId': 'office',
    'areaId': 'area',
    'priority': 'B'
  };

  http.Response success(String uuid, {bool image = false, String? serverId}) =>
      http.Response(
          jsonEncode({
            'success': true,
            'data': {
              ...payload,
              'id': serverId ?? 'server-$uuid',
              'clientGeneratedId': uuid,
              'syncVersion': image ? '1006' : '1005',
              'latitude': '26.47210000',
              'longitude': '80.31820000',
              'geo_image_url': image ? 'https://example.test/image.png' : null,
              'headOffice': {'id': 'office', 'name': 'Office'},
              'area': {'id': 'area', 'name': 'Area'},
            }
          }),
          image ? 200 : 201);

  DoctorCreationStore open() => DoctorCreationStore(
      database: db,
      directory: directory.path,
      encryptionKey: key,
      baseUrl: 'https://example.test/api',
      tokenProvider: () async => 'test-token',
      scopeGuard: () async => allowed,
      client: client);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('doctor_creation_test_');
    photo =
        await File('${directory.path}/capture.png').writeAsBytes(photoBytes);
    db = _MemoryDatabase();
    allowed = true;
    client = MockClient((_) async => http.Response('', 503));
    store = open();
  });
  tearDown(() async {
    await store.close();
    client.close();
    await directory.delete(recursive: true);
  });

  test('durable encrypted photo and SQLite payload survive reopening',
      () async {
    final uuid = await store.save(
        payload: payload,
        image: photo,
        headOfficeName: 'Office',
        areaName: 'Area');
    await photo.delete();
    expect((await store.readDoctors()).single.localSyncState,
        DoctorLocalSyncState.pendingCreate);
    expect((await store.readDoctors()).single.clientGeneratedId, uuid);
    expect(
        utf8.decode(db.rows.single['payload'] as List<int>,
            allowMalformed: true),
        isNot(contains('Dr. Local')));
    expect(await File(db.rows.single['image_path'] as String).readAsBytes(),
        isNot(photoBytes));
    await store.close();
    store = open();
    expect(await store.readImage(uuid), photoBytes);
    expect((await store.readDoctors()).single.clinicName, 'Local Clinic');
  });

  test(
      'create acknowledgment persists before image failure; retry uploads image only',
      () async {
    var creates = 0;
    var images = 0;
    var failImage = true;
    client = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer test-token');
      if (request.url.path == '/api/doctors') {
        creates++;
        expect(request.headers['content-type'], contains('application/json'));
        final body = jsonDecode(request.body) as Map;
        expect(body['headOfficeId'], 'office');
        return success(body['clientGeneratedId'] as String);
      }
      images++;
      final uuid = request.url.pathSegments[2];
      expect(request.url.path, '/api/doctors/$uuid/geo-image');
      expect(request.method, 'POST');
      expect(latin1.decode(request.bodyBytes), contains('name="geo_image"'));
      expect(latin1.decode(request.bodyBytes), contains('image/png'));
      return failImage
          ? http.Response('', 503)
          : success(uuid, image: true, serverId: 'image-response-id');
    });
    await store.close();
    store = open();
    final uuid = await store.save(payload: payload, image: photo);
    await store.synchronize();
    expect((await store.readDoctors()).single.localSyncState,
        DoctorLocalSyncState.synced);
    expect(await store.pendingImages(), {uuid});
    expect(creates, 1);
    expect(images, 1);
    await store.close();
    store = open();
    failImage = false;
    await store.synchronize();
    expect(creates, 1);
    expect(images, 2);
    expect(await store.pendingImages(), isEmpty);
    expect((await store.readDoctors()).single.geoImageUrl,
        'https://example.test/image.png');
  });

  test('45 records use bounded batches and coalesced, sequential requests',
      () async {
    var creates = 0;
    var images = 0;
    var inFlight = 0;
    var peak = 0;
    client = MockClient((request) async {
      inFlight++;
      if (inFlight > peak) peak = inFlight;
      await Future<void>.delayed(Duration.zero);
      late http.Response response;
      if (request.url.path.endsWith('/geo-image')) {
        images++;
        response = success(request.url.pathSegments[2], image: true);
      } else {
        creates++;
        response =
            success(jsonDecode(request.body)['clientGeneratedId'] as String);
      }
      inFlight--;
      return response;
    });
    await store.close();
    store = open();
    for (var i = 0; i < 45; i++) {
      await store
          .save(payload: {...payload, 'name': 'Doctor $i'}, image: photo);
    }
    await Future.wait([store.synchronize(), store.synchronize()]);
    expect(creates, 45);
    expect(images, 45);
    expect(peak, 1);
    expect(db.batchSizes, containsAllInOrder([20, 20, 5, 0]));
    expect(db.limits.every((value) => value == DoctorCreationStore.batchSize),
        isTrue);
  });

  test('mismatched UUID cannot clear pending state or upload image', () async {
    var requests = 0;
    client = MockClient((_) async {
      requests++;
      return success('wrong-uuid');
    });
    await store.close();
    store = open();
    await store.save(payload: payload, image: photo);
    await store.synchronize();
    expect(requests, 1);
    expect((await store.readDoctors()).single.localSyncState,
        DoctorLocalSyncState.pendingCreate);
    expect(store.message, isNotNull);
  });

  test(
      'scope change during create prevents image request and local acknowledgment',
      () async {
    var requests = 0;
    client = MockClient((request) async {
      requests++;
      allowed = false;
      return success(jsonDecode(request.body)['clientGeneratedId'] as String);
    });
    await store.close();
    store = open();
    await store.save(payload: payload, image: photo);
    await store.synchronize();
    expect(requests, 1);
    expect(db.rows.single['created'], 0);
  });

  test(
      'download recovers lost create response and later owns deletion visibility',
      () async {
    var creates = 0;
    client = MockClient((request) async {
      if (!request.url.path.endsWith('/geo-image')) creates++;
      return success(request.url.pathSegments[2], image: true);
    });
    await store.close();
    store = open();
    final uuid = await store.save(payload: payload, image: photo);
    final downloaded = DoctorCreationStore.recordFromApi(
            Map<String, dynamic>.from(
                jsonDecode(success(uuid).body)['data'] as Map),
            'download-local-id')
        .toDomain();
    await store.reconcileDownloaded([downloaded]);
    await store.synchronize();
    expect(creates, 0);
    final updated = (await store.readDoctors()).single;
    await store.reconcileDownloaded([updated]);
    expect(await store.readDoctors(), isEmpty);
    expect(await store.readImage(uuid), photoBytes);
    expect(await store.localIds(), {uuid});
  });
  test('queues an image for an existing doctor without creating it again',
      () async {
    var createRequests = 0;
    var imageRequests = 0;
    client = MockClient((request) async {
      if (request.url.path.endsWith('/geo-image')) {
        imageRequests++;
        return success(request.url.pathSegments[2],
            image: true, serverId: 'existing-server');
      }
      createRequests++;
      return http.Response('', 500);
    });
    await store.close();
    store = open();
    final doctor = DoctorCreationStore.recordFromApi({
      ...payload,
      'id': 'existing-server',
      'clientGeneratedId': 'existing-client',
      'syncVersion': '12',
    }, 'existing-local')
        .toDomain();
    await store.queueImage(doctor: doctor, image: photo);
    await store.synchronize();
    expect(createRequests, 0);
    expect(imageRequests, 1);
    expect(await store.pendingImages(), isEmpty);
  });

  test('existing doctor without client UUID uploads by server ID', () async {
    var requestedPath = '';
    client = MockClient((request) async {
      requestedPath = request.url.path;
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            ...payload,
            'id': 'existing-server',
            'geo_image_url': 'https://example.test/image.png',
            'syncVersion': '13',
          },
        }),
        200,
      );
    });
    await store.close();
    store = open();
    final doctor = DoctorCreationStore.recordFromApi({
      ...payload,
      'id': 'existing-server',
      'syncVersion': '12',
    }, 'existing-local')
        .toDomain();
    await store.queueImage(doctor: doctor, image: photo);
    await store.synchronize();

    expect(requestedPath, '/api/doctors/existing-server/geo-image');
    expect(await store.pendingImages(), isEmpty);
  });

  test('image added before doctor creation sync keeps the create payload',
      () async {
    var creates = 0;
    var images = 0;
    client = MockClient((request) async {
      if (request.url.path.endsWith('/geo-image')) {
        images++;
        return success(request.url.pathSegments[2], image: true);
      }
      creates++;
      final body = jsonDecode(request.body) as Map;
      expect(body['name'], 'Dr. Local');
      return success(body['clientGeneratedId'] as String);
    });
    await store.close();
    store = open();

    final uuid = await store.save(payload: payload, image: photo);
    final localDoctor = (await store.readDoctors()).single;
    expect(localDoctor.localSyncState, DoctorLocalSyncState.pendingCreate);
    await store.queueImage(doctor: localDoctor, image: photo);
    await store.synchronize();

    expect(creates, 1);
    expect(images, 1);
    expect(await store.pendingImages(), isEmpty);
    expect((await store.readDoctors()).single.clientGeneratedId, uuid);
  });

  test('image queued during an active sync is picked up by the same worker',
      () async {
    final createStarted = Completer<void>();
    final releaseCreate = Completer<void>();
    var imageRequests = 0;
    client = MockClient((request) async {
      if (request.url.path.endsWith('/geo-image')) {
        imageRequests++;
        return success(request.url.pathSegments[2], image: true);
      }
      createStarted.complete();
      await releaseCreate.future;
      final body = jsonDecode(request.body) as Map;
      return success(body['clientGeneratedId'] as String);
    });
    await store.close();
    store = open();

    await store.save(payload: payload, image: photo);
    final activeSync = store.synchronize();
    await createStarted.future;

    final existing = DoctorCreationStore.recordFromApi({
      ...payload,
      'id': 'existing-server',
      'clientGeneratedId': 'existing-client',
      'syncVersion': '12',
    }, 'existing-local')
        .toDomain();
    await store.queueImage(doctor: existing, image: photo);
    releaseCreate.complete();
    await activeSync;

    expect(imageRequests, 2);
    expect(await store.pendingImages(), isEmpty);
  });

  for (final size in [const Size(430, 900), const Size(800, 1280)]) {
    testWidgets('offline creation form renders at ${size.width} width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final form =
          OfflineDoctorCreateController(store: store, cachedDoctors: const []);
      form.headOffices.assignAll([
        {'id': 'office', 'name': 'Office'}
      ]);
      form.areas.assignAll([
        {'id': 'area', 'name': 'Area'}
      ]);
      await tester.pumpWidget(
          GetMaterialApp(home: OfflineDoctorCreateScreen(controller: form)));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('Add New Doctor'), findsOneWidget);
      expect(find.text('Clinic Name'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      form.onClose();
    });
  }

  testWidgets('offline-only badge clears independently of pending photo',
      (tester) async {
    final doctor = DoctorCreationStore.recordFromApi({
      ...payload,
      'id': 'server',
      'clientGeneratedId': 'local',
      'syncVersion': '1',
    }, 'local')
        .toDomain();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DoctorListCard(
      doctor: doctor.copyWith(
          serverId: null, localSyncState: DoctorLocalSyncState.pendingCreate),
      selected: false,
      onTap: () {},
    ))));
    expect(find.text('Offline stored only'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DoctorListCard(
      doctor: doctor,
      imagePending: true,
      selected: false,
      onTap: () {},
    ))));
    expect(find.text('Offline stored only'), findsNothing);
    expect(find.text('Photo upload pending'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('doctor without geo image exposes the add image action',
      (tester) async {
    final doctor = DoctorCreationStore.recordFromApi({
      ...payload,
      'id': 'server-no-image',
      'clientGeneratedId': 'client-no-image',
      'syncVersion': '1',
    }, 'local-no-image')
        .toDomain();
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DoctorListCard(
          doctor: doctor,
          selected: false,
          onTap: () {},
          onAddGeoImage: () => tapped = true,
        ),
      ),
    ));
    expect(find.text('Add Geo Image'), findsOneWidget);
    await tester.tap(find.text('Add Geo Image'));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('geo image action shows a loader while camera is opening',
      (tester) async {
    final doctor = DoctorCreationStore.recordFromApi({
      ...payload,
      'id': 'server-busy',
      'clientGeneratedId': 'client-busy',
      'syncVersion': '1',
    }, 'local-busy')
        .toDomain();
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DoctorListCard(
          doctor: doctor,
          selected: false,
          onTap: () {},
          imageActionBusy: true,
          onAddGeoImage: () => tapped = true,
        ),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Add Geo Image'));
    expect(tapped, isFalse);
    expect(tester.takeException(), isNull);
  });
}

/// Exercises storage/restart and transport logic without a platform SQLite
/// plugin. Real sqflite open/schema behavior is left to device verification.
class _MemoryDatabase implements Database {
  final rows = <Map<String, Object?>>[];
  final lookups = <Map<String, Object?>>[];
  final limits = <int>[];
  final batchSizes = <int>[];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    if (table == 'lookups') {
      lookups.removeWhere((row) => row['kind'] == values['kind']);
      lookups.add(Map.of(values));
      return lookups.length;
    }
    if (conflictAlgorithm == ConflictAlgorithm.replace) {
      rows.removeWhere((row) => row['uuid'] == values['uuid']);
    }
    rows.add({
      'sequence': rows.length + 1,
      'created': 0,
      'image_uploaded': 0,
      'visible': 1,
      ...values
    });
    return rows.length;
  }

  @override
  Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    Iterable<Map<String, Object?>> result = table == 'lookups' ? lookups : rows;
    if (where == 'uuid = ?')
      result = result.where((r) => r['uuid'] == whereArgs![0]);
    if (where == 'kind = ?')
      result = result.where((r) => r['kind'] == whereArgs![0]);
    if (where == 'visible = 1') result = result.where((r) => r['visible'] == 1);
    if (where == 'created = 1 AND image_uploaded = 0')
      result =
          result.where((r) => r['created'] == 1 && r['image_uploaded'] == 0);
    if (where?.startsWith('sequence >') ?? false) {
      result = result.where((r) =>
          (r['sequence'] as int) > (whereArgs![0] as int) &&
          (r['sequence'] as int) <= (whereArgs[1] as int) &&
          (r['created'] == 0 || r['image_uploaded'] == 0));
      limits.add(limit!);
    }
    if (limit != null) result = result.take(limit);
    final output = result.map((r) => Map<String, Object?>.of(r)).toList();
    if (where?.startsWith('sequence >') ?? false) batchSizes.add(output.length);
    return output;
  }

  @override
  Future<int> update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) async {
    for (final row in rows.where((r) => r['uuid'] == whereArgs![0])) {
      row.addAll(values);
    }
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) async =>
      [
        {'MAX(sequence)': rows.length}
      ];
  @override
  Future<void> close() async {}
}
