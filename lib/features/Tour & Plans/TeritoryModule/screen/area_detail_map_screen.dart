import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/area_detail_controller.dart';
import '../model/area_model.dart';
import '../model/chemist_location_model.dart';
import '../model/doctor_location_model.dart';
import '../model/stockist_location_model.dart';
import '../wigets/area_details/area_detail_google_map.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class AreaDetailMapScreen extends StatelessWidget {
  final AreaModel area;

  final List<DoctorLocationModel> doctors;
  final List<ChemistLocationModel> chemists;
  final List<StockistLocationModel> stockists;

  AreaDetailMapScreen({
    super.key,
    required this.area,
    required this.doctors,
    required this.chemists,
    required this.stockists,
  }) {
    Get.put(
      AreaDetailController(
        area: area,
        doctors: doctors,
        chemists: chemists,
        stockists: stockists,
      ),
      tag: area.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AreaDetailController>(
      tag: area.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(area.postOffice),
      ),
      body: Stack(
        children: [
          AreaDetailGoogleMap(
            area: area,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: AreaMapLegend(
              doctorCount: controller.areaDoctors.length,
              chemistCount: controller.areaChemists.length,
              stockistCount: controller.areaStockists.length,
            ),
          ),
        ],
      ),
    );
  }
}

class AreaMapLegend extends StatelessWidget {
  final int doctorCount;
  final int chemistCount;
  final int stockistCount;

  const AreaMapLegend({
    super.key,
    required this.doctorCount,
    required this.chemistCount,
    required this.stockistCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.v6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: TSizes.v190,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              TTexts.uiTextEntities,
              style: TextStyle(
                fontSize: TSizes.v15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: TSizes.v16),
            _LegendItem(
              icon: Icons.local_hospital,
              color: TColors.materialRed,
              title: TTexts.uiTextDoctors,
              count: doctorCount,
            ),
            const SizedBox(height: TSizes.v8),
            _LegendItem(
              icon: Icons.local_pharmacy,
              color: TColors.materialGreen,
              title: TTexts.uiTextChemists,
              count: chemistCount,
            ),
            const SizedBox(height: TSizes.v8),
            _LegendItem(
              icon: Icons.store,
              color: TColors.materialOrange,
              title: TTexts.uiTextStockists,
              count: stockistCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final int count;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: TSizes.v11,
          backgroundColor: color.withOpacity(.15),
          child: Icon(
            icon,
            size: TSizes.v14,
            color: color,
          ),
        ),
        const SizedBox(width: TSizes.v10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: TSizes.v13,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$count",
            style: const TextStyle(
              color: TColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
