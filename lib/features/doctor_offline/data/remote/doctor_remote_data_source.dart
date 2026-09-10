import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../../doctor_offline_exception.dart';
import '../../models/doctor_sync_models.dart';

abstract interface class DoctorAuthTokenProvider {
  Future<String?> readToken();
}

class AuthManagerDoctorAuthTokenProvider implements DoctorAuthTokenProvider {
  AuthManagerDoctorAuthTokenProvider({AuthManager? authManager})
      : _authManager = authManager ?? AuthManager();

  final AuthManager _authManager;

  @override
  Future<String?> readToken() => _authManager.getAuthToken();
}

abstract interface class DoctorRemoteDataSource {
  Future<BootstrapPage> fetchBootstrap({
    String? cursor,
    int limit = 500,
  });

  Future<DeltaPage> fetchDelta({
    required BigInt afterVersion,
    int limit = 500,
    String? headOfficeId,
  });

  Future<void> close();
}

class HttpDoctorRemoteDataSource implements DoctorRemoteDataSource {
  HttpDoctorRemoteDataSource({
    required DoctorAuthTokenProvider tokenProvider,
    http.Client? client,
    String baseUrl = THttpHelper.baseUrl,
    Duration timeout = const Duration(seconds: 25),
  })  : _tokenProvider = tokenProvider,
        _client = client ?? http.Client(),
        _ownsClient = client == null,
        _baseUri = Uri.parse(baseUrl),
        _timeout = timeout {
    if (_baseUri.scheme != 'https' || _baseUri.host.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Doctor sync requires a valid HTTPS base URL.',
      );
    }
  }

  final DoctorAuthTokenProvider _tokenProvider;
  final http.Client _client;
  final bool _ownsClient;
  final Uri _baseUri;
  final Duration _timeout;

  bool _closed = false;

  @override
  Future<BootstrapPage> fetchBootstrap({
    String? cursor,
    int limit = 500,
  }) async {
    if (limit < 1) {
      throw ArgumentError.value(limit, 'limit');
    }
    final query = <String, String>{'limit': '$limit'};
    if (cursor != null) {
      final normalizedCursor = cursor.trim();
      if (normalizedCursor.isEmpty) {
        throw ArgumentError.value(cursor, 'cursor');
      }
      query['cursor'] = normalizedCursor;
    }

    final json = await _get('/doctors/sync/bootstrap', query);
    try {
      final page = BootstrapPage.fromJson(json);
      if (!page.success) {
        throw const DoctorSyncProtocolException(
          'The bootstrap endpoint reported an unsuccessful response.',
        );
      }
      return page;
    } on DoctorOfflineException {
      rethrow;
    } on FormatException catch (error) {
      throw DoctorSyncProtocolException(
        'The bootstrap response did not match the required contract.',
        cause: error,
      );
    }
  }

  @override
  Future<DeltaPage> fetchDelta({
    required BigInt afterVersion,
    int limit = 500,
    String? headOfficeId,
  }) async {
    if (afterVersion.isNegative) {
      throw ArgumentError.value(afterVersion, 'afterVersion');
    }
    if (limit < 1 || limit > 1000) {
      throw ArgumentError.value(limit, 'limit');
    }
    final query = <String, String>{
      'afterVersion': afterVersion.toString(),
      'limit': '$limit',
    };
    final normalizedHeadOfficeId = headOfficeId?.trim();
    if (normalizedHeadOfficeId != null && normalizedHeadOfficeId.isNotEmpty) {
      query['headOfficeId'] = normalizedHeadOfficeId;
    }

    final json = await _get('/doctors/sync', query);
    try {
      final page = DeltaPage.fromJson(json);
      if (!page.success) {
        throw const DoctorSyncProtocolException(
          'The delta endpoint reported an unsuccessful response.',
        );
      }
      return page;
    } on DoctorOfflineException {
      rethrow;
    } on FormatException catch (error) {
      throw DoctorSyncProtocolException(
        'The delta response did not match the required contract.',
        cause: error,
      );
    }
  }

  Future<Map<String, dynamic>> _get(
    String endpoint,
    Map<String, String> query,
  ) async {
    if (_closed) {
      throw const DoctorRemoteException('The doctor remote service is closed.');
    }
    final token = (await _tokenProvider.readToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const DoctorAuthenticationException(
        'A valid signed-in session is required.',
      );
    }

    final uri = _buildUri(endpoint, query);
    http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);
    } on TimeoutException catch (error) {
      throw DoctorRemoteException(
        'The doctor sync request timed out.',
        cause: error,
        statusCode: 408,
      );
    } on http.ClientException catch (error) {
      throw DoctorRemoteException(
        'The doctor sync service could not be reached.',
        cause: error,
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw DoctorAuthenticationException(
        response.statusCode == 401
            ? 'Your session has expired. Please sign in again.'
            : 'This account is not authorized to sync doctors.',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DoctorRemoteException(
        _httpErrorMessage(response.statusCode),
        statusCode: response.statusCode,
        retryAfter: _parseRetryAfter(response.headers['retry-after']),
      );
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const FormatException('The response root must be an object.');
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException catch (error) {
      throw DoctorSyncProtocolException(
        'The doctor sync service returned invalid JSON.',
        cause: error,
      );
    }
  }

  Uri _buildUri(String endpoint, Map<String, String> query) {
    final basePath = _baseUri.path.replaceFirst(RegExp(r'/+$'), '');
    final endpointPath = endpoint.replaceFirst(RegExp(r'^/+'), '');
    final includesApiPrefix = basePath == '/api' || basePath.endsWith('/api');
    final apiPath = includesApiPrefix ? basePath : '$basePath/api';
    return _baseUri.replace(
      path: '$apiPath/$endpointPath'.replaceAll(RegExp(r'/+'), '/'),
      queryParameters: query,
      fragment: '',
    );
  }

  String _httpErrorMessage(int statusCode) {
    if (statusCode == 408) return 'The doctor sync request timed out.';
    if (statusCode == 409 || statusCode == 410) {
      return 'The saved doctor sync cursor is no longer accepted.';
    }
    if (statusCode == 429) {
      return 'Doctor sync is temporarily rate limited.';
    }
    if (statusCode >= 500) {
      return 'The doctor sync service is temporarily unavailable.';
    }
    return 'Doctor sync failed with HTTP status $statusCode.';
  }

  Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    if (_ownsClient) _client.close();
  }
}
