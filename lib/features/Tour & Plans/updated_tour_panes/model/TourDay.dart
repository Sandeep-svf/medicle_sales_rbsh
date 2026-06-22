import '../DayType.dart';

class TourDay {
  final DateTime date;
  final DayType type;

  // Backend Fields
  final String? beatId;
  final String? beatName;
  final String? jointWorkUserId;
  final String? jointWorkUserName;
  final String? notes;
  final String? holidayName;

  const TourDay({
    required this.date,
    required this.type,
    this.beatId,
    this.beatName,
    this.jointWorkUserId,
    this.jointWorkUserName,
    this.notes,
    this.holidayName,
  });

  TourDay copyWith({
    DayType? type,
    String? beatId,
    String? beatName,
    String? jointWorkUserId,
    String? jointWorkUserName,
    String? notes,
    String? holidayName,
  }) {
    return TourDay(
      date: date,
      type: type ?? this.type,
      beatId: beatId ?? this.beatId,
      beatName: beatName ?? this.beatName,
      jointWorkUserId: jointWorkUserId ?? this.jointWorkUserId,
      jointWorkUserName: jointWorkUserName ?? this.jointWorkUserName,
      notes: notes ?? this.notes,
      holidayName: holidayName ?? this.holidayName,
    );
  }
}