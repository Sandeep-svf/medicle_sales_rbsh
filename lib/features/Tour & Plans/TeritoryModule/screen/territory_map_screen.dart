import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/territory_controller.dart';
import '../wigets/beat_creation_panel.dart';
import '../wigets/beat_legend.dart';
import '../wigets/headquarter_selector.dart';
import '../wigets/offline_map_toggle.dart';
import '../wigets/territory_bottom_panel.dart';
import '../wigets/territory_google_map.dart';
import '../wigets/territory_top_bar.dart';

class TerritoryMapScreen extends GetView<TerritoryController> {
  const TerritoryMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(
      TerritoryController(),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: Stack(
          children: [

            /// MAP
            const Positioned.fill(
              child: TerritoryGoogleMap(),
            ),

            /// TOP BAR
            const Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: TerritoryTopBar(),
            ),


            const Positioned(
              top: 150,
              right: 12,
              child: BeatLegend(),
            ),

            /// HQ SELECTOR
            const Positioned(
              top: 82,
              left: 12,
              right: 12,
              child: HeadquarterSelector(),
            ),

            /// offline map toggle
            const Positioned(

              top: 80,

              left: 12,

              right: 12,

              child: OfflineMapToggle(),

            ),

            /// BOTTOM PANEL
            const Align(

              alignment: Alignment.bottomCenter,

              child: BeatCreationPanel(),

            ),

            const Align(

              alignment: Alignment.bottomCenter,

              child: TerritoryBottomPanel(),

            ),

          ],
        ),
      ),

      //floatingActionButton: const TerritoryFab(),
    );
  }
}