import 'dart:ui';

class Doctor {
  final String name;
  final String classType; // A+, A, B+
  final String visitStatus; // e.g., "visit 3 of 4"
  final String actionLabel; // "due", "fits", "+ add"
  final Color actionColor;
  final bool isRecommendation;

  Doctor({
    required this.name,
    required this.classType,
    required this.visitStatus,
    required this.actionLabel,
    required this.actionColor,
    this.isRecommendation = false,
  });
}