import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'bindings/doctor_offline_binding.dart';
import 'controllers/doctor_offline_controller.dart';
import 'data/local/doctor_encryption_key_provider.dart';
import 'data/local/doctor_local_data_source.dart';
import 'data/local/hive_encrypted_doctor_local_data_source.dart';
import 'data/remote/doctor_remote_data_source.dart';
import 'doctor_offline_exception.dart';
import 'models/doctor_scope.dart';
import 'repositories/doctor_repository.dart';
import 'repositories/doctor_repository_impl.dart';
import 'services/doctor_connectivity_monitor.dart';
import 'sync/doctor_sync_coordinator.dart';
import 'ui/doctor_offline_screen.dart';

class DoctorOfflineModule {
  DoctorOfflineModule._({
    required this.scope,
    required this.namespace,
    required this.repository,
    required this.syncCoordinator,
    required this.controller,
  });

  static final Set<String> _openNamespaces = <String>{};

  final DoctorOfflineScope scope;
  final String namespace;
  final DoctorRepository repository;
  final DoctorSyncCoordinator syncCoordinator;
  final DoctorOfflineController controller;

  bool _disposed = false;

  String get getXTag => 'doctor_offline_$namespace';

  DoctorOfflineBinding get binding {
    return DoctorOfflineBinding(controller: controller, tag: getXTag);
  }

  Widget screen({Key? key}) {
    return DoctorOfflineScreen(key: key, controller: controller);
  }

  static Future<DoctorOfflineModule> initialize({
    required String accountId,
    String? authorizedScopeId,
    String? deltaHeadOfficeId,
    String? environment,
    String baseUrl = THttpHelper.baseUrl,
    AuthManager? authManager,
    DoctorAuthTokenProvider? tokenProvider,
    DoctorEncryptionKeyProvider? encryptionKeyProvider,
    FlutterSecureStorage? secureStorage,
    Connectivity? connectivity,
    http.Client? httpClient,
    String? supportDirectoryPath,
    DoctorSyncLog? syncLog,
  }) async {
    final parsedBaseUri = Uri.parse(baseUrl);
    if (parsedBaseUri.scheme != 'https' || parsedBaseUri.host.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Doctor sync requires a valid HTTPS base URL.',
      );
    }
    final scope = DoctorOfflineScope(
      environment: environment ?? _normalizedEnvironment(parsedBaseUri),
      accountId: accountId,
      authorizedScopeId: authorizedScopeId,
    );
    final namespace = await scope.storageNamespace();
    if (!_openNamespaces.add(namespace)) {
      throw const DoctorStorageException(
        'This doctor cache scope is already open.',
      );
    }

    DoctorRepository? repository;
    DoctorLocalDataSource? localDataSource;
    DoctorRemoteDataSource? remoteDataSource;
    DoctorSyncCoordinator? coordinator;
    DoctorOfflineController? controller;
    try {
      final rootPath =
          supportDirectoryPath ?? (await getApplicationSupportDirectory()).path;
      final storagePath = path.join(
        rootPath,
        'doctor_offline',
        namespace,
      );
      final keyProvider = encryptionKeyProvider ??
          SecureStorageDoctorEncryptionKeyProvider(
            namespace: namespace,
            secureStorage: secureStorage,
          );
      final encryptionKey = await keyProvider.loadOrCreateKey(
        encryptedStoreExists:
            HiveEncryptedDoctorLocalDataSource.storeFilesExist(storagePath),
      );
      localDataSource = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: encryptionKey,
      );
      final authentication = authManager ?? AuthManager();
      remoteDataSource = HttpDoctorRemoteDataSource(
        tokenProvider: tokenProvider ??
            AuthManagerDoctorAuthTokenProvider(authManager: authentication),
        client: httpClient,
        baseUrl: baseUrl,
      );
      repository = DoctorRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
      coordinator = DoctorSyncCoordinator(
        repository: repository,
        deltaHeadOfficeId: deltaHeadOfficeId,
        scopeGuard: () async {
          final currentAccountId = await authentication.getUserId();
          return currentAccountId == accountId;
        },
        log: syncLog,
      );
      controller = DoctorOfflineController(
        repository: repository,
        syncCoordinator: coordinator,
        connectivityMonitor: ConnectivityPlusDoctorConnectivityMonitor(
          connectivity: connectivity,
        ),
      );
      final module = DoctorOfflineModule._(
        scope: scope,
        namespace: namespace,
        repository: repository,
        syncCoordinator: coordinator,
        controller: controller,
      );
      await controller.initialize();
      return module;
    } catch (error, stackTrace) {
      await controller?.shutdown();
      await coordinator?.dispose();
      try {
        if (repository != null) {
          await repository.close();
        } else {
          await remoteDataSource?.close();
          await localDataSource?.close();
        }
      } catch (_) {}
      _openNamespaces.remove(namespace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await controller.shutdown();
    await syncCoordinator.dispose();
    await repository.close();
    _openNamespaces.remove(namespace);
  }

  static String _normalizedEnvironment(Uri baseUri) {
    final port = baseUri.hasPort ? ':${baseUri.port}' : '';
    final normalizedPath = baseUri.path.replaceFirst(RegExp(r'/+$'), '');
    return '${baseUri.scheme.toLowerCase()}://'
        '${baseUri.host.toLowerCase()}$port$normalizedPath';
  }
}
