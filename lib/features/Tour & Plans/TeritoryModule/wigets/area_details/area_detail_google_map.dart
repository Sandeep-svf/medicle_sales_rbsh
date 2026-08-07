import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../controller/area_detail_controller.dart';
import '../../model/area_model.dart';
import 'entity_marker.dart';

class AreaDetailGoogleMap extends StatelessWidget {
  final AreaModel area;

  const AreaDetailGoogleMap({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AreaDetailController>(
      tag: area.id,
    );

    return Obx(
          () => FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            area.latitude,
            area.longitude,
          ),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.medicle.sales',
          ),

          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(
                  area.latitude,
                  area.longitude,
                ),
                radius: controller.dynamicRadius.value,
                useRadiusInMeter: true,
                color: Colors.blue.withOpacity(.15),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            ],
          ),

          /// Area Name
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  area.latitude,
                  area.longitude,
                ),
                width: 160,
                height: 50,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    area.postOffice,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          /// Doctor Markers
          MarkerLayer(
            markers: controller.areaDoctors.map((doctor) {
              return Marker(
                point: LatLng(
                  doctor.latitude,
                  doctor.longitude,
                ),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    debugPrint(
                      "Doctor Area : ${doctor.areaId}",
                    );
                  },
                  child: EntityMarker(
                    icon: Icons.local_hospital,
                    color: Colors.red,
                    onTap: () {
                      debugPrint(
                        "Doctor Area : ${doctor.areaId}",
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),

          /// chemist Markers
          MarkerLayer(
            markers: controller.areaChemists.map((chemist) {
              return Marker(
                point: LatLng(
                  chemist.latitude,
                  chemist.longitude,
                ),
                width: 40,
                height: 40,
                child: EntityMarker(
                  icon: Icons.local_pharmacy,
                  color: Colors.green,
                  onTap: () {
                    debugPrint(
                      "Chemist Area : ${chemist.areaId}",
                    );
                  },
                ),
              );
            }).toList(),
          ),
          /// Stockist Markers
          MarkerLayer(
            markers: controller.areaStockists.map((stockist) {
              return Marker(
                point: LatLng(
                  stockist.latitude,
                  stockist.longitude,
                ),
                width: 40,
                height: 40,
                child: EntityMarker(
                  icon: Icons.store,
                  color: Colors.orange,
                  onTap: () {
                    debugPrint(
                      "Stockist Area : ${stockist.areaId}",
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}