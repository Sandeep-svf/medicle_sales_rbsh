import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class ReturnDialog extends StatefulWidget {
  const ReturnDialog({
    super.key,
    required this.onReturn,
  });

  final ValueChanged<String> onReturn;

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Return Tour Plan",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(
                height: TSizes.sm,
              ),

              Text(
                "Please provide the reason for returning this tour plan.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  hintText: "Return comments...",
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
                mainAxisAlignment: MainAxisAlignment.end,
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
                      backgroundColor: TColors.warning,
                      foregroundColor: TColors.textWhite,
                    ),
                    onPressed: () {
                      widget.onReturn(
                        controller.text.trim(),
                      );
                      Get.back();
                    },
                    child: const Text("Return"),
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