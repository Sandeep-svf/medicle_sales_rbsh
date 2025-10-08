/*
// lib/data/models/pdf_item.dart
class PdfItem {
  final int? id;
  final String title;
  final String fileKey;
  final String? finalUrl;     // exact final URL used to download (signed)
  final String? updatedAt;    // ISO-8601 from server
  final String? localPath;    // absolute path to downloaded PDF
  final String? lastSyncedAt; // for housekeeping

  PdfItem({
    this.id,
    required this.title,
    required this.fileKey,
    this.finalUrl,
    this.updatedAt,
    this.localPath,
    this.lastSyncedAt,
  });

  PdfItem copyWith({
    int? id,
    String? title,
    String? fileKey,
    String? finalUrl,
    String? updatedAt,
    String? localPath,
    String? lastSyncedAt,
  }) {
    return PdfItem(
      id: id ?? this.id,
      title: title ?? this.title,
      fileKey: fileKey ?? this.fileKey,
      finalUrl: finalUrl ?? this.finalUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      localPath: localPath ?? this.localPath,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  factory PdfItem.fromDb(Map<String, Object?> map) {
    return PdfItem(
      id: map['id'] as int?,
      title: (map['title'] ?? 'Untitled').toString(),
      fileKey: (map['fileKey'] ?? '').toString(),
      finalUrl: (map['finalUrl'] ?? '').toString().isEmpty ? null : (map['finalUrl'] as String),
      updatedAt: (map['updatedAt'] ?? '').toString().isEmpty ? null : (map['updatedAt'] as String),
      localPath: (map['localPath'] ?? '').toString().isEmpty ? null : (map['localPath'] as String),
      lastSyncedAt: (map['lastSyncedAt'] ?? '').toString().isEmpty ? null : (map['lastSyncedAt'] as String),
    );
  }

  Map<String, Object?> toDb() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'fileKey': fileKey,
      'finalUrl': finalUrl ?? '',
      'updatedAt': updatedAt ?? '',
      'localPath': localPath ?? '',
      'lastSyncedAt': lastSyncedAt ?? '',
    };
  }
}
*/


class PdfItem {
  final int? idPk;            // local db id (autoincrement)
  final String id;            // server GUID
  final String title;
  final String? description;
  final String fileKey;       // server file_key
  final String? updatedAt;    // server updated_at
  final String? signedUrl;    // last signed url we used
  final String? localPath;    // downloaded absolute path
  final String? lastSyncedAt; // when we cached

  PdfItem({
    this.idPk,
    required this.id,
    required this.title,
    this.description,
    required this.fileKey,
    this.updatedAt,
    this.signedUrl,
    this.localPath,
    this.lastSyncedAt,
  });

  PdfItem copyWith({
    int? idPk,
    String? id,
    String? title,
    String? description,
    String? fileKey,
    String? updatedAt,
    String? signedUrl,
    String? localPath,
    String? lastSyncedAt,
  }) {
    return PdfItem(
      idPk: idPk ?? this.idPk,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileKey: fileKey ?? this.fileKey,
      updatedAt: updatedAt ?? this.updatedAt,
      signedUrl: signedUrl ?? this.signedUrl,
      localPath: localPath ?? this.localPath,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Map one list item from GET /api/pdfs
  static PdfItem fromListJson(Map<String, dynamic> e) {
    return PdfItem(
      id: (e['id'] ?? '').toString(),
      title: (e['title'] ?? 'Untitled').toString(),
      description: (e['description'] ?? '').toString().isEmpty ? null : (e['description'] as String),
      fileKey: (e['file_key'] ?? '').toString(),
      updatedAt: (e['updated_at'] ?? '').toString().isEmpty ? null : (e['updated_at'] as String),
    );
  }

  /// Map envelope: { success, count, data: [ ... ] }
  static List<PdfItem> listFromApiEnvelope(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map(PdfItem.fromListJson)
          .toList(growable: false);
    }
    return const <PdfItem>[];
  }

  // ---------- DB mapping ----------

  factory PdfItem.fromDb(Map<String, Object?> map) {
    return PdfItem(
      idPk: map['id'] as int?,
      id: (map['serverId'] ?? '').toString(),
      title: (map['title'] ?? 'Untitled').toString(),
      description: (map['description'] ?? '').toString().isEmpty ? null : (map['description'] as String),
      fileKey: (map['fileKey'] ?? '').toString(),
      updatedAt: (map['updatedAt'] ?? '').toString().isEmpty ? null : (map['updatedAt'] as String),
      signedUrl: (map['signedUrl'] ?? '').toString().isEmpty ? null : (map['signedUrl'] as String),
      localPath: (map['localPath'] ?? '').toString().isEmpty ? null : (map['localPath'] as String),
      lastSyncedAt: (map['lastSyncedAt'] ?? '').toString().isEmpty ? null : (map['lastSyncedAt'] as String),
    );
  }

  Map<String, Object?> toDb() {
    return {
      if (idPk != null) 'id': idPk,
      'serverId': id,
      'title': title,
      'description': description ?? '',
      'fileKey': fileKey,
      'updatedAt': updatedAt ?? '',
      'signedUrl': signedUrl ?? '',
      'localPath': localPath ?? '',
      'lastSyncedAt': lastSyncedAt ?? '',
    };
  }
}

