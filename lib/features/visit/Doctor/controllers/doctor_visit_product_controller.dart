import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/http/http_client.dart';
import '../../../product/model/ProductModel.dart';
import '../repository/visit_cache_repository.dart';

class DoctorVisitProductController {
  DoctorVisitProductController({
    VisitCacheRepository? cacheRepository,
    Connectivity? connectivity,
    http.Client? client,
  })  : _cacheRepository = cacheRepository ?? VisitCacheRepository(),
        _connectivity = connectivity ?? Connectivity(),
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  static const String _cacheKey = 'doctor_visit_products';
  static const Duration _requestTimeout = Duration(seconds: 20);

  final VisitCacheRepository _cacheRepository;
  final Connectivity _connectivity;
  final http.Client _client;
  final bool _ownsClient;

  final RxBool isLoading = false.obs;
  final RxList<Product> productList = <Product>[].obs;

  bool _isRefreshing = false;
  bool _isDisposed = false;

  Future<void> loadProducts({bool refresh = true}) async {
    await _loadCachedProducts();

    if (refresh) {
      unawaited(refreshProducts());
    }
  }

  Future<bool> refreshProducts() async {
    if (_isRefreshing || _isDisposed) return false;

    try {
      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return false;
    } catch (error) {
      debugPrint(
        'DoctorVisitProductController: Connectivity check failed: $error',
      );
      return false;
    }

    _isRefreshing = true;
    if (productList.isEmpty) {
      isLoading.value = true;
    }

    try {
      final response = await _client
          .get(Uri.parse('${THttpHelper.baseUrl}/products'))
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'DoctorVisitProductController: Product refresh failed with '
          '${response.statusCode}. Using cached products.',
        );
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        debugPrint(
          'DoctorVisitProductController: Unexpected product response. '
          'Using cached products.',
        );
        return false;
      }

      final products = decoded
          .whereType<Map>()
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      productList.assignAll(products);
      await _cacheRepository.save(
        cacheKey: _cacheKey,
        json: jsonEncode(decoded),
      );

      debugPrint(
        'DoctorVisitProductController: Cached ${products.length} products.',
      );
      return true;
    } on TimeoutException {
      debugPrint(
        'DoctorVisitProductController: Product refresh timed out. '
        'Using cached products.',
      );
      return false;
    } on http.ClientException {
      debugPrint(
        'DoctorVisitProductController: Product API is unreachable. '
        'Using cached products.',
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint(
        'DoctorVisitProductController: Product refresh failed: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _isRefreshing = false;
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _loadCachedProducts() async {
    if (_isDisposed || productList.isNotEmpty) return;

    try {
      final cachedJson = await _cacheRepository.get(_cacheKey);
      if (cachedJson == null || cachedJson.isEmpty) return;

      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) return;

      productList.assignAll(
        decoded
            .whereType<Map>()
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item))),
      );

      debugPrint(
        'DoctorVisitProductController: Loaded '
        '${productList.length} cached products.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'DoctorVisitProductController: Could not read product cache: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void dispose() {
    _isDisposed = true;
    if (_ownsClient) {
      _client.close();
    }
  }
}
