import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/enum/day_type.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/DashboardController.dart';
import '../model/SalesChartDashboardModel.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class TodayBeatCard extends StatelessWidget {
  final TodayBeatAssigned? beat;

  const TodayBeatCard({
    super.key,
    this.beat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColors.primary_shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(.08),
            blurRadius: TSizes.v20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //---------------------------------------------------
          // Header
          //---------------------------------------------------

          Row(
            children: [
              Container(
                height: TSizes.v48,
                width: TSizes.v48,
                decoration: BoxDecoration(
                  color: TColors.primary_shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: TColors.primary,
                  size: TSizes.v26,
                ),
              ).animate(onPlay: (controller) => controller.repeat()).scale(
                    begin: const Offset(.95, .95),
                    end: const Offset(1.08, 1.08),
                    duration: 1500.ms,
                  ),
              const SizedBox(width: TSizes.v12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TTexts.uiTextTODAYSBEAT,
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        fontSize: TSizes.v11,
                      ),
                    ),
                    SizedBox(height: TSizes.v3),
                    Text(
                      TTexts.uiTextFieldAssignment,
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.v17,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: TColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: TColors.success,
                      size: TSizes.v14,
                    ),
                    SizedBox(width: TSizes.v5),
                    Text(
                      TTexts.uiTextTODAY,
                      style: TextStyle(
                        color: TColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.v11,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: TSizes.v20),

          //---------------------------------------------------
          // Beat Name
          //---------------------------------------------------

          Text(
            beat?.dayType.showBeat == true
                ? (beat?.beatName ?? "No Beat Assigned")
                : beat?.dayType.displayName ?? "No Activity",
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: TSizes.v25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: TSizes.v6),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: TSizes.v15,
                color: TColors.textSecondary,
              ),
              const SizedBox(width: TSizes.v6),
              const Text(
                TTexts.uiTextTuesday04Aug2026,
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: TSizes.v18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TColors.primary_shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: TColors.primary,
                ),
                SizedBox(width: TSizes.v10),
                Expanded(
                  child: Text(
                    TTexts.uiTextTodaySBeatIsActiveCompleteYourPlanned,
                    style: TextStyle(
                      color: TColors.textPrimary,
                      fontSize: TSizes.v12,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: TSizes.v22),

          //---------------------------------------------------
          // Stats
          //---------------------------------------------------

          if (beat?.dayType.showBeat == true)
            Row(
              children: [
                Expanded(
                  child: _BeatStat(
                    icon: Icons.medical_services,
                    value: "${beat?.doctorsCount ?? 0}",
                    label: TTexts.uiTextDoctors,
                  ),
                ),
                const SizedBox(width: TSizes.v10),
                Expanded(
                  child: _BeatStat(
                    icon: Icons.local_pharmacy,
                    value: "${beat?.chemistsCount ?? 0}",
                    label: TTexts.uiTextChemists,
                  ),
                ),
                const SizedBox(width: TSizes.v10),
                Expanded(
                  child: _BeatStat(
                    icon: Icons.storefront,
                    value: "${beat?.stockistsCount ?? 0}",
                    label: TTexts.uiTextStockists,
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TColors.primary_shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.event_available,
                    color: TColors.primary,
                    size: TSizes.v34,
                  ),
                  const SizedBox(height: TSizes.v10),
                  Text(
                    beat?.dayType.displayName ?? "No Activity",
                    style: const TextStyle(
                      fontSize: TSizes.v18,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: TSizes.v6),
                  const Text(
                    TTexts.uiTextNoBeatAssignedForToday,
                    style: TextStyle(
                      color: TColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: TSizes.v22),

          Divider(
            color: TColors.borderSecondary,
            height: TSizes.v1,
          ),

          const SizedBox(height: TSizes.v18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                TTexts.uiTextNeedAnotherBeat,
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: TSizes.v12,
                ),
              ),
              const SizedBox(height: TSizes.v4),
              const Text(
                TTexts.uiTextSwitchYourBeatAssignment,
                style: TextStyle(
                  color: TColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TSizes.v14),
              SizedBox(
                width: double.infinity,
                height: TSizes.v50,
                child: ElevatedButton(
                  onPressed: () async {
                    final controller = Get.find<DashboardController>();

                    await controller.fetchDashboardBeats();

                    controller.showDashboardBeatBottomSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    elevation: TSizes.v0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(Icons.swap_horiz_rounded),
                      const SizedBox(width: TSizes.v8),
                      Text(
                        TTexts.uiTextSwitchTodaySBeat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.v14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: .15);
  }
}

class _BeatStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _BeatStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .95, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: TColors.softGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.borderSecondary,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: TSizes.v42,
              width: TSizes.v42,
              decoration: BoxDecoration(
                color: TColors.primary_shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: TColors.primary,
                size: TSizes.v22,
              ),
            ),
            const SizedBox(height: TSizes.v12),
            Text(
              value,
              style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: TSizes.v22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: TSizes.v4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: TSizes.v12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
