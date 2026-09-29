import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_request_loader.dart';

export 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;

Future<http.Response> get(
  Uri url, {
  Map<String, String>? headers,
}) =>
    ApiRequestLoader.track(() => http.get(url, headers: headers));

Future<http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) =>
    ApiRequestLoader.track(
      () => http.post(url, headers: headers, body: body, encoding: encoding),
    );

Future<http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) =>
    ApiRequestLoader.track(
      () => http.put(url, headers: headers, body: body, encoding: encoding),
    );

Future<http.Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) =>
    ApiRequestLoader.track(
      () => http.patch(url, headers: headers, body: body, encoding: encoding),
    );

Future<http.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) =>
    ApiRequestLoader.track(
      () => http.delete(url, headers: headers, body: body, encoding: encoding),
    );

Future<http.Response> head(
  Uri url, {
  Map<String, String>? headers,
}) =>
    ApiRequestLoader.track(() => http.head(url, headers: headers));

Future<String> read(
  Uri url, {
  Map<String, String>? headers,
}) =>
    ApiRequestLoader.track(() => http.read(url, headers: headers));

Future<Uint8List> readBytes(
  Uri url, {
  Map<String, String>? headers,
}) =>
    ApiRequestLoader.track(() => http.readBytes(url, headers: headers));

Future<T> runWithClient<T>(
  Future<T> Function() body,
  http.Client Function() clientFactory,
) =>
    ApiRequestLoader.track(
      () => http.runWithClient(body, clientFactory),
    );

final _trackedRequestClient = TrackedClient();

Future<http.StreamedResponse> send(http.BaseRequest request) =>
    _trackedRequestClient.send(request);

/// A package:http client that keeps the shared loader visible until the body
/// has been consumed (or the stream has been cancelled).
class TrackedClient extends http.BaseClient {
  TrackedClient({http.Client? client, this.trackActivity = true})
      : _client = client ?? http.Client();

  final http.Client _client;
  final bool trackActivity;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!trackActivity) return _client.send(request);
    ApiRequestLoader.begin();
    try {
      final response = await _client.send(request);
      var isComplete = false;
      void completeOnce() {
        if (isComplete) return;
        isComplete = true;
        ApiRequestLoader.complete();
      }

      final stream = Stream<List<int>>.multi((controller) {
        final subscription = response.stream.listen(
          controller.add,
          onError: (Object error, StackTrace stackTrace) {
            controller.addError(error, stackTrace);
          },
          onDone: () {
            controller.close();
            completeOnce();
          },
        );
        controller
          ..onPause = subscription.pause
          ..onResume = subscription.resume
          ..onCancel = () async {
            await subscription.cancel();
            completeOnce();
          };
      });

      return http.StreamedResponse(
        stream,
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (_) {
      ApiRequestLoader.complete();
      rethrow;
    }
  }

  @override
  void close() => _client.close();
}
