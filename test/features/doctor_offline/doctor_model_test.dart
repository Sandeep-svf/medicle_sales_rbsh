import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_dto.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_record.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_sync_models.dart';

import 'doctor_test_fixtures.dart';

void main() {
  group('DoctorDto', () {
    test('parses the complete supplied bootstrap doctor without data loss', () {
      final json = fullDoctorJson();
      expect(json, hasLength(31));

      final doctor = DoctorDto.fromJson(json);

      expect(doctor.id, '00f08a0d-65e9-443d-964a-b99f5141ccb9');
      expect(doctor.name, 'sam 123');
      expect(doctor.specialization, isNull);
      expect(doctor.clinicName, isNull);
      expect(doctor.clinicAddress, isNull);
      expect(doctor.location, 'Unable to get address.');
      expect(doctor.latitude, 28.58993961);
      expect(doctor.longitude, 77.43492868);
      expect(doctor.email, isNull);
      expect(doctor.phone, isNull);
      expect(doctor.registrationNumber, isNull);
      expect(doctor.yearsOfExperience, isNull);
      expect(doctor.dateOfBirth, isNull);
      expect(doctor.qualification, isNull);
      expect(doctor.consultationFee, isNull);
      expect(doctor.availableTimings, isNull);
      expect(doctor.geoImageUrl, isNull);
      expect(doctor.gender, 'Male');
      expect(doctor.anniversary, isNull);
      expect(doctor.priority, 'C');
      expect(doctor.headOfficeId, '0c9bc293-9cc9-4013-8ba4-b89002d5b491');
      expect(doctor.headOfficeName, 'Gaya');
      expect(doctor.areaId, 'c79df78a-32be-4532-9da8-faa7ce27b784');
      expect(doctor.areaName, 'alkkdd');
      expect(doctor.ucpmpAnnualCap, 100000);
      expect(doctor.createdByName, isNull);
      expect(doctor.clientGeneratedId, isNull);
      expect(doctor.syncVersion, BigInt.one);
      expect(doctor.createdAt, DateTime.parse('2026-01-06T10:39:34.134Z'));
      expect(doctor.updatedAt, DateTime.parse('2026-07-01T09:57:58.860Z'));
    });

    test('preserves exact BIGINT versions and accepted numeric variations', () {
      final json = fullDoctorJson(
        syncVersion: '900719925474099312345',
      )
        ..['yearsOfExperience'] = 14.0
        ..['consultationFee'] = '1250.75'
        ..['ucpmpAnnualCap'] = '100000';

      final doctor = DoctorDto.fromJson(json);

      expect(doctor.syncVersion.toString(), '900719925474099312345');
      expect(doctor.yearsOfExperience, 14);
      expect(doctor.consultationFee, 1250.75);
      expect(doctor.ucpmpAnnualCap, 100000);
      expect(doctor.toJson()['syncVersion'], '900719925474099312345');
    });

    test('normalizes matching client id aliases and rejects conflicts', () {
      final matching = fullDoctorJson(
        clientGeneratedId: 'client-1',
        clientGeneratedIdAlias: 'client-1',
      );
      expect(DoctorDto.fromJson(matching).clientGeneratedId, 'client-1');

      final conflicting = fullDoctorJson(
        clientGeneratedId: 'client-1',
        clientGeneratedIdAlias: 'client-2',
      );
      expect(
        () => DoctorDto.fromJson(conflicting),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid identities, versions, and optional values', () {
      expect(
        () => DoctorDto.fromJson(fullDoctorJson()..['id'] = ''),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => DoctorDto.fromJson(fullDoctorJson()..['syncVersion'] = 1.2),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => DoctorDto.fromJson(fullDoctorJson()..['latitude'] = 'north'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => DoctorDto.fromJson(
          fullDoctorJson()..['dateOfBirth'] = '2026-02-31',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('DoctorRecord preserves future pending-create identity metadata', () {
    final pending = fixtureDoctorRecord().copyWith(
      serverId: null,
      clientGeneratedId: 'future-client-id',
      localSyncState: DoctorLocalSyncState.pendingCreate,
      syncVersion: null,
    );

    final restored = DoctorRecord.fromJson(pending.toJson());

    expect(restored.localId, pending.localId);
    expect(restored.serverId, isNull);
    expect(restored.clientGeneratedId, 'future-client-id');
    expect(restored.localSyncState, DoctorLocalSyncState.pendingCreate);
    expect(restored.syncVersion, isNull);
  });

  test('BootstrapPage validates cursor and required envelope fields', () {
    final json = {
      'success': true,
      'snapshotVersion': 1,
      'currentServerVersion': 1,
      'nextCursor': null,
      'hasMore': true,
      'doctors': <Object>[],
    };
    expect(
      () => BootstrapPage.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });
}
