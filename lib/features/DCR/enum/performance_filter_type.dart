enum PerformanceFilterType {
  today,
  weekly,
  monthly,
  custom,
}

extension PerformanceFilterTypeExtension on PerformanceFilterType {
  String get apiValue {
    switch (this) {
      case PerformanceFilterType.today:
        return "today";

      case PerformanceFilterType.weekly:
        return "weekly";

      case PerformanceFilterType.monthly:
        return "monthly";

      case PerformanceFilterType.custom:
        return "custom";
    }
  }
}