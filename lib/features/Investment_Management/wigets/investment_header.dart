import 'package:flutter/material.dart';

import 'investment_toggle.dart';

class InvestmentHeader extends StatelessWidget {

  final bool table;

  final ValueChanged<bool> onToggle;

  const InvestmentHeader({
    super.key,
    required this.table,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        const Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                "My Investment Requests",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height:6),

              Text(
                "Track every request through approval & payout",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              )

            ],
          ),
        ),

        InvestmentToggle(
          table: table,
          onChanged: onToggle,
        )

      ],
    );
  }
}