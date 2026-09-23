import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class EntityMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const EntityMarker({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: TSizes.v38,
        height: TSizes.v38,
        decoration: BoxDecoration(
          color: TColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: TSizes.v2,
          ),
          boxShadow: const [
            BoxShadow(
              color: TColors.black12,
              blurRadius: TSizes.v6,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: TSizes.v20,
        ),
      ),
    );
  }
}
