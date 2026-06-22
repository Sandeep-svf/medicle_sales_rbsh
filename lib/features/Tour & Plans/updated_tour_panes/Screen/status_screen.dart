import 'package:flutter/material.dart';

import '../helper/AppColors.dart';


class StatusScreen extends StatelessWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Plan status & history", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 24),
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimelineNode("Auto-draft", "20 Jun", true),
                  _buildTimelineLine(true),
                  _buildTimelineNode("MSR editing", "now", true, isActive: true),
                  _buildTimelineLine(false),
                  _buildTimelineNode("Submit", "by 25 Jun", false),
                  _buildTimelineLine(false),
                  _buildTimelineNode("ASM review", "by 28 Jun", false),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String title, String sub, bool isDone, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: isDone ? AppColors.primaryDark : Colors.grey.shade200, shape: BoxShape.circle, border: isActive ? Border.all(color: Colors.orange, width: 3) : null),
          child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? AppColors.primaryDark : AppColors.textMain)),
        Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTimelineLine(bool isDone) {
    return Expanded(child: Container(height: 2, color: isDone ? AppColors.primaryDark : Colors.grey.shade200));
  }
}