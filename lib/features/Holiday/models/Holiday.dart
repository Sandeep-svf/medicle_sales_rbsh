import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Enum representing the specific types provided
enum HolidayType {
  National,
  Regional,
  Religious,
  Company,
  Optional,
  Unknown;

  // Helper to parse string to Enum
  static HolidayType fromString(String? type) {
    switch (type) {
      case 'National': return HolidayType.National;
      case 'Regional': return HolidayType.Regional;
      case 'Religious': return HolidayType.Religious;
      case 'Company': return HolidayType.Company;
      case 'Optional': return HolidayType.Optional;
      default: return HolidayType.Unknown;
    }
  }

  // Helper to convert Enum back to string for API calls
  String? get apiValue {
    if (this == HolidayType.Unknown) return null;
    return toString().split('.').last;
  }
}

class Holiday extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final HolidayType type;
  final String description;
  final String hexColor;
  final bool isOptional;
  final bool isRecurring;

  const Holiday({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    required this.hexColor,
    required this.isOptional,
    required this.isRecurring,
  });

  // Factory constructor to parse JSON with null handling
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Holiday',
      // Safe date parsing
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      type: HolidayType.fromString(json['type'] as String?),
      description: json['description'] as String? ?? '',
      // Default to a safe color if null or invalid
      hexColor: json['color'] as String? ?? '#EF4444',
      isOptional: json['isOptional'] as bool? ?? false,
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  // Helper to get Color object from hex string
  Color get color {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [id, title, date, type, isOptional];
}