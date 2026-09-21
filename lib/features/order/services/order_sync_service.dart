import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/order_models.dart';
import '../repositories/order_repository.dart';

abstract interface class OrderRemoteDataSource {
  Future<void> send(LocalOrder order);
}

/// No order API contract has been supplied. Enable only after implementing the
/// acknowledgement described in features/order/README.md on the backend.
class HttpOrderRemoteDataSource implements OrderRemoteDataSource {
  HttpOrderRemoteDataSource(
      {http.Client? client,
      String? endpoint,
      Future<String?> Function()? tokenProvider})
      : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _endpoint =
            endpoint ?? const String.fromEnvironment('ORDER_CREATE_URL'),
        _tokenProvider = tokenProvider ?? AuthManager().getAuthToken;
  final http.Client _client;
  final bool _ownsClient;
  final String _endpoint;
  final Future<String?> Function() _tokenProvider;
  bool get isConfigured => _endpoint.isNotEmpty;

  @override
  Future<void> send(LocalOrder order) async {
    if (!isConfigured)
      throw const OrderSyncException(
          'Order upload is not available yet. Your order is saved on this device.');
    final uri = Uri.parse(_endpoint);
    if (uri.scheme != 'https' || uri.host.isEmpty)
      throw const OrderSyncException('The order service address is invalid.');
    final token = await _tokenProvider();
    if (token == null || token.isEmpty)
      throw const OrderSyncException('Sign in again to upload your orders.');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..headers['Idempotency-Key'] = order.clientGeneratedId
      ..fields.addAll({
        'clientGeneratedId': order.clientGeneratedId,
        'doctorId': order.doctorId ?? '',
        'doctorName': order.doctorName,
        'customerType': order.customerType,
        'contactPhone': order.contactPhone ?? '',
        'clinicName': order.clinicName ?? '',
        'specialization': order.specialization ?? '',
        'area': order.area ?? '',
        'headOffice': order.headOffice ?? '',
        'deliveryAddress': order.deliveryAddress ?? '',
        'notes': order.notes ?? '',
        'stockistName': order.stockistName ?? '',
        'purchaseOrderReference': order.purchaseOrderReference ?? '',
        'priority': order.priority,
        'paymentTerms': order.paymentTerms,
        if (order.creditDays != null) 'creditDays': '${order.creditDays}',
        if (order.requestedDeliveryDate != null)
          'requestedDeliveryDate':
              order.requestedDeliveryDate!.toIso8601String(),
        'orderDate': order.orderDate.toUtc().toIso8601String(),
        'currency': 'INR',
        'items': jsonEncode(order.items.map((item) => item.toJson()).toList()),
      });
    request.files.add(await http.MultipartFile.fromPath(
        'attachment', order.attachmentPath,
        filename: order.attachmentName,
        contentType: MediaType.parse(order.attachmentMime)));
    final response = await _client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 60));
    if (response.statusCode != 200 && response.statusCode != 201)
      throw OrderSyncException(
          'Upload was not confirmed (${response.statusCode}). Your order is retained.');
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const OrderSyncException(
          'The server did not confirm this order. Please retry later.');
    }
    if (decoded is! Map ||
        decoded['success'] != true ||
        decoded['data'] is! Map)
      throw const OrderSyncException(
          'The server did not confirm this order. Please retry later.');
    final data = decoded['data'] as Map;
    if (data['clientGeneratedId'] != order.clientGeneratedId ||
        data['id'] is! String ||
        (data['id'] as String).isEmpty ||
        data['attachmentAccepted'] != true) {
      throw const OrderSyncException(
          'Waiting for confirmation of the order and attachment.');
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}

class OrderSyncResult {
  const OrderSyncResult(
      {this.sent = 0,
      this.failed = 0,
      this.offline = false,
      this.unavailable = false});
  final int sent, failed;
  final bool offline, unavailable;
  String get message => unavailable
      ? 'Order upload is not available yet. Your orders remain saved on this device.'
      : offline
          ? 'You are offline. Orders remain saved for upload.'
          : failed > 0
              ? '$sent uploaded · $failed retained for retry.'
              : sent > 0
                  ? '$sent order(s) uploaded and removed from this device.'
                  : 'No orders are waiting to upload.';
}

class OrderSyncService {
  OrderSyncService(
      {required this.repository,
      required this.remote,
      Connectivity? connectivity,
      this.onChanged,
      Future<bool> Function()? isOnline})
      : _connectivity = connectivity ?? Connectivity(),
        _isOnline = isOnline;
  final OrderRepository repository;
  final OrderRemoteDataSource remote;
  final Connectivity _connectivity;
  final Future<bool> Function()? _isOnline;
  final Future<void> Function()? onChanged;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Future<OrderSyncResult>? _inFlight;
  bool _disposed = false;
  bool get isRunning => _inFlight != null;
  void startListening() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none) && !_disposed)
        unawaited(syncPending());
    });
  }

  Future<OrderSyncResult> syncPending() {
    if (_disposed) return Future.value(const OrderSyncResult());
    return _inFlight ??= _run().whenComplete(() => _inFlight = null);
  }

  Future<OrderSyncResult> _run() async {
    if (remote is HttpOrderRemoteDataSource &&
        !(remote as HttpOrderRemoteDataSource).isConfigured)
      return const OrderSyncResult(unavailable: true);
    try {
      final online = await (_isOnline?.call() ??
          _connectivity
              .checkConnectivity()
              .then((r) => !r.contains(ConnectivityResult.none)));
      if (!online) return const OrderSyncResult(offline: true);
    } catch (_) {
      return const OrderSyncResult(offline: true);
    }
    var sent = 0, failed = 0;
    var cursor = '';
    while (!_disposed) {
      final batch = await repository.pendingOrders(limit: 10, afterId: cursor);
      if (batch.isEmpty) break;
      for (final order in batch) {
        if (_disposed) break;
        cursor = order.localId;
        try {
          await repository.markSyncing(order.localId);
          await onChanged?.call();
          await remote.send(order);
          await repository.deleteLocal(order.localId,
              attachmentPath: order.attachmentPath);
          sent++;
        } catch (error) {
          await repository.markFailed(
              order.localId,
              error is OrderSyncException
                  ? error.message
                  : 'Upload interrupted. Your order is saved for retry.');
          failed++;
        }
        if (!_disposed) await onChanged?.call();
      }
    }
    return OrderSyncResult(sent: sent, failed: failed);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    await _inFlight;
    if (remote is HttpOrderRemoteDataSource)
      (remote as HttpOrderRemoteDataSource).close();
  }
}

class OrderSyncException implements Exception {
  const OrderSyncException(this.message);
  final String message;
  @override
  String toString() => message;
}
