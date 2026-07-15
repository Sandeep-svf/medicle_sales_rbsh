import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnDialog extends StatefulWidget {
  const ReturnDialog({
    super.key,
    required this.onReturn,
  });

  final Function(String comments) onReturn;

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Return Tour Plan"),
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Reason for returning...",
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
            widget.onReturn(controller.text.trim());
            Get.back();
          },
          child: const Text("Return"),
        ),
      ],
    );
  }
}