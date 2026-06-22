import 'package:flutter/material.dart';

import '../helper/AppColors.dart';


class PreSubmitValidationModal extends StatelessWidget {
  const PreSubmitValidationModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 24, top: 24, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pre-submit validation · July MTP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(backgroundColor: AppColors.holidayBg),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  _buildValidationItem(isSuccess: true, title: "24 working days all assigned", subtitle: "23 field • 1 meeting • leave & holidays excluded"),
                  _buildValidationItem(isSuccess: true, title: "No clash with approved leave or UP holidays", subtitle: "14 Jul leave honoured • 6 Jul Muharram blocked"),
                  _buildValidationItem(isSuccess: false, title: "1 A+ doctor below frequency norm — Dr. Kapoor (1 of 2)", subtitle: "suggested fix: add to Beat 04 · 21 Jul (+2.2 km) — ", actionText: "apply fix"),
                  _buildValidationItem(isSuccess: true, title: "Travel & call load within limits", subtitle: "max day: 29 km / 8 calls • monthly ~510 km"),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text("Warnings don't block submission — they're shown to your ASM alongside the plan. Blocking issues (red) must be fixed first.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18), backgroundColor: AppColors.holidayBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Keep editing", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text("Submit to ASM — 9 days before deadline", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildValidationItem({required bool isSuccess, required String title, required String subtitle, String? actionText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2), padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: isSuccess ? AppColors.leaveBg : Colors.orange.shade50, shape: BoxShape.circle),
            child: Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? AppColors.primaryDark : Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain)),
                const SizedBox(height: 2),
                Wrap(
                  children: [
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    if (actionText != null) Text(actionText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, decoration: TextDecoration.underline))
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