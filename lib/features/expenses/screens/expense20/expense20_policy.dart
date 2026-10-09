import '../../../../utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../models/ExpenseDefaultValueModel.dart';
import '../widgets/allowance_status_style.dart';
import 'expense20_widgets.dart';

Future<void> showExpense20Policy(
        BuildContext context, ExpenseDefaultValueModel? settings) =>
    showDialog<void>(
      context: context,
      builder: (_) => Expense20Policy(settings: settings),
    );

class Expense20Policy extends StatelessWidget {
  const Expense20Policy({super.key, this.settings});
  final ExpenseDefaultValueModel? settings;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: TColors.white,
        surfaceTintColor: TColors.transparent,
        insetPadding: const EdgeInsets.symmetric(
            horizontal: TSizes.v20, vertical: TSizes.v24),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.v18)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: TSizes.v760,
                maxHeight: MediaQuery.sizeOf(context).height *
                    TSizes.expensePolicyHeightFraction),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  color: TColors.primary,
                  padding: const EdgeInsets.all(TSizes.v20),
                  child: Row(children: [
                    const Icon(Icons.policy_outlined, color: TColors.white),
                    const SizedBox(width: TSizes.v12),
                    const Expanded(
                        child: Text('Expense Policy',
                            style: TextStyle(
                                color: TColors.white,
                                fontSize: TSizes.v21,
                                fontWeight: FontWeight.w700))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close policy',
                        icon: const Icon(Icons.close, color: TColors.white)),
                  ])),
              Flexible(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(TSizes.v24),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily call eligibility',
                                style: TextStyle(
                                    color: TColors.primary,
                                    fontSize: TSizes.v17,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: TSizes.v8),
                            const Text(
                                'TA and DA use confirmed doctor and chemist visits for the '
                                'selected expense date. The percentages below are payable allowances.',
                                style: TextStyle(
                                    color: TColors.textSecondary,
                                    height: TSizes.v1_5)),
                            const SizedBox(height: TSizes.v16),
                            LayoutBuilder(
                                builder: (context, constraints) =>
                                    SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                            width: constraints.maxWidth <
                                                    TSizes.v500
                                                ? 500
                                                : constraints.maxWidth,
                                            child: Table(
                                                defaultVerticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                columnWidths: const {
                                                  0: FlexColumnWidth(1.5),
                                                  1: FlexColumnWidth(1.5)
                                                },
                                                border: TableBorder.all(
                                                    color: TColors
                                                        .borderSecondary),
                                                children: [
                                                  TableRow(
                                                      decoration:
                                                          const BoxDecoration(
                                                              color: TColors
                                                                  .primaryBackground),
                                                      children: [
                                                        'Doctor calls',
                                                        'Chemist calls',
                                                        'TA payable',
                                                        'DA payable'
                                                      ]
                                                          .map((text) => _cell(
                                                              text,
                                                              bold: true))
                                                          .toList()),
                                                  for (final row in const [
                                                    [
                                                      '12 or more',
                                                      '5 or more',
                                                      '100%',
                                                      '100%'
                                                    ],
                                                    [
                                                      '10–11',
                                                      '4',
                                                      '100%',
                                                      '100% · FLAG'
                                                    ],
                                                    ['8–9', '3', '100%', '50%'],
                                                    ['7', '2', '50%', '50%'],
                                                    [
                                                      'Less than 7',
                                                      '0–1',
                                                      '0%',
                                                      '0%'
                                                    ],
                                                  ])
                                                    TableRow(
                                                        children: row
                                                            .map(_cell)
                                                            .toList()),
                                                ])))),
                            const SizedBox(height: TSizes.v16),
                            _note(
                                'Mixed visit counts',
                                'The lower doctor/chemist tier applies. '
                                    'Zero chemist visits means 0% TA and DA payable.'),
                            _note(
                                'FLAG',
                                'The 10–11 doctor / 4 chemist tier pays 100% and is '
                                    'recorded as FLAG. A flag is not an approval decision.'),
                            _note(
                                'Final fare only',
                                'The deduction changes only the final payable fare. '
                                    'Your actual travel distance and DA location type are retained. '
                                    'Review the calculation and saved remark before submitting.'),
                            const Divider(
                                color: TColors.borderSecondary,
                                height: TSizes.v32),
                            const Text('Allowance rates',
                                style: TextStyle(
                                    color: TColors.primary,
                                    fontSize: TSizes.v17,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: TSizes.v10),
                            if (settings == null)
                              const Text(
                                  'Rates are unavailable. Refresh the screen to retry.',
                                  style: TextStyle(color: TColors.error))
                            else ...[
                              _rate('TA · per kilometre', settings!.ratePerKm),
                              _rate('DA · Headquarter',
                                  settings!.headOfficeAmount),
                              _rate('DA · X Station',
                                  settings!.exHeadquartersAmount),
                              _rate('DA · Out of station',
                                  settings!.outsideHeadOfficeAmount),
                            ],
                            const SizedBox(height: TSizes.v16),
                            _note(
                                'Travel Allowance',
                                'Add one or more travel legs. One Way uses '
                                    'distance × rate; Round Trip uses distance × rate × 2. '
                                    'A bill is not required for TA or DA.'),
                            _note(
                                'Other Expense',
                                'Enter the amount and attach a bill photo. '
                                    'Other Expense has no visit-based deduction.'),
                            _note(
                                'Editing',
                                'TA and DA can be edited once. Other Expense cannot '
                                    'be edited. Submission and payment status are shown from the server.'),
                          ]))),
              Padding(
                  padding: const EdgeInsets.all(TSizes.v16),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white),
                          child: const Text('Understood')))),
            ])),
      );

  Widget _cell(String text, {bool bold = false}) {
    final percent =
        text.contains('%') ? int.tryParse(text.split('%').first) : null;
    return Padding(
        padding: const EdgeInsets.all(TSizes.v12),
        child: Text(text,
            style: TextStyle(
                fontSize: TSizes.v12,
                color: percent == null
                    ? TColors.textPrimary
                    : AllowanceStatusStyle.foreground(percent),
                fontWeight: bold || percent != null
                    ? FontWeight.w700
                    : FontWeight.w400)));
  }

  Widget _note(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: TSizes.v14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: TColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: TSizes.v4),
        Text(body,
            style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: TSizes.v13,
                height: TSizes.v1_5)),
      ]));

  Widget _rate(String label, double? amount) => Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.v6),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: TColors.textSecondary, fontSize: TSizes.v13))),
        Text(amount == null ? 'Unavailable' : expense20Money(amount),
            style: const TextStyle(
                color: TColors.primary, fontWeight: FontWeight.w600))
      ]));
}
