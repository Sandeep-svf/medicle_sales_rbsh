import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

const expense20WorkingLocations = {
  'headoffice': 'Headquarter (HQ)',
  'ex-headquarters': 'X Station',
  'outside': 'Out of Station',
};

Future<String?> chooseExpense20WorkingLocation(BuildContext context,
        {String? initial}) =>
    showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Working location',
      barrierColor:
          TColors.black.withValues(alpha: TSizes.expenseDialogBarrierOpacity),
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: TSizes.expenseDialogAnimationMs),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
            scale:
                Tween<double>(begin: TSizes.expenseDialogInitialScale, end: 1)
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic)),
            child: child),
      ),
      pageBuilder: (context, _, __) => _WorkingLocationDialog(initial: initial),
    );

class _WorkingLocationDialog extends StatefulWidget {
  const _WorkingLocationDialog({this.initial});
  final String? initial;
  @override
  State<_WorkingLocationDialog> createState() => _WorkingLocationDialogState();
}

class _WorkingLocationDialogState extends State<_WorkingLocationDialog> {
  String? selected;
  @override
  void initState() {
    super.initState();
    selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: TColors.white,
        insetPadding: const EdgeInsets.all(TSizes.md),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.lg)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: TSizes.v460,
              maxHeight: MediaQuery.sizeOf(context).height *
                  TSizes.expenseDialogHeightFraction),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.lg),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.all(TSizes.v12),
                        decoration: BoxDecoration(
                            color: TColors.primaryBackground,
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusLg)),
                        child: const Icon(Icons.location_on_outlined,
                            color: TColors.primary, size: TSizes.iconMd)),
                    const SizedBox(width: TSizes.v12),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Working location',
                              style: TextStyle(
                                  color: TColors.primary,
                                  fontSize: TSizes.v12,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: TSizes.xs),
                          Text('Where are you working?',
                              style: TextStyle(
                                  color: TColors.textPrimary,
                                  fontSize: TSizes.fontSizeLg,
                                  fontWeight: FontWeight.w700)),
                        ])),
                  ]),
                  const SizedBox(height: TSizes.md),
                  const Text(
                      'Choose your location for this expense session. Your DA location will be filled automatically.',
                      style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: TSizes.fontSizeSm)),
                  const SizedBox(height: TSizes.md),
                  Flexible(
                      child: SingleChildScrollView(
                          child: Column(children: [
                    for (final entry in expense20WorkingLocations.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: TSizes.v12),
                        child: Semantics(
                          selected: selected == entry.key,
                          button: true,
                          child: AnimatedContainer(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(
                                    milliseconds:
                                        TSizes.expenseSelectionAnimationMs),
                            decoration: BoxDecoration(
                                color: selected == entry.key
                                    ? TColors.primaryBackground
                                    : TColors.light,
                                borderRadius:
                                    BorderRadius.circular(TSizes.cardRadiusLg),
                                border: Border.all(
                                    color: selected == entry.key
                                        ? TColors.primary
                                        : TColors.borderSecondary)),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(TSizes.cardRadiusLg),
                              onTap: () => Navigator.pop(context, entry.key),
                              child: Padding(
                                  padding: const EdgeInsets.all(TSizes.md),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                            switch (entry.key) {
                                              'headoffice' =>
                                                Icons.apartment_outlined,
                                              'ex-headquarters' =>
                                                Icons.route_outlined,
                                              _ => Icons.luggage_outlined,
                                            },
                                            size: TSizes.iconMd,
                                            color: TColors.primary),
                                        const SizedBox(width: TSizes.v12),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(entry.value,
                                                  style: const TextStyle(
                                                      color:
                                                          TColors.textPrimary,
                                                      fontSize:
                                                          TSizes.fontSizeSm,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const SizedBox(height: TSizes.xs),
                                              Text(
                                                  switch (entry.key) {
                                                    'headoffice' =>
                                                      'Working at your headquarters. Add TA is unavailable for HQ.',
                                                    'ex-headquarters' =>
                                                      'Working away from HQ within your assigned territory.',
                                                    _ =>
                                                      'Working out of station. Existing TA and DA checks still apply.',
                                                  },
                                                  style: const TextStyle(
                                                      color:
                                                          TColors.textSecondary,
                                                      fontSize: TSizes.v12,
                                                      height: TSizes.v1_4)),
                                            ])),
                                        const SizedBox(width: TSizes.sm),
                                        Icon(
                                            selected == entry.key
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: selected == entry.key
                                                ? TColors.primary
                                                : TColors.darkGrey,
                                            size: TSizes.iconMd),
                                      ])),
                            ),
                          ),
                        ),
                      ),
                  ]))),
                ]),
          ),
        ),
      );
}
