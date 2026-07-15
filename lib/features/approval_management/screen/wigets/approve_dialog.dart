import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class ApproveDialog extends StatefulWidget {
  const ApproveDialog({
    super.key,
    required this.onApprove,
  });

  final ValueChanged<String> onApprove;

  @override
  State<ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<ApproveDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          TSizes.cardRadiusLg,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                "Approve Tour Plan",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),

              const SizedBox(
                height: TSizes.sm,
              ),

              Text(
                "Add comments (optional).",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: TColors.textSecondary,
                ),
              ),

              const SizedBox(
                height: TSizes.lg,
              ),

              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Approval comments...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      TSizes.inputFieldRadius,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: TSizes.lg,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [

                  OutlinedButton(
                    onPressed: Get.back,
                    child: const Text("Cancel"),
                  ),

                  const SizedBox(
                    width: TSizes.md,
                  ),

                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      TColors.primary,
                    ),
                    onPressed: () {
                      widget.onApprove(
                        controller.text.trim(),
                      );
                      Get.back();
                    },
                    child: const Text("Approve"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}