import 'doctor_dto.dart';
import 'doctor_model_parsing.dart';

const Object _syncUnset = Object();

class BootstrapPage {
  const BootstrapPage({
    required this.success,
    required this.snapshotVersion,
    required this.currentServerVersion,
    required this.nextCursor,
    required this.hasMore,
    required this.doctors,
  });

  final bool success;
  final BigInt snapshotVersion;
  final BigInt currentServerVersion;
  final String? nextCursor;
  final bool hasMore;
  final List<DoctorDto> doctors;

  factory BootstrapPage.fromJson(Map<String, dynamic> json) {
    final success = _requiredBool(json['success'], 'success');
    final hasMore = _requiredBool(json['hasMore'], 'hasMore');
    final cursor = DoctorModelParsing.nullableString(
      json['nextCursor'],
      'nextCursor',
    );
    final rawDoctors = json['doctors'];
    if (rawDoctors is! List) {
      throw const FormatException('doctors must be a list.');
    }
    if (hasMore && (cursor == null || cursor.isEmpty)) {
      throw const FormatException(
        'A nonempty nextCursor is required when hasMore is true.',
      );
    }

    return BootstrapPage(
      success: success,
      snapshotVersion: DoctorModelParsing.requiredVersion(
        json['snapshotVersion'],
        'snapshotVersion',
      ),
      currentServerVersion: DoctorModelParsing.requiredVersion(
        json['currentServerVersion'],
        'currentServerVersion',
      ),
      nextCursor: cursor,
      hasMore: hasMore,
      doctors: rawDoctors.map((rawDoctor) {
        if (rawDoctor is! Map) {
          throw const FormatException('Each doctor must be an object.');
        }
        return DoctorDto.fromJson(Map<String, dynamic>.from(rawDoctor));
      }).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'snapshotVersion': snapshotVersion.toString(),
      'currentServerVersion': currentServerVersion.toString(),
      'nextCursor': nextCursor,
      'hasMore': hasMore,
      'doctors': doctors.map((doctor) => doctor.toJson()).toList(),
    };
  }
}

class DoctorDeletion {
  const DoctorDeletion({required this.id, required this.syncVersion});

  final String id;
  final BigInt syncVersion;

  factory DoctorDeletion.fromJson(Map<String, dynamic> json) {
    return DoctorDeletion(
      id: DoctorModelParsing.requiredIdentifier(json['id'], 'delete.id'),
      syncVersion: DoctorModelParsing.requiredVersion(
        json['syncVersion'],
        'delete.syncVersion',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'syncVersion': syncVersion.toString()};
  }
}

class DeltaPage {
  const DeltaPage({
    required this.success,
    required this.currentServerVersion,
    required this.afterVersion,
    required this.nextAfterVersion,
    required this.hasMore,
    required this.upserts,
    required this.deletes,
    required this.deletionsFieldPresent,
  });

  final bool success;
  final BigInt currentServerVersion;
  final BigInt afterVersion;
  final BigInt? nextAfterVersion;
  final bool hasMore;
  final List<DoctorDto> upserts;
  final List<DoctorDeletion> deletes;
  final bool deletionsFieldPresent;

  factory DeltaPage.fromJson(Map<String, dynamic> json) {
    final rawUpserts = json['upserts'];
    if (rawUpserts is! List) {
      throw const FormatException('upserts must be a list.');
    }

    final deletionsFieldPresent = json.containsKey('deletes');
    final rawDeletes = json['deletes'];
    if (deletionsFieldPresent && rawDeletes is! List) {
      throw const FormatException('deletes must be a list when supplied.');
    }

    return DeltaPage(
      success: _requiredBool(json['success'], 'success'),
      currentServerVersion: DoctorModelParsing.requiredVersion(
        json['currentServerVersion'],
        'currentServerVersion',
      ),
      afterVersion: DoctorModelParsing.requiredVersion(
        json['afterVersion'],
        'afterVersion',
      ),
      nextAfterVersion: DoctorModelParsing.nullableVersion(
        json['nextAfterVersion'],
        'nextAfterVersion',
      ),
      hasMore: _requiredBool(json['hasMore'], 'hasMore'),
      upserts: rawUpserts.map((rawDoctor) {
        if (rawDoctor is! Map) {
          throw const FormatException('Each upsert must be an object.');
        }
        return DoctorDto.fromJson(Map<String, dynamic>.from(rawDoctor));
      }).toList(growable: false),
      deletes: deletionsFieldPresent
          ? (rawDeletes as List).map((rawDeletion) {
              if (rawDeletion is! Map) {
                throw const FormatException(
                  'Each deletion must be an object.',
                );
              }
              return DoctorDeletion.fromJson(
                Map<String, dynamic>.from(rawDeletion),
              );
            }).toList(growable: false)
          : const [],
      deletionsFieldPresent: deletionsFieldPresent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'currentServerVersion': currentServerVersion.toString(),
      'afterVersion': afterVersion.toString(),
      'nextAfterVersion': nextAfterVersion?.toString(),
      'hasMore': hasMore,
      'upserts': upserts.map((doctor) => doctor.toJson()).toList(),
      if (deletionsFieldPresent)
        'deletes': deletes.map((deletion) => deletion.toJson()).toList(),
    };
  }
}

class DoctorSyncCheckpoint {
  const DoctorSyncCheckpoint({
    required this.bootstrapComplete,
    required this.activeGeneration,
    required this.bootstrapGeneration,
    required this.bootstrapCursor,
    required this.bootstrapSnapshotVersion,
    required this.downloadedCount,
    required this.deltaVersion,
    required this.lastSuccessfulSyncUtc,
  });

  const DoctorSyncCheckpoint.empty()
      : bootstrapComplete = false,
        activeGeneration = null,
        bootstrapGeneration = null,
        bootstrapCursor = null,
        bootstrapSnapshotVersion = null,
        downloadedCount = 0,
        deltaVersion = null,
        lastSuccessfulSyncUtc = null;

  final bool bootstrapComplete;
  final String? activeGeneration;
  final String? bootstrapGeneration;
  final String? bootstrapCursor;
  final BigInt? bootstrapSnapshotVersion;
  final int downloadedCount;
  final BigInt? deltaVersion;
  final DateTime? lastSuccessfulSyncUtc;

  factory DoctorSyncCheckpoint.fromJson(Map<String, dynamic> json) {
    return DoctorSyncCheckpoint(
      bootstrapComplete: _requiredBool(
        json['bootstrapComplete'],
        'bootstrapComplete',
      ),
      activeGeneration: DoctorModelParsing.nullableIdentifier(
        json['activeGeneration'],
        'activeGeneration',
      ),
      bootstrapGeneration: DoctorModelParsing.nullableIdentifier(
        json['bootstrapGeneration'],
        'bootstrapGeneration',
      ),
      bootstrapCursor: DoctorModelParsing.nullableString(
        json['bootstrapCursor'],
        'bootstrapCursor',
      ),
      bootstrapSnapshotVersion: DoctorModelParsing.nullableVersion(
        json['bootstrapSnapshotVersion'],
        'bootstrapSnapshotVersion',
      ),
      downloadedCount: DoctorModelParsing.nullableInteger(
            json['downloadedCount'],
            'downloadedCount',
          ) ??
          0,
      deltaVersion: DoctorModelParsing.nullableVersion(
        json['deltaVersion'],
        'deltaVersion',
      ),
      lastSuccessfulSyncUtc: DoctorModelParsing.nullableTimestamp(
        json['lastSuccessfulSyncUtc'],
        'lastSuccessfulSyncUtc',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bootstrapComplete': bootstrapComplete,
      'activeGeneration': activeGeneration,
      'bootstrapGeneration': bootstrapGeneration,
      'bootstrapCursor': bootstrapCursor,
      'bootstrapSnapshotVersion': bootstrapSnapshotVersion?.toString(),
      'downloadedCount': downloadedCount,
      'deltaVersion': deltaVersion?.toString(),
      'lastSuccessfulSyncUtc':
          DoctorModelParsing.encodeTimestamp(lastSuccessfulSyncUtc),
    };
  }

  DoctorSyncCheckpoint copyWith({
    bool? bootstrapComplete,
    Object? activeGeneration = _syncUnset,
    Object? bootstrapGeneration = _syncUnset,
    Object? bootstrapCursor = _syncUnset,
    Object? bootstrapSnapshotVersion = _syncUnset,
    int? downloadedCount,
    Object? deltaVersion = _syncUnset,
    Object? lastSuccessfulSyncUtc = _syncUnset,
  }) {
    return DoctorSyncCheckpoint(
      bootstrapComplete: bootstrapComplete ?? this.bootstrapComplete,
      activeGeneration: identical(activeGeneration, _syncUnset)
          ? this.activeGeneration
          : activeGeneration as String?,
      bootstrapGeneration: identical(bootstrapGeneration, _syncUnset)
          ? this.bootstrapGeneration
          : bootstrapGeneration as String?,
      bootstrapCursor: identical(bootstrapCursor, _syncUnset)
          ? this.bootstrapCursor
          : bootstrapCursor as String?,
      bootstrapSnapshotVersion: identical(bootstrapSnapshotVersion, _syncUnset)
          ? this.bootstrapSnapshotVersion
          : bootstrapSnapshotVersion as BigInt?,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      deltaVersion: identical(deltaVersion, _syncUnset)
          ? this.deltaVersion
          : deltaVersion as BigInt?,
      lastSuccessfulSyncUtc: identical(lastSuccessfulSyncUtc, _syncUnset)
          ? this.lastSuccessfulSyncUtc
          : lastSuccessfulSyncUtc as DateTime?,
    );
  }
}

enum DoctorSyncPhase {
  idle,
  initializing,
  downloading,
  syncing,
  current,
  offline,
  authenticationRequired,
  storageUnavailable,
  protocolBlocked,
  failed,
}

class DoctorSyncStatus {
  const DoctorSyncStatus({
    required this.phase,
    required this.message,
    required this.downloadedCount,
    required this.hasCachedData,
    required this.lastSuccessfulSyncUtc,
  });

  const DoctorSyncStatus.idle()
      : phase = DoctorSyncPhase.idle,
        message = 'Ready',
        downloadedCount = 0,
        hasCachedData = false,
        lastSuccessfulSyncUtc = null;

  final DoctorSyncPhase phase;
  final String message;
  final int downloadedCount;
  final bool hasCachedData;
  final DateTime? lastSuccessfulSyncUtc;

  bool get isBusy {
    return phase == DoctorSyncPhase.initializing ||
        phase == DoctorSyncPhase.downloading ||
        phase == DoctorSyncPhase.syncing;
  }

  DoctorSyncStatus copyWith({
    DoctorSyncPhase? phase,
    String? message,
    int? downloadedCount,
    bool? hasCachedData,
    Object? lastSuccessfulSyncUtc = _syncUnset,
  }) {
    return DoctorSyncStatus(
      phase: phase ?? this.phase,
      message: message ?? this.message,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      hasCachedData: hasCachedData ?? this.hasCachedData,
      lastSuccessfulSyncUtc: identical(lastSuccessfulSyncUtc, _syncUnset)
          ? this.lastSuccessfulSyncUtc
          : lastSuccessfulSyncUtc as DateTime?,
    );
  }
}

bool _requiredBool(Object? value, String fieldName) {
  if (value is! bool) {
    throw FormatException('$fieldName must be a boolean.');
  }
  return value;
}
