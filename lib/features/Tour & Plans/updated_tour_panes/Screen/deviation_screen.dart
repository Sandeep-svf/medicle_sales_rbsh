import 'package:flutter/material.dart';

import '../helper/AppColors.dart';


class DeviationScreen extends StatelessWidget {
  const DeviationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mid-month deviation flow", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 24),
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("START DAY · 17 JUL 09:12 — BEAT MISMATCH DETECTED", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  const Text("Planned: Beat 03 · Sector 4–10\nYou selected: Beat 01 · Gaur City", style: TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  const Text("Reason (required to continue):", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      Chip(label: const Text("Doctor unavailable"), backgroundColor: AppColors.primaryDark, labelStyle: const TextStyle(color: Colors.white), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      Chip(label: const Text("Stockist urgency"), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      Chip(label: const Text("Manager instruction"), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Start day with deviation →", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}