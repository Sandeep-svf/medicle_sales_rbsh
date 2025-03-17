import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/MarketingMaterials/Screens/pramotion.dart';

import 'brochure.dart';

class MarketingmaterialsScreen extends StatelessWidget {
  const MarketingmaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 48) / 2; // Half width with padding

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to top
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Brochure Module
                _buildModuleCard(
                  context,
                  "assets/images/pdf.png", // Replace with actual image path
                  "Brochure",
                  cardWidth,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BrochureScreen()),
                    );
                  },
                ),

                // Promotion Module
                _buildModuleCard(
                  context,
                  "assets/images/dummy.jpeg", // Replace with actual image path
                  "Promotion",
                  cardWidth,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PromotionScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build card modules
  Widget _buildModuleCard(BuildContext context, String imagePath, String title,
      double cardWidth, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: cardWidth,
          height: 250,
          child: Column(
            children: [
              // Image takes most of the space
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    imagePath,
                    width: cardWidth,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Text at the bottom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}