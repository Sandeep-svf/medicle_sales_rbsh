import 'package:flutter/material.dart';
import '../helper/AppColors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class PreSubmitValidationModal extends StatelessWidget {
  const PreSubmitValidationModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TColors.transparent,
      elevation: TSizes.v0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: TSizes.v600,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: TColors.pureBlack.withOpacity(0.1),
                blurRadius: TSizes.v20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 32, right: 24, top: 24, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(TTexts.uiTextPreSubmitValidationJulyMTP,
                      style: TextStyle(
                          fontSize: TSizes.v20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.holidayBg),
                  )
                ],
              ),
            ),
            const Divider(height: TSizes.v1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  _buildValidationItem(
                      isSuccess: true,
                      title: TTexts.uiText24WorkingDaysAllAssigned,
                      subtitle:
                          TTexts.uiText23Field1MeetingLeaveHolidaysExcluded),
                  _buildValidationItem(
                      isSuccess: true,
                      title: TTexts.uiTextNoClashWithApprovedLeaveOrUPHolidays,
                      subtitle:
                          TTexts.uiText14JulLeaveHonoured6JulMuharramBlocked),
                  _buildValidationItem(
                      isSuccess: false,
                      title: TTexts.uiText1ADoctorBelowFrequencyNormDrKapoor,
                      subtitle: TTexts.uiTextSuggestedFixAddToBeat0421Jul,
                      actionText: "apply fix"),
                  _buildValidationItem(
                      isSuccess: true,
                      title: TTexts.uiTextTravelCallLoadWithinLimits,
                      subtitle: TTexts.uiTextMaxDay29Km8CallsMonthly510),
                ],
              ),
            ),
            const Divider(height: TSizes.v1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                      TTexts.uiTextWarningsDonTBlockSubmissionTheyReShown,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: TSizes.v12, color: AppColors.textMuted)),
                  const SizedBox(height: TSizes.v20),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: AppColors.holidayBg,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(TTexts.uiTextKeepEditing,
                              style: TextStyle(
                                  color: AppColors.textMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: TSizes.v16)),
                        ),
                      ),
                      const SizedBox(width: TSizes.v16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: TColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check, size: TSizes.v20),
                          label: const Text(
                              TTexts.uiTextSubmitToASM9DaysBeforeDeadline,
                              style: TextStyle(
                                  fontSize: TSizes.v16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildValidationItem(
      {required bool isSuccess,
      required String title,
      required String subtitle,
      String? actionText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: isSuccess ? AppColors.leaveBg : TColors.materialOrange50,
                shape: BoxShape.circle),
            child: Icon(isSuccess ? Icons.check_circle : Icons.error,
                color:
                    isSuccess ? AppColors.primaryDark : TColors.materialOrange,
                size: TSizes.v20),
          ),
          const SizedBox(width: TSizes.v16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.v14,
                        color: AppColors.textMain)),
                const SizedBox(height: TSizes.v2),
                Wrap(
                  children: [
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: TSizes.v13, color: AppColors.textMuted)),
                    if (actionText != null)
                      Text(actionText,
                          style: const TextStyle(
                              fontSize: TSizes.v13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                              decoration: TextDecoration.underline))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
