import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/area_detail_controller.dart';
import '../model/area_model.dart';
import '../model/chemist_location_model.dart';
import '../model/doctor_location_model.dart';
import '../model/stockist_location_model.dart';
import '../wigets/area_details/area_detail_google_map.dart';

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
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Entities",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 16),

            _LegendItem(
              icon: Icons.local_hospital,
              color: Colors.red,
              title: "Doctors",
              count: doctorCount,
            ),

            const SizedBox(height: 8),

            _LegendItem(
              icon: Icons.local_pharmacy,
              color: Colors.green,
              title: "Chemists",
              count: chemistCount,
            ),

            const SizedBox(height: 8),

            _LegendItem(
              icon: Icons.store,
              color: Colors.orange,
              title: "Stockists",
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
          radius: 11,
          backgroundColor: color.withOpacity(.15),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}