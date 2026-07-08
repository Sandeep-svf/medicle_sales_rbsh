import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/territory_controller.dart';

class BeatLegend extends GetView<TerritoryController> {
  const BeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.beats.isEmpty) {
        return const SizedBox();
      }

      return Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Beats",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            ...controller.beats.map((beat) {

              final selected =
                  controller.selectedBeat.value?.id == beat.id;

              return InkWell(
                onTap: () {

                  if (selected) {
                    controller.selectedBeat.value = null;
                  } else {
                    controller.selectBeat(beat);
                  }

                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? controller.beatColor(beat).withOpacity(.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [

                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: controller.beatColor(beat),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          beat.beatName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }),

          ],
        ),
      );
    });
  }
}