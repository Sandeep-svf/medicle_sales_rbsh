/*
// lib/data/services/pdf_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/http/http_client.dart';
import '../model/PdfItem.dart';


class PdfService {
  final Dio _dio;

  PdfService([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Fetch list from GET /pdfs
  /// Expected items: { title, fileKey, updatedAt? }
*/
/*  Future<List<PdfItem>> fetchList() async {
    final resp = await _dio.get("${THttpHelper.baseUrl}/pdfs");
    final data = resp.data;
    if (resp.statusCode == 200 && data is List) {
      return data.map<PdfItem>((item) {
        final title = (item['title'] ?? 'Untitled').toString();
        final fileKey = (item['fileKey'] ?? '').toString();
        final updatedAt = item['updatedAt']?.toString(); // may be null if backend not sending yet
        return PdfItem(title: title, fileKey: fileKey, updatedAt: updatedAt);
      }).toList();
    }
    return [];
  }*//*


  Future<List<PdfItem>> fetchList() async {
    try {
      final resp = await _dio.get("${THttpHelper.baseUrl}/pdfs");
      final data = resp.data;

      // Check for success status and if the "data" field exists
      if (resp.statusCode == 200 && data != null && data['data'] is List) {
        // Extract the 'data' list from the response
        final pdfList = data['data'] as List;

        // Map the list to PdfItem models
        return pdfList.map<PdfItem>((item) {
          final title = (item['title'] ?? 'Untitled').toString();
          final fileKey = (item['file_key'] ?? '').toString(); // Updated to match new field name
          final updatedAt = item['updated_at']?.toString();  // Updated field name

          // Return the PdfItem model
          return PdfItem(
            title: title,
            fileKey: fileKey,
            updatedAt: updatedAt,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching PDF list: $e");
      return [];
    }
  }


  /// Get a signed URL for a fileKey
  Future<String?> fetchSignedUrl(String fileKey) async {
    final url = "${THttpHelper.baseUrl}/pdfs/signed-url/$fileKey";
   // print("pdf fetchsignurl: ${THttpHelper.baseUrl}/pdfs/signed-url/$fileKey}");
    final resp = await _dio.get(url);
    if (resp.statusCode == 200 && resp.data["fileUrl"] != null) {
      return resp.data["fileUrl"] as String;
    }
    return null;
  }

  /// Download a URL to app docs dir /pdf_cache/<filename>
  /// Returns the absolute local path
  Future<String> downloadPdf(String signedUrl, String fileKey) async {
    final docs = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(join(docs.path, 'pdf_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final filename = fileKey.split('/').last;
    final filePath = join(cacheDir.path, filename);

    final resp = await _dio.get<List<int>>(
      signedUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final file = File(filePath);
    await file.writeAsBytes(resp.data!, flush: true);
    return filePath;
  }
}
*/

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../utils/http/http_client.dart';
import '../model/PdfItem.dart';

class PdfService {
  final Dio _dio;

  PdfService([Dio? dio])
      : _dio = dio ?? Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<List<PdfItem>> fetchList() async {
    final url = "${THttpHelper.baseUrl}/pdfs";
    print("PdfService fetchList → GET $url");
    try {
      final resp = await _dio.get(url);
      final body = resp.data;
      if (resp.statusCode == 200 && body is Map) {
        final map = Map<String, dynamic>.from(body as Map);
        final list = PdfItem.listFromApiEnvelope(map);
        print("PdfService fetchList OK: ${list.length} items");
        return list;
      }
      print("PdfService fetchList WARN: unexpected response");
      return const <PdfItem>[];
    } catch (e, st) {
      print("PdfService fetchList ERROR: $e");
      print("PdfService fetchList STACK: $st");
      return const <PdfItem>[];
    }
  }

  Future<String?> fetchSignedUrlById(String id) async {
    final url = "${THttpHelper.baseUrl}/pdfs/$id/signed-url";
    print("PdfService fetchSignedUrlById → GET $url");
    try {
      final resp = await _dio.get(url);
      if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
        final data = resp.data['data'];
        if (data is Map<String, dynamic>) {
          final s = data['signedUrl']?.toString();
          print("PdfService fetchSignedUrlById OK: ${s != null}");
          return (s == null || s.isEmpty) ? null : s;
        }
      }
      print("PdfService fetchSignedUrlById WARN: unexpected response");
      return null;
    } catch (e, st) {
      print("PdfService fetchSignedUrlById ERROR: $e");
      print("PdfService fetchSignedUrlById STACK: $st");
      return null;
    }
  }

  Future<String> downloadPdf(
      String signedUrl, {
        String? preferredFileName,
      }) async {
    print("PdfService downloadPdf → $signedUrl");
    final docs = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(docs.path, 'pdf_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final fileName = (preferredFileName == null || preferredFileName.trim().isEmpty)
        ? Uri.parse(signedUrl).pathSegments.last
        : preferredFileName;
    final filePath = p.join(cacheDir.path, fileName);

    final resp = await _dio.get<List<int>>(
      signedUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final file = File(filePath);
    await file.writeAsBytes(resp.data ?? const <int>[], flush: true);
    print("PdfService downloadPdf OK: $filePath");
    return filePath;
  }
}

