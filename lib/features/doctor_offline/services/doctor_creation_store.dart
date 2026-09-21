import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/doctor.dart';
import '../models/doctor_dto.dart';
import '../models/doctor_record.dart';

/// SQLite outbox isolated from legacy databases. Payloads, lookup data and
/// durable image files are authenticated/encrypted with the account cache key.
class DoctorCreationStore {
  DoctorCreationStore({
    required this.database,
    required this.directory,
    required List<int> encryptionKey,
    required this.baseUrl,
    required this.tokenProvider,
    required this.scopeGuard,
    http.Client? client,
  })  : _key = SecretKey(encryptionKey),
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  final Database database;
  final String directory;
  final String baseUrl;
  final Future<String?> Function() tokenProvider;
  final Future<bool> Function() scopeGuard;
  final SecretKey _key;
  final http.Client _client;
  final bool _ownsClient;
  final _cipher = AesGcm.with256bits();
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;
  Future<void>? _running;
  bool _closed = false;
  bool _rescan = false;
  String? message;
  bool get uploading => _running != null;
  static const batchSize = 20;

  static Future<Database> openDatabaseAt(String directory) async {
    await Directory(directory).create(recursive: true);
    return openDatabase(path.join(directory, 'doctor_creations.sqlite'),
        version: 1, onCreate: (db, _) async {
      await db.execute(
          'CREATE TABLE creations (sequence INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT NOT NULL UNIQUE, payload BLOB NOT NULL, record BLOB NOT NULL, image_path TEXT NOT NULL, created INTEGER NOT NULL DEFAULT 0, image_uploaded INTEGER NOT NULL DEFAULT 0, visible INTEGER NOT NULL DEFAULT 1)');
      await db.execute(
          'CREATE TABLE lookups (kind TEXT PRIMARY KEY, payload BLOB NOT NULL)');
    });
  }

  Future<Uint8List> _seal(List<int> bytes) async {
    final box = await _cipher.encrypt(bytes, secretKey: _key);
    return Uint8List.fromList(box.concatenation());
  }

  Future<Uint8List> _unseal(List<int> bytes) async =>
      Uint8List.fromList(await _cipher.decrypt(
          SecretBox.fromConcatenation(bytes, nonceLength: 12, macLength: 16),
          secretKey: _key));

  Future<Uint8List> _encode(Map<String, dynamic> data) =>
      _seal(utf8.encode(jsonEncode(data)));
  Future<Map<String, dynamic>> _decode(Object? data) async =>
      Map<String, dynamic>.from(
          jsonDecode(utf8.decode(await _unseal((data as List).cast<int>())))
              as Map);

  Future<void> _checkScope() async {
    if (_closed || !await scopeGuard()) {
      throw StateError('The doctor account changed. Reopen Offline Doctors.');
    }
  }

  void _notify() {
    if (!_closed) _changes.add(null);
  }

  Future<String> save(
      {required Map<String, dynamic> payload,
      required File image,
      String? headOfficeName,
      String? areaName}) async {
    await _checkScope();
    final uuid = const Uuid().v4();
    final body = {...payload, 'clientGeneratedId': uuid};
    final record = recordFromApi({
      ...body,
      'id': uuid,
      'syncVersion': '0',
      'headOfficeName': headOfficeName,
      'areaName': areaName,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    }, uuid)
        .copyWith(
            serverId: null,
            syncVersion: null,
            localSyncState: DoctorLocalSyncState.pendingCreate);
    final imageFile = File(path.join(directory, '$uuid.image'));
    await imageFile.writeAsBytes(await _seal(await image.readAsBytes()),
        flush: true);
    try {
      final encodedPayload = await _encode(body);
      final encodedRecord = await _encode(record.toJson());
      await _checkScope();
      await database.insert('creations', {
        'uuid': uuid,
        'payload': encodedPayload,
        'record': encodedRecord,
        'image_path': imageFile.path
      });
    } catch (_) {
      await imageFile.delete();
      rethrow;
    }
    if (_running != null) _rescan = true;
    _notify();
    return uuid;
  }

  Future<String> queueImage(
      {required Doctor doctor, required File image}) async {
    await _checkScope();
    final uuid = doctor.geoImageUploadId;
    final existingRows = await database.query(
      'creations',
      columns: ['payload', 'created'],
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );
    final existing = existingRows.isEmpty ? null : existingRows.first;
    final createStillPending = existing?['created'] == 0 ||
        (doctor.localSyncState == DoctorLocalSyncState.pendingCreate &&
            doctor.serverId == null);
    final payload = createStillPending && existing?['payload'] != null
        ? await _decode(existing!['payload'])
        : <String, dynamic>{'clientGeneratedId': uuid};
    final imageFile = File(path.join(directory, '$uuid.image'));
    await imageFile.writeAsBytes(await _seal(await image.readAsBytes()),
        flush: true);
    try {
      final encodedRecord =
          await _encode(DoctorRecord.fromDomain(doctor).toJson());
      final encodedPayload = await _encode(payload);
      await _checkScope();
      await database.insert(
          'creations',
          {
            'uuid': uuid,
            'payload': encodedPayload,
            'record': encodedRecord,
            'image_path': imageFile.path,
            'created': createStillPending ? 0 : 1,
            'image_uploaded': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      await imageFile.delete();
      rethrow;
    }
    // If a doctor sync is already draining the outbox, its current pass may
    // have taken its snapshot before this image was queued. Ask that same
    // worker to rescan so the image is uploaded without requiring a second
    // manual refresh.
    if (_running != null) _rescan = true;
    _notify();
    return uuid;
  }

  Future<List<Doctor>> readDoctors() async {
    final rows = await database.query('creations',
        columns: ['record'], where: 'visible = 1');
    final result = <Doctor>[];
    for (final row in rows) {
      result
          .add(DoctorRecord.fromJson(await _decode(row['record'])).toDomain());
    }
    return result;
  }

  Future<Set<String>> localIds() async =>
      (await database.query('creations', columns: ['uuid']))
          .map((row) => row['uuid'] as String)
          .toSet();

  /// A download can acknowledge a create whose HTTP response was lost. Once a
  /// completed upload appears in the server cache, that cache owns visibility
  /// (including future server deletions); retain only the local photo archive.
  Future<void> reconcileDownloaded(List<Doctor> doctors) async {
    await _checkScope();
    final byClient = {
      for (final d in doctors)
        if (d.clientGeneratedId != null) d.clientGeneratedId!: d
    };
    if (byClient.isEmpty) return;
    final rows = await database.query('creations', where: 'visible = 1');
    var changed = false;
    for (final row in rows) {
      final uuid = row['uuid'] as String;
      final remote = byClient[uuid];
      if (remote == null || remote.serverId == null) continue;
      final local = DoctorRecord.fromJson(await _decode(row['record']));
      if (local.serverId != null && local.serverId != remote.serverId) continue;
      final remoteIsCurrent = remote.syncVersion != null &&
          (local.syncVersion == null ||
              remote.syncVersion! >= local.syncVersion!);
      if (!remoteIsCurrent) continue;
      final remoteHasImage = remote.geoImageUrl?.trim().isNotEmpty == true;
      // Do not archive a locally completed image upload until the server
      // delta confirms the image URL. This protects the offline list from an
      // older doctor version returned during the same sync pass.
      final imageConfirmed = row['image_uploaded'] == 1 && remoteHasImage;
      if (row['created'] == 0 || imageConfirmed) {
        final encoded = await _encode(
            DoctorRecord.fromDomain(remote.copyWith(localId: uuid)).toJson());
        await _checkScope();
        await database.update(
            'creations',
            {
              'created': 1,
              'record': encoded,
              'visible': imageConfirmed ? 0 : 1
            },
            where: 'uuid = ?',
            whereArgs: [uuid]);
        changed = true;
      }
    }
    if (changed) _notify();
  }

  Future<Set<String>> pendingImages() async =>
      (await database.query('creations',
              columns: ['uuid'], where: 'created = 1 AND image_uploaded = 0'))
          .map((row) => row['uuid'] as String)
          .toSet();

  Future<Uint8List?> readImage(String uuid) async {
    final rows = await database.query('creations',
        columns: ['image_path'],
        where: 'uuid = ?',
        whereArgs: [uuid],
        limit: 1);
    if (rows.isEmpty) return null;
    return _unseal(
        await File(rows.first['image_path'] as String).readAsBytes());
  }

  Future<bool> hasStoredImage(String uuid) async {
    try {
      return await readImage(uuid) != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> readLookup(String kind) async {
    final rows =
        await database.query('lookups', where: 'kind = ?', whereArgs: [kind]);
    if (rows.isEmpty) return [];
    return List<Map<String, dynamic>>.from(
        (await _decode(rows.first['payload']))['items'] as List);
  }

  Future<void> saveLookup(String kind, List<Map<String, dynamic>> items) async {
    final encoded = await _encode({'items': items});
    await _checkScope();
    await database.insert('lookups', {'kind': kind, 'payload': encoded},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> synchronize() {
    if (_closed) return Future.value();
    if (_running != null) return _running!;
    final future = _drain();
    _running = future;
    _notify();
    return future.whenComplete(() {
      _running = null;
      _notify();
    });
  }

  Future<void> _drain() async {
    do {
      _rescan = false;
      await _upload();
    } while (_rescan && !_closed && message == null);
  }

  Future<void> _upload() async {
    message = null;
    try {
      await _checkScope();
      // A fixed upper bound makes each pass finite even if more doctors are added.
      final maxSequence = Sqflite.firstIntValue(
              await database.rawQuery('SELECT MAX(sequence) FROM creations')) ??
          0;
      var after = 0;
      var failed = 0;
      while (!_closed) {
        await _checkScope();
        final rows = await database.query('creations',
            where:
                'sequence > ? AND sequence <= ? AND (created = 0 OR image_uploaded = 0)',
            whereArgs: [after, maxSequence],
            orderBy: 'sequence',
            limit: batchSize);
        if (rows.isEmpty) break;
        for (final row in rows) {
          await _checkScope();
          after = row['sequence'] as int;
          try {
            await _uploadOne(row);
          } on FileSystemException {
            failed++;
          } on FormatException {
            failed++;
          } on _UploadRejected catch (error) {
            failed++;
            // Authentication failures invalidate the whole pass. A server
            // error for one doctor must not prevent later doctors from being
            // attempted; the failed row remains in the outbox for retry.
            if (error.status == 401 || error.status == 403) {
              rethrow;
            }
          }
        }
        if (failed > 0) {
          message =
              '$failed doctor upload(s) need retry. Saved data is retained.';
        }
        _notify();
        await Future<void>.delayed(Duration.zero);
      }
    } on _UploadRejected catch (error) {
      message = error.status == 401 || error.status == 403
          ? 'Sign in with an authorized account to upload saved doctors.'
          : 'Server could not accept uploads (${error.status}). Saved data will retry on refresh or reconnection.';
    } catch (_) {
      message =
          'Upload paused. Saved doctors and photos will retry on refresh or reconnection.';
    }
  }

  Uri _uri(String endpoint) {
    final base = Uri.parse(baseUrl);
    final basePath = base.path.replaceFirst(RegExp(r'/+$'), '');
    final api = basePath.endsWith('/api') ? basePath : '$basePath/api';
    return base.replace(path: '$api/$endpoint', query: null, fragment: null);
  }

  Future<void> _uploadOne(Map<String, Object?> row) async {
    final uuid = row['uuid'] as String;
    final token = await tokenProvider();
    if (token == null || token.isEmpty) throw const _UploadRejected(401);
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    };
    var record = DoctorRecord.fromJson(await _decode(row['record']));
    if (row['created'] == 0) {
      final body = await _decode(row['payload']);
      await _checkScope();
      final response = await _client
          .post(_uri('doctors'),
              headers: {...headers, 'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      record = _responseRecord(response, uuid, record, expectedStatus: 201);
      final encoded = await _encode(record.toJson());
      await _checkScope();
      await database.update('creations', {'created': 1, 'record': encoded},
          where: 'uuid = ?', whereArgs: [uuid]);
      _notify();
    }
    if (row['image_uploaded'] == 0) {
      final bytes =
          await _unseal(await File(row['image_path'] as String).readAsBytes());
      final png = bytes.length >= 4 &&
          bytes[0] == 137 &&
          bytes[1] == 80 &&
          bytes[2] == 78 &&
          bytes[3] == 71;
      final request =
          http.MultipartRequest('POST', _uri('doctors/$uuid/geo-image'))
            ..headers.addAll(headers)
            ..files.add(http.MultipartFile.fromBytes('geo_image', bytes,
                filename: '$uuid.${png ? 'png' : 'jpg'}',
                contentType: MediaType('image', png ? 'png' : 'jpeg')));
      await _checkScope();
      final response = await (() async =>
              http.Response.fromStream(await _client.send(request)))()
          .timeout(const Duration(seconds: 60));
      record = _responseRecord(response, uuid, record,
          expectedStatus: 200, allowServerIdChange: true);
      if (record.geoImageUrl == null || record.geoImageUrl!.isEmpty) {
        throw const FormatException('Missing uploaded image URL');
      }
      final encoded = await _encode(record.toJson());
      await _checkScope();
      await database.update(
          'creations', {'image_uploaded': 1, 'record': encoded},
          where: 'uuid = ?', whereArgs: [uuid]);
      _notify();
    }
  }

  DoctorRecord _responseRecord(
      http.Response response, String uuid, DoctorRecord previous,
      {required int expectedStatus, bool allowServerIdChange = false}) {
    if (response.statusCode != expectedStatus) {
      throw _UploadRejected(response.statusCode);
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] != true) {
      throw const FormatException('Unsuccessful response');
    }
    final data = Map<String, dynamic>.from(json['data'] as Map);
    final clientId = data['clientGeneratedId'] ?? data['client_generated_id'];
    final responseServerId = data['id']?.toString();
    final identityMatches = clientId == uuid ||
        (previous.serverId != null && responseServerId == previous.serverId);
    if (!identityMatches) {
      throw const FormatException('Doctor UUID mismatch');
    }
    final record = recordFromApi(data, uuid);
    if (!allowServerIdChange &&
        previous.serverId != null &&
        previous.serverId != record.serverId) {
      throw const FormatException('Server ID mismatch');
    }
    return record.copyWith(
        serverId: allowServerIdChange
            ? (previous.serverId ?? record.serverId)
            : record.serverId,
        headOfficeName: record.headOfficeName ?? previous.headOfficeName,
        areaName: record.areaName ?? previous.areaName);
  }

  static DoctorRecord recordFromApi(
      Map<String, dynamic> source, String localId) {
    final json = Map<String, dynamic>.from(source);
    const aliases = {
      'clinic_name': 'clinicName',
      'clinic_address': 'clinicAddress',
      'registration_number': 'registrationNumber',
      'years_of_experience': 'yearsOfExperience',
      'date_of_birth': 'dateOfBirth',
      'consultation_fee': 'consultationFee',
      'available_timings': 'availableTimings',
      'geo_image_url': 'geoImageUrl',
      'ucpmp_annual_cap': 'ucpmpAnnualCap',
      'created_by_name': 'createdByName',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
      'client_generated_id': 'clientGeneratedId'
    };
    for (final entry in aliases.entries) {
      json[entry.value] ??= json[entry.key];
    }
    json['headOfficeName'] ??= (json['headOffice'] as Map?)?['name'];
    json['areaName'] ??= (json['area'] as Map?)?['name'];
    return DoctorRecord.fromDto(
        dto: DoctorDto.fromJson(json), localId: localId);
  }

  Future<void> close() async {
    _closed = true;
    if (_ownsClient) _client.close();
    await _running;
    await _changes.close();
    await database.close();
  }
}

class _UploadRejected implements Exception {
  const _UploadRejected(this.status);
  final int status;
}
