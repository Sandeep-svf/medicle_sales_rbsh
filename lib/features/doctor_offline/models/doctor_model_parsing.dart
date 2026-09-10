class DoctorModelParsing {
  const DoctorModelParsing._();

  static String requiredIdentifier(Object? value, String fieldName) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$fieldName must be a nonempty string.');
    }
    return value.trim();
  }

  static String? nullableString(Object? value, String fieldName) {
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('$fieldName must be a string or null.');
    }
    return value;
  }

  static String? nullableIdentifier(Object? value, String fieldName) {
    final parsed = nullableString(value, fieldName);
    if (parsed == null) return null;
    if (parsed.trim().isEmpty) {
      throw FormatException('$fieldName cannot be empty.');
    }
    return parsed.trim();
  }

  static num? nullableNumber(Object? value, String fieldName) {
    if (value == null) return null;
    if (value is num && value.isFinite) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null && parsed.isFinite) return parsed;
    }
    throw FormatException('$fieldName must be a finite number or null.');
  }

  static int? nullableInteger(Object? value, String fieldName) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num && value.isFinite && value == value.truncate()) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('$fieldName must be an integer or null.');
  }

  static BigInt requiredVersion(Object? value, String fieldName) {
    final parsed = nullableVersion(value, fieldName);
    if (parsed == null) {
      throw FormatException('$fieldName is required.');
    }
    return parsed;
  }

  static BigInt? nullableVersion(Object? value, String fieldName) {
    if (value == null) return null;

    BigInt? parsed;
    if (value is int) {
      parsed = BigInt.from(value);
    } else if (value is String) {
      parsed = BigInt.tryParse(value);
    }

    if (parsed == null || parsed.isNegative) {
      throw FormatException(
        '$fieldName must be a nonnegative exact integer or decimal string.',
      );
    }
    return parsed;
  }

  static DateTime? nullableCalendarDate(Object? value, String fieldName) {
    final source = nullableString(value, fieldName);
    if (source == null) return null;
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T.*)?$').firstMatch(
      source,
    );
    if (match == null) {
      throw FormatException('$fieldName contains an invalid calendar date.');
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final parsed = DateTime.tryParse(source);
    final normalized = DateTime.utc(year, month, day);
    if (parsed == null ||
        normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw FormatException('$fieldName contains an invalid calendar date.');
    }
    return normalized;
  }

  static DateTime? nullableTimestamp(Object? value, String fieldName) {
    final source = nullableString(value, fieldName);
    if (source == null) return null;
    final parsed = DateTime.tryParse(source);
    if (parsed == null) {
      throw FormatException('$fieldName contains an invalid timestamp.');
    }
    return parsed.toUtc();
  }

  static String? clientGeneratedId(Map<String, dynamic> json) {
    final camelCase = nullableIdentifier(
      json['clientGeneratedId'],
      'clientGeneratedId',
    );
    final snakeCase = nullableIdentifier(
      json['client_generated_id'],
      'client_generated_id',
    );

    if (camelCase != null && snakeCase != null && camelCase != snakeCase) {
      throw const FormatException(
        'Conflicting clientGeneratedId aliases were received.',
      );
    }

    return camelCase ?? snakeCase;
  }

  static String? encodeCalendarDate(DateTime? value) {
    if (value == null) return null;
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String? encodeTimestamp(DateTime? value) {
    return value?.toUtc().toIso8601String();
  }
}
