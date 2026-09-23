import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class BeatChangeActionDialog extends StatefulWidget {
  const BeatChangeActionDialog({
    super.key,
    required this.approve,
    required this.onSubmit,
  });

  final bool approve;

  final Function(String comments) onSubmit;

  @override
  State<BeatChangeActionDialog> createState() => _BeatChangeActionDialogState();
}

class _BeatChangeActionDialogState extends State<BeatChangeActionDialog> {
  final TextEditingController commentsController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.approve ? Icons.check_circle : Icons.cancel,
                size: TSizes.v60,
                color: widget.approve ? TColors.success : TColors.error,
              ),
              const SizedBox(height: TSizes.v16),
              Text(
                widget.approve ? "Approve Beat Change" : "Reject Beat Change",
                style: const TextStyle(
                  fontSize: TSizes.v20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TSizes.v8),
              Text(
                widget.approve
                    ? "Please enter approval comments."
                    : "Please provide rejection reason.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TColors.textSecondary,
                ),
              ),
              const SizedBox(height: TSizes.v20),
              TextFormField(
                controller: commentsController,
                maxLines: 4,
                maxLength: 250,
                decoration: InputDecoration(
                  labelText: TTexts.uiTextComments,
                  hintText: widget.approve
                      ? "Enter approval comments..."
                      : "Enter rejection reason...",
                  filled: true,
                  fillColor: TColors.softGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: TColors.primary,
                      width: TSizes.v2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Comments are required";
                  }

                  if (value.trim().length < 5) {
                    return "Please enter at least 5 characters";
                  }

                  return null;
                },
              ),
              const SizedBox(height: TSizes.v20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        TTexts.cancel,
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.v12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor:
                            widget.approve ? TColors.success : TColors.error,
                        foregroundColor: TColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        Get.back();

                        widget.onSubmit(
                          commentsController.text.trim(),
                        );
                      },
                      child: Text(
                        widget.approve ? "Approve" : "Reject",
                      ),
                    ),
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
