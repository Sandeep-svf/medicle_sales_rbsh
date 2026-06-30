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

            controller.selectedArea.value = null;

            controller.selectedDoctor.value = null;

          },

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

              PolygonLayer(

                polygons: controller.visibleBeats.map((beat) {

                  final areas = controller.beatAreasOf(beat);

                  if (areas.length < 2) {
                    return Polygon(points: []);
                  }

                  return Polygon(

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

                  );

                }).toList(),

              ),

          MarkerLayer(

            markers: controller.visibleBeats.map((beat){

              final areas = controller.beatAreasOf(beat);

              if (areas.isEmpty) {

                return Marker(

                  point: controller.currentCenter.value,

                  child: const SizedBox(),

                );

              }

              final first = areas.first;

              return Marker(

                point: LatLng(
                  first.latitude,
                  first.longitude,
                ),

                width: 140,

                height: 44,

                child: Container(

                  alignment: Alignment.center,

                  decoration: BoxDecoration(

                    color: controller.beatColor(beat),

                    borderRadius:
                    BorderRadius.circular(30),

                    boxShadow: const [

                      BoxShadow(

                        blurRadius: 8,

                        color: Colors.black26,

                      )

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
                ? TColors.primary.withOpacity(.35)
                    : Colors.blue.withOpacity(.15),

                borderColor: selected
                ? TColors.primary
                    : Colors.blue,

                  borderStrokeWidth: 2,

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