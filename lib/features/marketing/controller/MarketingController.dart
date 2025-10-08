/*
// lib/controllers/marketing_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../model/PdfItem.dart';
import '../pdfDB/pdfDB.dart';
import '../service/PdfService.dart';

class MarketingController extends GetxController {
  static const _prefGridKey = "view_mode_grid";
  static const _prefOfflineKey = "view_mode_offline";

  final PdfService _service;

  MarketingController({PdfService? service}) : _service = service ?? PdfService();

  // UI state (reactive)
  final isLoading = false.obs;
  final isGridView = false.obs;
  // default = false => Online first (unless user previously saved Offline)
  final isOfflineMode = false.obs;

  // Data (reactive)
  final onlineItems = <PdfItem>[].obs;   // server list
  final offlineItems = <PdfItem>[].obs;  // SQLite list

  @override
  void onInit() {
    super.onInit();
    _restorePrefs().then((_) => load());
  }

  Future<void> _restorePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isGridView.value = prefs.getBool(_prefGridKey) ?? false;
    isOfflineMode.value = prefs.getBool(_prefOfflineKey) ?? false; // default Online
  }

  Future<void> _saveGrid(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefGridKey, v);
  }

  Future<void> _saveOffline(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOfflineKey, v);
  }

  void toggleGrid() {
    final v = !isGridView.value;
    isGridView.value = v;
    _saveGrid(v);
  }

  Future<void> setOffline(bool v) async {
    isOfflineMode.value = v;
    await _saveOffline(v);
    await load();
  }

  /// Network availability: connectivity + DNS lookup
  Future<bool> isOnline() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) return false;
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      if (isOfflineMode.value) {
        await _loadFromDb();
      } else {
        // If no internet in Online mode, keep items (could be 0) but don't crash
        if (!await isOnline()) {
          onlineItems.clear();
          isLoading.value = false;
          return;
        }
        await _loadFromOnline();
        // Seed/update offline cache in background
        _backgroundSyncToDbAndFiles();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromDb() async {
    final list = await PdfDb.getAll();
    debugPrint("[DB] loaded ${list.length} items");
    offlineItems.assignAll(list);
  }

  Future<void> _loadFromOnline() async {
    final list = await _service.fetchList();
    debugPrint("[API] fetched ${list.length} items");
    onlineItems.assignAll(list);
  }

  // Helper: check if we already have a cached local file for a fileKey
  Future<String?> getCachedLocalPath(String fileKey) async {
    final existing = await PdfDb.getByFileKey(fileKey);
    final p = existing?.localPath;
    if (p != null && File(p).existsSync()) return p;
    return null;
  }

  /// Public wrappers so UI never touches the private service.
  Future<String?> getSignedUrl(String fileKey) => _service.fetchSignedUrl(fileKey);
  Future<String> downloadToCache(String signedUrl, String fileKey) =>
      _service.downloadPdf(signedUrl, fileKey);

  /// "Refresh PDFs" → re-fetch list, re-download newer/missing, upsert DB.
  Future<void> refreshPdfs(BuildContext context) async {
    isLoading.value = true;
    String message = "Offline copies refreshed";
    try {
      if (!await isOnline()) {
        message = "Internet not available. Showing saved PDFs.";
        await _loadFromDb();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final list = await _service.fetchList();
      if (list.isEmpty) {
        message = "No files from server. Showing saved PDFs.";
        await _loadFromDb();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        return;
      }
      onlineItems.assignAll(list);
      await _syncLoop(list);
      if (isOfflineMode.value) {
        await _loadFromDb();
      }
    } catch (_) {
      message = "Refresh failed. Showing saved PDFs.";
    } finally {
      isLoading.value = false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _backgroundSyncToDbAndFiles() async {
    final list = onlineItems.toList();
    if (list.isEmpty) return;
    await _syncLoop(list);
  }

  /// Compare server updatedAt vs DB; (re)download as needed and upsert
  Future<void> _syncLoop(List<PdfItem> list) async {
    for (final item in list) {
      if (item.fileKey.isEmpty) continue;

      final existing = await PdfDb.getByFileKey(item.fileKey);
      final serverUpdated = item.updatedAt ?? "";

      bool needsDownload = false;
      if (existing == null) {
        needsDownload = true;
      } else {
        final localUpdated = existing.updatedAt ?? "";
        if (serverUpdated.isNotEmpty && serverUpdated != localUpdated) {
          needsDownload = true;
        }
        if (!needsDownload &&
            (existing.localPath == null || !(File(existing.localPath!).existsSync()))) {
          needsDownload = true;
        }
      }

      if (!needsDownload) continue;

      // Fetch fresh signed URL using your service logic
      final signedUrl = await _service.fetchSignedUrl(item.fileKey);
      print("pdf signedUrl: ${signedUrl}");
      if (signedUrl == null) continue;

      try {
        final localPath = await _service.downloadPdf(signedUrl, item.fileKey);
        final toSave = PdfItem(
          title: item.title,
          fileKey: item.fileKey,
          finalUrl: signedUrl,        // exact final URL used
          updatedAt: item.updatedAt,  // server "updated date"
          localPath: localPath,       // absolute local path
          lastSyncedAt: DateTime.now().toIso8601String(),
        );
        await PdfDb.upsert(toSave);
      } catch (_) {
        // skip this file, continue others
      }
    }
  }
}
*/


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../model/PdfItem.dart';
import '../pdfDB/pdfDB.dart';
import '../service/PdfService.dart';

class MarketingController extends GetxController {
  static const _prefGridKey = "view_mode_grid";
  static const _prefOfflineKey = "view_mode_offline";

  final PdfService _service;

  MarketingController({PdfService? service}) : _service = service ?? PdfService();

  final isLoading = false.obs;
  final isGridView = false.obs;
  final isOfflineMode = false.obs;

  final onlineItems = <PdfItem>[].obs;
  final offlineItems = <PdfItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _restorePrefs().then((_) => load());
  }

  Future<void> _restorePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isGridView.value = prefs.getBool(_prefGridKey) ?? false;
    isOfflineMode.value = prefs.getBool(_prefOfflineKey) ?? false;
  }

  Future<void> _saveGrid(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefGridKey, v);
  }

  Future<void> _saveOffline(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOfflineKey, v);
  }

  void toggleGrid() {
    final v = !isGridView.value;
    isGridView.value = v;
    _saveGrid(v);
  }

  Future<void> setOffline(bool v) async {
    isOfflineMode.value = v;
    await _saveOffline(v);
    await load();
  }

  Future<bool> isOnline() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) return false;
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      if (isOfflineMode.value) {
        await _loadFromDb();
      } else {
        if (!await isOnline()) {
          onlineItems.clear();
          isLoading.value = false;
          return;
        }
        await _loadFromOnline();
        _backgroundSyncToDbAndFiles();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromDb() async {
    final list = await PdfDb.getAll();
    debugPrint("MarketingController _loadFromDb: ${list.length} items");
    offlineItems.assignAll(list);
  }

  Future<void> _loadFromOnline() async {
    final list = await _service.fetchList();
    debugPrint("MarketingController _loadFromOnline: ${list.length} items");
    onlineItems.assignAll(list);
  }

  Future<String?> getCachedLocalPathByFileKey(String fileKey) async {
    final existing = await PdfDb.getByFileKey(fileKey);
    final p = existing?.localPath;
    if (p != null && File(p).existsSync()) return p;
    return null;
  }

  Future<String?> getSignedUrlById(String id) => _service.fetchSignedUrlById(id);

  Future<String> downloadToCache({
    required String signedUrl,
    required String filename,
  }) {
    return _service.downloadPdf(signedUrl, preferredFileName: filename);
  }

  /// Background sync: for each online item, see if we need to download.
  Future<void> _backgroundSyncToDbAndFiles() async {
    final list = onlineItems.toList();
    for (final item in list) {
      // Use fileKey as uniqueness in DB; get existing cache state
      final existing = await PdfDb.getByFileKey(item.fileKey);
      final serverUpdated = item.updatedAt ?? "";
      final needsDownload = existing == null ||
          (existing.updatedAt ?? "") != serverUpdated ||
          existing.localPath == null ||
          !File(existing.localPath!).existsSync();

      if (!needsDownload) continue;

      final signed = await getSignedUrlById(item.id);
      if (signed == null || signed.isEmpty) continue;

      final safeName = (item.title.isNotEmpty ? item.title : item.fileKey)
          .replaceAll(RegExp(r'[\\/:"*?<>|]+'), '_');
      try {
        final localPath = await downloadToCache(
          signedUrl: signed,
          filename: "$safeName.pdf",
        );
        final toSave = item.copyWith(
          signedUrl: signed,
          localPath: localPath,
          lastSyncedAt: DateTime.now().toIso8601String(),
        );
        await PdfDb.upsert(toSave);
      } catch (_) {
        // skip errors, continue other files
      }
    }
  }

  /// Save/refresh a single item after user taps & we download
  Future<void> saveDownloaded(PdfItem item, String signedUrl, String localPath) async {
    final toSave = item.copyWith(
      signedUrl: signedUrl,
      localPath: localPath,
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
    await PdfDb.upsert(toSave);
  }
}
