import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/utils/color_extension.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../model/beat_model.dart';
import '../utils/enumsclass.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class BeatCard extends GetView<TerritoryController> {
  final BeatModel beat;

  const BeatCard({
    super.key,
    required this.beat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.v2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: TSizes.v16,
                  height: TSizes.v60,
                  decoration: BoxDecoration(
                    color: beat.color.toColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: TSizes.v14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beat.beatName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.fontSizeLg,
                        ),
                      ),
                      const SizedBox(height: TSizes.v6),
                      Text(
                        DateFormat("dd MMM yyyy").format(beat.createdAt),
                        style: TextStyle(
                          color: TColors.materialGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "view":
                        controller.selectBeat(beat);

                        break;

                      case "edit":
                        controller.editBeat(beat);

                        break;

                      case "delete":
                        controller.deleteBeat(beat);
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: "view",
                      child: Text(TTexts.uiTextView),
                    ),
                    PopupMenuItem(
                      value: "edit",
                      child: Text(TTexts.uiTextEdit),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Text(TTexts.uiTextDelete),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: TSizes.v18),
            Row(
              children: [
                Expanded(
                  child: _tile(
                    Icons.location_on,
                    beat.areaCount.toString(),
                    "Areas",
                  ),
                ),
                const SizedBox(width: TSizes.v10),
                Expanded(
                  child: _tile(
                    Icons.local_hospital,
                    controller.doctorCountOfBeat(beat).toString(),
                    "Doctors",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: TColors.materialGrey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: TColors.primary,
          ),
          const SizedBox(height: TSizes.v6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: TSizes.v12,
            ),
          ),
        ],
      ),
    );
  }
}
