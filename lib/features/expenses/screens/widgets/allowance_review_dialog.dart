import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../models/allowance_deduction.dart';
import 'allowance_status_style.dart';

class AllowanceReviewDialog extends StatelessWidget {
  const AllowanceReviewDialog({super.key, required this.deduction});
  final AllowanceDeduction deduction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: TColors.white,
      surfaceTintColor: TColors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: 820, maxHeight: size.height * .88),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _header(),
          Flexible(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(builder: (context, constraints) {
              final summary = _summary();
              final rules = _rules();
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _visitSummary(constraints.maxWidth),
                    const SizedBox(height: 24),
                    if (constraints.maxWidth >= 680)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: summary),
                            const SizedBox(width: 24),
                            Expanded(child: rules),
                          ])
                    else ...[summary, const SizedBox(height: 24), rules],
                    const SizedBox(height: 24),
                    _remark(),
                  ]);
            }),
          )),
          _footer(context),
        ]),
      ),
    );
  }

  Widget _header() => Container(
        color: TColors.primary,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: TColors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long_outlined,
                color: TColors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Review ${deduction.label} claim',
                    style: const TextStyle(
                        color: TColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(
                    DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(deduction.date)),
                    style:
                        const TextStyle(color: TColors.white70, fontSize: 13)),
              ])),
        ]),
      );

  Widget _heading(String title) => Text(title,
      style: const TextStyle(
          color: TColors.primary, fontSize: 15, fontWeight: FontWeight.w700));

  Widget _summary() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _heading('Claim calculation'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: TColors.light, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _row('Original fare',
                '₹${deduction.grossAmount.toStringAsFixed(2)}'),
            _row('Deduction (${deduction.deductionPercent}%)',
                '₹${deduction.deductedAmount.toStringAsFixed(2)}'),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          key: const ValueKey('allowance-payable-status'),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AllowanceStatusStyle.background(deduction.payablePercent),
              border: Border.all(
                  color:
                      AllowanceStatusStyle.foreground(deduction.payablePercent)
                          .withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(12)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('Final payable',
                      style: TextStyle(
                          color: TColors.textSecondary, fontSize: 13))),
              Flexible(
                  child: _statusPill(deduction.payablePercent,
                      text: AllowanceStatusStyle.label(
                          deduction.payablePercent))),
            ]),
            const SizedBox(height: 6),
            Text('₹${deduction.payableAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    color: AllowanceStatusStyle.foreground(
                        deduction.payablePercent),
                    fontSize: 28,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
                '${deduction.payablePercent}% of the original ${deduction.label} fare',
                style: const TextStyle(
                    color: TColors.textSecondary, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 24),
        _eligibilityStamp(),
      ]);

  Widget _eligibilityStamp() {
    final color = deduction.flagged
        ? TColors.allowancePartialText
        : AllowanceStatusStyle.foreground(deduction.payablePercent);
    final title = deduction.flagged
        ? 'FLAGGED'
        : AllowanceStatusStyle.label(deduction.payablePercent).toUpperCase();
    final icon = deduction.flagged
        ? Icons.flag_outlined
        : deduction.payablePercent == 0
            ? Icons.block_outlined
            : deduction.payablePercent == 50
                ? Icons.percent_rounded
                : Icons.verified_outlined;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.rotate(
          angle: -.035,
          child: Container(
            key: const ValueKey('allowance-eligibility-stamp'),
            constraints: const BoxConstraints(maxWidth: 330),
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: TColors.white,
              border: Border.all(color: color.withValues(alpha: .75), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: .4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(children: [
                Text('DCR ELIGIBILITY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: color,
                        fontSize: 24,
                        height: 1.15,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text('${deduction.payablePercent}% ${deduction.label} payable',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rules() {
    const rows = [
      ['12 or more', '5 or more', '100%', '100%'],
      ['10–11', '4', '100%', '100% · FLAG'],
      ['8–9', '3', '100%', '50%'],
      ['7', '2', '50%', '50%'],
      ['Less than 7', '1', '0%', '0%'],
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Daily call eligibility rules'),
      const SizedBox(height: 5),
      const Text(
          'Percentages show the allowance payable; the marked row is your applied tier.',
          style: TextStyle(color: TColors.textSecondary, fontSize: 12)),
      const SizedBox(height: 12),
      LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width:
                      constraints.maxWidth < 380 ? 380 : constraints.maxWidth,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TColors.primary_shade100)),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.5),
                        1: FlexColumnWidth(1.4),
                        2: FlexColumnWidth(.9),
                        3: FlexColumnWidth(1.6)
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                            decoration: const BoxDecoration(
                                color: TColors.primaryBackground),
                            children: [
                              'Doctor calls',
                              'Chemist calls',
                              'TA',
                              'DA'
                            ]
                                .map((text) => _cell(text, heading: true))
                                .toList()),
                        for (var index = 0; index < rows.length; index++)
                          TableRow(
                              decoration: BoxDecoration(
                                  color: deduction.eligibilityTier == 4 - index
                                      ? AllowanceStatusStyle.background(
                                          deduction.payablePercent)
                                      : TColors.white),
                              children: rows[index]
                                  .map((text) => _cell(text,
                                      applied: deduction.eligibilityTier ==
                                          4 - index,
                                      heading: deduction.eligibilityTier ==
                                          4 - index))
                                  .toList()),
                      ],
                    ),
                  ),
                ),
              )),
      const SizedBox(height: 10),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
                color:
                    AllowanceStatusStyle.foreground(deduction.payablePercent),
                borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 7),
        const Expanded(
            child: Text('Highlighted row: applied eligibility tier.',
                style: TextStyle(color: TColors.textSecondary, fontSize: 12))),
      ]),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _statusPill(100, text: '100% Full'),
        _statusPill(50, text: '50% Partial'),
        _statusPill(0, text: '0% Not eligible'),
      ]),
      const SizedBox(height: 10),
      const Text(
          '10–11 doctor calls with 4 chemist calls receive full DA and are marked FLAG. '
          'For mixed counts, the lower tier applies. Zero chemist visits means no TA or DA is payable.',
          style: TextStyle(
              color: TColors.textSecondary, fontSize: 12, height: 1.5)),
    ]);
  }

  Widget _cell(String text, {bool heading = false, bool applied = false}) {
    final percent =
        text.contains('%') ? int.tryParse(text.split('%').first) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: percent != null
          ? _statusPill(percent, text: text)
          : Row(children: [
              if (applied &&
                  (text == '12 or more' ||
                      text == '10–11' ||
                      text == '8–9' ||
                      text == '7' ||
                      text == 'Less than 7')) ...[
                Icon(Icons.check_circle,
                    size: 14,
                    semanticLabel: 'Applied eligibility tier',
                    color: AllowanceStatusStyle.foreground(
                        deduction.payablePercent)),
                const SizedBox(width: 4),
              ],
              Expanded(
                  child: Text(text,
                      style: TextStyle(
                          color: TColors.textPrimary,
                          fontSize: 12,
                          fontWeight:
                              heading ? FontWeight.w600 : FontWeight.w400))),
            ]),
    );
  }

  Widget _statusPill(int percent, {required String text}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
            color: AllowanceStatusStyle.background(percent),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
                color: AllowanceStatusStyle.foreground(percent)
                    .withValues(alpha: .22))),
        child: Text(text,
            style: TextStyle(
                color: AllowanceStatusStyle.foreground(percent),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );

  Widget _visitSummary(double width) {
    final doctors = _visitCard('Doctor visits', Icons.medical_services_outlined,
        deduction.doctorCalls);
    final chemists = _visitCard('Chemist visits', Icons.local_pharmacy_outlined,
        deduction.chemistCalls);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Completed visits for the expense date'),
      const SizedBox(height: 5),
      const Text('Confirmed doctor and chemist visits determine the allowance.',
          style: TextStyle(color: TColors.textSecondary, fontSize: 12)),
      const SizedBox(height: 12),
      if (width >= 480)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: doctors),
          const SizedBox(width: 12),
          Expanded(child: chemists),
        ])
      else ...[doctors, const SizedBox(height: 12), chemists],
    ]);
  }

  Widget _visitCard(String title, IconData icon, int visits) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: TColors.light,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.borderSecondary)),
        child: Row(children: [
          Icon(icon, size: 22, color: TColors.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: TColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Text('$visits',
              key: ValueKey('$title-count'),
              style: const TextStyle(
                  color: TColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _remark() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _heading('Remark to be saved'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: TColors.light, borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.notes_outlined,
                color: TColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(deduction.remark,
                    style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 13,
                        height: 1.6))),
          ]),
        ),
      ]);

  Widget _footer(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
            color: TColors.white,
            border: Border(top: BorderSide(color: TColors.primary_shade100))),
        child: OverflowBar(
            spacing: 12,
            overflowSpacing: 8,
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                      foregroundColor: TColors.textSecondary,
                      minimumSize: const Size(80, 44)),
                  child: const Text('Back')),
              ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      minimumSize: const Size(160, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  label: const Text('Submit claim')),
            ]),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: TColors.textSecondary, fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
        ]),
      );
}
