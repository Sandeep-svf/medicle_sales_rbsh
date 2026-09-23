import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class GpsImagePreviewWidget extends StatelessWidget {
  final File image;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime capturedAt;

  const GpsImagePreviewWidget({
    super.key,
    required this.image,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.capturedAt,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          /// IMAGE
          Image.file(
            image,
            width: TSizes.v420,
            height: TSizes.v220,
            fit: BoxFit.cover,
          ),

          /// DARK GRADIENT OVERLAY
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColors.pureBlack.withOpacity(0.8),
                    TColors.pureBlack.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// MAP THUMBNAIL (OPTIONAL)
                  Container(
                    height: TSizes.v70,
                    width: TSizes.v70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TColors.white54),
                      image: const DecorationImage(
                        image: AssetImage(
                            "assets/logos/faviicons_glucks_care_dark.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.v10),

                  /// LOCATION TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address ?? "Location captured",
                          style: const TextStyle(
                            color: TColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.v13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: TSizes.v4),
                        Text(
                          "Lat ${latitude.toStringAsFixed(6)}, "
                          "Lng ${longitude.toStringAsFixed(6)}",
                          style: const TextStyle(
                            color: TColors.white70,
                            fontSize: TSizes.v11,
                          ),
                        ),
                        const SizedBox(height: TSizes.v4),
                        Text(
                          "${DateFormat("EEE, dd/MM/yyyy • hh:mm a").format(capturedAt)} "
                          "GMT${_formatGmtOffset(capturedAt)}",
                          style: const TextStyle(
                            color: TColors.white70,
                            fontSize: TSizes.v11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGmtOffset(DateTime dateTime) {
    final offset = dateTime.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return "$sign$hours:$minutes";
  }
}
