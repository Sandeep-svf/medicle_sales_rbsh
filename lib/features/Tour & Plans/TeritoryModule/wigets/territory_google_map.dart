import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'doctor_marker_widget.dart';


import '../../../../utils/constants/colors.dart';
import '../controller/territory_controller.dart';
import 'area_circle_widget.dart';

class TerritoryGoogleMap extends GetView<TerritoryController> {
  const TerritoryGoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FlutterMap(

        mapController: controller.mapController,

        options: MapOptions(



          initialCenter: controller.currentCenter.value,

          initialZoom: controller.currentZoom.value,

          minZoom: 5,

          maxZoom: 18,

          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),

          onPositionChanged: (position, hasGesture) {

            controller.currentZoom.value =
                position.zoom ?? 13;

          },

          onTap: (_, point) {

            print("TerritoryController ===== MAP TAP =====");

            final area = controller.areaFromPoint(point);

            print("TerritoryController Area : ${area?.postOffice}");

            if (area != null) {
              print("TerritoryController Selecting Area");
              controller.selectArea(area);
            } else {
              print("TerritoryController No Area Found");
            }
          },

          onSecondaryTap: (_, __) {},

          onLongPress: (_, __) {},

        ),

        children: [

          /////////////////////////////////////////////////////
          /// MAP
          /////////////////////////////////////////////////////

          TileLayer(

            urlTemplate:
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

            userAgentPackageName:
            "com.medicle.sales",

          ),

          /////////////////////////////////////////////////////
          /// AREA CIRCLE
          /////////////////////////////////////////////////////

          if(controller.showAreas.value)

            if (controller.showBeats.value)

              /// old one for beat edge

             /* PolygonLayer(





                polygons: controller.visibleBeats.map((beat) {

                  final areas = controller.beatAreasOf(beat);

                  if (areas.length < 2) {
                    return Polygon(points: []);
                  }

                  final points = [...areas]
                    ..sort((a, b) {
                      final lat = a.latitude.compareTo(b.latitude);
                      if (lat != 0) return lat;
                      return a.longitude.compareTo(b.longitude);
                    });

                  return Polygon(
                    hitValue: beat,
                    points: points
                        .map(
                          (e) => LatLng(
                        e.latitude,
                        e.longitude,
                      ),
                    )
                        .toList(),
                    color: controller.beatColor(beat).withOpacity(.18),
                    borderColor: controller.beatColor(beat),
                    borderStrokeWidth: 3,
                  );

                  // this is old one.
                 *//* return Polygon(

                    points: areas.map((e) {

                      return LatLng(
                        e.latitude,
                        e.longitude,
                      );

                    }).toList(),

                    color: controller
                        .beatColor(beat)
                        .withOpacity(.18),

                    borderColor:
                    controller.beatColor(beat),

                    borderStrokeWidth: 3,

                  );*//*

                }).toList(),

              ),*/

              /// new one for beat circle
              if (controller.showBeats.value)
                CircleLayer(
                  circles: controller.visibleBeats.map((beat) {

                    final areas = controller.beatAreasOf(beat);

                    if (areas.isEmpty) {
                      return CircleMarker(
                        point: controller.currentCenter.value,
                        radius: 0,
                      );
                    }

                    return CircleMarker(

                      point: controller.beatCenter(areas),

                      radius: controller.beatRadius(areas),

                      useRadiusInMeter: true,

                      color: controller
                          .beatColor(beat)
                          .withOpacity(.15),

                      borderColor: controller.beatColor(beat),

                      borderStrokeWidth: 3,

                    );

                  }).toList(),
                ),


          MarkerLayer(
            markers: controller.visibleBeats.map((beat) {

              final areas = controller.beatAreasOf(beat);

              if (areas.isEmpty) {
                return Marker(
                  point: controller.currentCenter.value,
                  width: 1,
                  height: 1,
                  child: const SizedBox(),
                );
              }

              final center = controller.beatCenter(areas);

              return Marker(
                point: center,
                width: 120,
                height: 40,
                child: GestureDetector(
                  onTap: () => controller.selectBeat(beat),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: controller.beatColor(beat),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      beat.beatName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          /// HEADQUARTER MARKERS
          MarkerLayer(
            markers: controller.headquarters.map((hq) {
              return Marker(
                point: LatLng(
                  hq.latitude,
                  hq.longitude,
                ),
                width: 46,
                height: 46,
                child: GestureDetector(
                  onTap: () => controller.changeHeadquarter(hq),
                  child: Container(
                    decoration: BoxDecoration(
                      color: controller.selectedHeadquarter.value?.id == hq.id
                          ? Colors.red
                          : Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

            CircleLayer(



              circles: controller.visibleAreas.map((area){
                final selected = controller.selectedAreas.any(
                      (e) => e.id == area.id,
                );

                return CircleMarker(

                  point: LatLng(
                    area.latitude,
                    area.longitude,
                  ),

                  radius: area.radius,

                  useRadiusInMeter: true,



                  color: selected
                      ? TColors.primary.withOpacity(.45)
                      : controller.isAreaInSelectedHeadquarter(area)
                      ? Colors.blue.withOpacity(.22)
                      : Colors.grey.withOpacity(.08),

                  borderColor: selected
                      ? TColors.primary
                      : controller.isAreaInSelectedHeadquarter(area)
                      ? Colors.blue
                      : Colors.grey,

                  borderStrokeWidth: selected ? 4 : 2,

                );

              }).toList(),

            ),

          if (controller.showAreaLabels)
          MarkerLayer(
            markers: controller.visibleAreas.map((area) {
              return Marker(
                point: LatLng(
                  area.latitude,
                  area.longitude,
                ),
                width: 110,
                height: 55,
                child: AreaCircleWidget(
                  area: area,
                ),
              );
            }).toList(),
          ),


          /////////////////////////////////////////////////////
          /// DOCTOR MARKERS
          /////////////////////////////////////////////////////

          if (controller.showDoctors.value &&
              controller.showDoctorMarkers)

            MarkerClusterLayerWidget(

              options: MarkerClusterLayerOptions(

                maxClusterRadius: 45,

                size: const Size(45, 45),

                disableClusteringAtZoom: 16,

                markers: controller.visibleDoctors.map((doctor){

                  return Marker(

                    point: LatLng(
                      doctor.latitude,
                      doctor.longitude,
                    ),

                    width: 44,

                    height: 44,

                    child: GestureDetector(

                      onTap: (){

                        controller.selectDoctor(
                          doctor,
                        );

                      },

                      child: DoctorMarkerWidget(
                        doctor: doctor,
                        selected: controller.selectedAreas.any(
                              (area) => area.id == doctor.areaId,
                        ),
                      ),

                    ),

                  );

                }).toList(),

                builder: (context, markers){

                  return Container(

                    decoration: BoxDecoration(

                      color: TColors.primary,

                      shape: BoxShape.circle,

                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),

                    ),

                    child: Center(

                      child: Text(

                        markers.length.toString(),

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ),

                  );

                },

              ),

            ),

        ],

      );
    });
  }
}