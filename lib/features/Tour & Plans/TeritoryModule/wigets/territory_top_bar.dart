import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';



class TerritoryTopBar extends StatelessWidget {
  const TerritoryTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        height: 62,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),

          child: Row(
            children: [

              Icon(
                Icons.map_rounded,
                color: TColors.primary,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Territory Management",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}