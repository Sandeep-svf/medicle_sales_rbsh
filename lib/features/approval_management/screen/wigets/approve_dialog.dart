import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApproveDialog extends StatefulWidget {
  const ApproveDialog({
    super.key,
    required this.onApprove,
  });

  final Function(String comments) onApprove;

  @override
  State<ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<ApproveDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Approve Tour Plan"),
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Enter approval comments...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApprove(controller.text.trim());
            Get.back();
          },
          child: const Text("Approve"),
        ),
      ],
    );
  }
}