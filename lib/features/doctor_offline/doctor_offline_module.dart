import 'dart:async';
import 'services/doctor_creation_store.dart';

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
  static final Map<String, DoctorOfflineModule> _sharedModules =
      <String, DoctorOfflineModule>{};
  static final Map<String, Future<DoctorOfflineModule>> _initializations =
      <String, Future<DoctorOfflineModule>>{};

  final DoctorOfflineScope scope;
  final String namespace;
  final DoctorRepository repository;
  final DoctorSyncCoordinator syncCoordinator;
  final DoctorOfflineController controller;

  bool _disposed = false;
  int _leaseCount = 1;

  String get getXTag => 'doctor_offline_$namespace';

  DoctorOfflineBinding get binding {
    return DoctorOfflineBinding(controller: controller, tag: getXTag);
  }

  Widget screen({Key? key}) {
    return DoctorOfflineScreen(key: key, controller: controller);
  }

  /// Returns one shared, account-scoped module. Schedule and visit upload
  /// flows use this so they can share the encrypted doctor cache and creation
  /// outbox with the Offline Doctors screen instead of opening a second
  /// database handle.
  static Future<DoctorOfflineModule> acquire({
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
    final scope = DoctorOfflineScope(
      environment: environment ?? _normalizedEnvironment(parsedBaseUri),
      accountId: accountId,
      authorizedScopeId: authorizedScopeId,
    );
    final namespace = await scope.storageNamespace();
    final existing = _sharedModules[namespace];
    if (existing != null && !existing._disposed) {
      existing._leaseCount++;
      return existing;
    }

    final initializing = _initializations[namespace];
    if (initializing != null) {
      final module = await initializing;
      module._leaseCount++;
      return module;
    }

    final future = initialize(
      accountId: accountId,
      authorizedScopeId: authorizedScopeId,
      deltaHeadOfficeId: deltaHeadOfficeId,
      environment: environment,
      baseUrl: baseUrl,
      authManager: authManager,
      tokenProvider: tokenProvider,
      encryptionKeyProvider: encryptionKeyProvider,
      secureStorage: secureStorage,
      connectivity: connectivity,
      httpClient: httpClient,
      supportDirectoryPath: supportDirectoryPath,
      syncLog: syncLog,
    );
    _initializations[namespace] = future;
    try {
      final module = await future;
      _sharedModules[namespace] = module;
      return module;
    } finally {
      if (identical(_initializations[namespace], future)) {
        _initializations.remove(namespace);
      }
    }
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
    DoctorCreationStore? creationStore;
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
      creationStore = DoctorCreationStore(
        database: await DoctorCreationStore.openDatabaseAt(storagePath),
        directory: storagePath,
        encryptionKey: encryptionKey,
        baseUrl: baseUrl,
        tokenProvider: tokenProvider?.readToken ?? authentication.getAuthToken,
        scopeGuard: () async => await authentication.getUserId() == accountId,
      );
      controller = DoctorOfflineController(
        accountId: accountId,
        creationStore: creationStore,
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
      if (controller != null) {
        await controller.shutdown();
      } else {
        await creationStore?.close();
      }
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
    final shared = _sharedModules[namespace];
    if (identical(shared, this)) {
      _leaseCount--;
      if (_leaseCount > 0) return;
      _sharedModules.remove(namespace);
    }
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
