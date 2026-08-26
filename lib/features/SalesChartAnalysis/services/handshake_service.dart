import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../utils/http/http_client.dart';
import '../model/handshake_available_user.dart';

class HandshakeService {
  const HandshakeService();

  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<List<HandshakeAvailableUser>> fetchAvailableUsers({
    required DateTime date,
  }) async {
    final formattedDate = formatApiDate(date);
    final endpoint =
        'tour-plans/users/availability?date=${Uri.encodeQueryComponent(formattedDate)}';

    debugPrint('[HandshakeService] GET ${THttpHelper.baseUrl}/$endpoint');

    final response = await THttpHelper.authGet(endpoint).timeout(
      _requestTimeout,
    );

    if (response['success'] == false) {
      throw HandshakeServiceException(
        (response['message'] ?? 'Unable to load available users.').toString(),
      );
    }

    final responseData = response['data'];
    if (responseData is! List) {
      throw const HandshakeServiceException(
        'Invalid available-user response received.',
      );
    }

    final usersById = <String, HandshakeAvailableUser>{};

    for (final responseItem in responseData) {
      if (responseItem is! Map) continue;

      final user = HandshakeAvailableUser.fromJson(
        Map<String, dynamic>.from(responseItem),
      );

      if (user.id.isNotEmpty && user.available) {
        usersById[user.id] = user;
      }
    }

    final users = usersById.values.toList(growable: false)
      ..sort(
        (firstUser, secondUser) => firstUser.displayName
            .toLowerCase()
            .compareTo(secondUser.displayName.toLowerCase()),
      );

    debugPrint(
      '[HandshakeService] Available users for $formattedDate: ${users.length}',
    );

    return users;
  }

  Future<HandshakeSubmissionResult> sendRequest({
    required String dayId,
    required Iterable<String> userIds,
    required String notes,
  }) async {
    final normalizedDayId = dayId.trim();
    final normalizedUserIds = userIds
        .map((userId) => userId.trim())
        .where((userId) => userId.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedDayId.isEmpty) {
      throw const HandshakeServiceException(
        'Current tour-plan day is unavailable.',
      );
    }

    if (normalizedUserIds.isEmpty) {
      throw const HandshakeServiceException(
        'Please select at least one user.',
      );
    }

    final endpoint =
        'tour-plans/day/${Uri.encodeComponent(normalizedDayId)}/collaboration';
    final payload = <String, dynamic>{
      'joint_work_user_ids': normalizedUserIds,
      'notes': notes.trim(),
    };

    debugPrint('[HandshakeService] POST ${THttpHelper.baseUrl}/$endpoint');
    debugPrint(
      '[HandshakeService] Sending ${normalizedUserIds.length} selected user(s).',
    );

    final response = await THttpHelper.authPost(endpoint, payload).timeout(
      _requestTimeout,
    );

    if (response['success'] == false) {
      throw HandshakeServiceException(
        (response['message'] ?? 'Unable to send handshake request.').toString(),
      );
    }

    final responseData = response['data'];

    return HandshakeSubmissionResult(
      success: true,
      message: (response['message'] ?? 'Handshake request sent successfully.')
          .toString(),
      data: responseData is Map
          ? Map<String, dynamic>.from(responseData)
          : const <String, dynamic>{},
    );
  }

  static DateTime resolveAvailabilityDate(String? dashboardDate) {
    final parsedDate = DateTime.tryParse(dashboardDate?.trim() ?? '');
    final selectedDate = parsedDate ?? DateTime.now();

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
  }

  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String errorMessage(Object error) {
    if (error is HandshakeServiceException) return error.message;
    if (error is ApiException) return error.message;
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (error is SocketException || error is http.ClientException) {
      return 'Internet connection is unavailable.';
    }

    return 'Something went wrong. Please try again.';
  }
}

class HandshakeServiceException implements Exception {
  const HandshakeServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
