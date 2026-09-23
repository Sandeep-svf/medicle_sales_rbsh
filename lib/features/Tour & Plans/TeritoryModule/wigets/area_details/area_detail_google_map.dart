import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../controller/area_detail_controller.dart';
import '../../model/area_model.dart';
import 'entity_marker.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

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
                color: TColors.materialBlue.withOpacity(.15),
                borderColor: TColors.materialBlue,
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
                width: TSizes.v160,
                height: TSizes.v50,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: TColors.white,
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
                width: TSizes.v40,
                height: TSizes.v40,
                child: GestureDetector(
                  onTap: () {
                    debugPrint(
                      "Doctor Area : ${doctor.areaId}",
                    );
                  },
                  child: EntityMarker(
                    icon: Icons.local_hospital,
                    color: TColors.materialRed,
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
                width: TSizes.v40,
                height: TSizes.v40,
                child: EntityMarker(
                  icon: Icons.local_pharmacy,
                  color: TColors.materialGreen,
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
                width: TSizes.v40,
                height: TSizes.v40,
                child: EntityMarker(
                  icon: Icons.store,
                  color: TColors.materialOrange,
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
