import 'package:flutter/material.dart';

import '../helper/AppColors.dart';


class AsmViewScreen extends StatelessWidget {
  const AsmViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ASM review — team MTPs · July", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildTeamRow("Amit Verma", "submitted 24 Jun • auto-checks 9/9", "review", Colors.orange.shade100, Colors.orange.shade800),
                  _buildTeamRow("Neha Joshi", "submitted 23 Jun • 1 warning", "review", Colors.orange.shade100, Colors.orange.shade800),
                  _buildTeamRow("Rohit Bisht", "not submitted • nudged today", "2 days left", Colors.red.shade50, Colors.red.shade800),
                  _buildTeamRow("Priya Goel", "approved 24 Jun", "done", AppColors.leaveBg, AppColors.primaryDark),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTeamRow(String name, String sub, String badge, Color badgeBg, Color badgeText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
            child: Text(badge, style: TextStyle(color: badgeText, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }
}