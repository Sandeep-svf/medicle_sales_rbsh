import 'package:flutter/material.dart';


import '../../../../utils/constants/colors.dart';
import 'section_card.dart';

class ComplianceCard extends StatelessWidget {
  const ComplianceCard({super.key});

  @override
  Widget build(BuildContext context) {

    const used = 19000.0;
    const limit = 50000.0;

    final progress = used / limit;

    return SectionCard(

      title: "Compliance",

      icon: Icons.verified_user_outlined,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Expanded(

                child: _tile(
                  "Used",
                  "₹19,000",
                  Colors.orange,
                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: _tile(
                  "Remaining",
                  "₹31,000",
                  Colors.green,
                ),

              )

            ],

          ),

          const SizedBox(height: 18),

          const Text(
            "Quarterly Budget",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: TColors.primary,
            ),
          ),

          const SizedBox(height: 10),

          Row(

            children: [

              const Text("₹0"),

              const Spacer(),

              Text(
                "₹${limit.toStringAsFixed(0)}",
              )

            ],

          ),

          const SizedBox(height: 18),

          Container(

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color: Colors.green.withOpacity(.08),

              borderRadius: BorderRadius.circular(12),

            ),

            child: const Row(

              children: [

                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Within compliance limit",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )

              ],

            ),

          )

        ],

      ),

    );

  }

  Widget _tile(
      String title,
      String value,
      Color color,
      ) {

    return Container(

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: color.withOpacity(.08),

        borderRadius: BorderRadius.circular(14),

      ),

      child: Column(

        children: [

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

        ],

      ),

    );

  }

}