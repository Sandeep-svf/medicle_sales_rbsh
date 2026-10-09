import '../../SalesChartAnalysis/model/SalesChartDashboardModel.dart';

/// Daily DCR eligibility. When counts differ, the lower tier applies.
class AllowanceDeduction {
  const AllowanceDeduction({
    required this.category,
    required this.date,
    required this.doctorCalls,
    required this.chemistCalls,
    required this.grossCents,
    required this.payablePercent,
    required this.flagged,
    required this.eligibilityTier,
    this.doctorTotal = 0,
    this.doctorScheduled = 0,
    this.chemistTotal = 0,
    this.chemistScheduled = 0,
  });

  static const remarkPrefix = '[DCR allowance]';
  final String category;
  final String date;
  final int doctorCalls;
  final int chemistCalls;
  final int grossCents;
  final int payablePercent;
  final bool flagged;
  final int eligibilityTier;
  final int doctorTotal;
  final int doctorScheduled;
  final int chemistTotal;
  final int chemistScheduled;

  factory AllowanceDeduction.calculate({
    required String category,
    required String date,
    required double grossAmount,
    required Visits visits,
  }) {
    if (category != 'travel' && category != 'daily') {
      throw ArgumentError('DCR deductions apply only to TA and DA.');
    }
    if (!grossAmount.isFinite ||
        grossAmount < 0 ||
        visits.doctor == null ||
        visits.chemist == null) {
      throw ArgumentError(
          'Valid fare and confirmed visit counts are required.');
    }
    final doctors = visits.doctor!.confirmed;
    final chemists = visits.chemist!.confirmed;
    if (doctors < 0 || chemists < 0) {
      throw ArgumentError('Visit counts cannot be negative.');
    }
    final doctorTier = doctors >= 12
        ? 4
        : doctors >= 10
            ? 3
            : doctors >= 8
                ? 2
                : doctors >= 7
                    ? 1
                    : 0;
    final chemistTier = chemists >= 5
        ? 4
        : chemists >= 4
            ? 3
            : chemists >= 3
                ? 2
                : chemists >= 2
                    ? 1
                    : 0;
    final tier = doctorTier < chemistTier ? doctorTier : chemistTier;
    final payable = tier >= 3
        ? 100
        : tier == 2
            ? (category == 'travel' ? 100 : 50)
            : tier == 1
                ? 50
                : 0;
    return AllowanceDeduction(
      category: category,
      date: date,
      doctorCalls: doctors,
      chemistCalls: chemists,
      grossCents: (grossAmount * 100).round(),
      payablePercent: payable,
      flagged: tier == 3,
      eligibilityTier: tier,
      doctorTotal:
          visits.doctor!.total < doctors ? doctors : visits.doctor!.total,
      doctorScheduled: visits.doctor!.scheduled,
      chemistTotal:
          visits.chemist!.total < chemists ? chemists : visits.chemist!.total,
      chemistScheduled: visits.chemist!.scheduled,
    );
  }

  int get payableCents => (grossCents * payablePercent / 100).round();
  double get grossAmount => grossCents / 100;
  double get payableAmount => payableCents / 100;
  double get deductedAmount => (grossCents - payableCents) / 100;
  int get deductionPercent => 100 - payablePercent;
  String get label => category == 'travel' ? 'TA' : 'DA';

  String get remark => '$remarkPrefix $date | $label | '
      'Confirmed: $doctorCalls doctor, $chemistCalls chemist | '
      'Original: ₹${grossAmount.toStringAsFixed(2)} | '
      'Deduction: $deductionPercent% (₹${deductedAmount.toStringAsFixed(2)}) | '
      'Final payable: ₹${payableAmount.toStringAsFixed(2)}'
      '${flagged ? ' | FLAG' : ''}';

  static String removePreviousRemark(String description) => description
      .split('\n')
      .where((line) => !line.startsWith(remarkPrefix))
      .join('\n')
      .trim();

  String appendTo(String description) {
    final original = removePreviousRemark(description);
    return original.isEmpty ? remark : '$original\n$remark';
  }
}
