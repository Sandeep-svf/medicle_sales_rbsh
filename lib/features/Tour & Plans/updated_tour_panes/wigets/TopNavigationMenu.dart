import 'package:flutter/material.dart';

import '../helper/AppColors.dart';


class TopNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const TopNavigationMenu({Key? key, required this.currentIndex, required this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.pie_chart, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _navItem("MTP July", Icons.calendar_month, 0),
                  _navItem("STP", Icons.table_chart_outlined, 1),
                  _navItem("Status", Icons.access_time, 2),
                  _navItem("ASM view", Icons.check_circle_outline, 3),
                  _navItem("Deviation", Icons.warning_amber_rounded, 4),
                ],
              ),
            ),
          ),
          CircleAvatar(
              backgroundColor: Colors.orange.shade300,
              child: const Text("AV", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  Widget _navItem(String title, IconData icon, int index) {
    bool isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 24),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}