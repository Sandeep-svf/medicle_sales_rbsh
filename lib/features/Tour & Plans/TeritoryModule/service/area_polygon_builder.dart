import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/area_model.dart';

class AreaPolygonBuilder {
  static List<Polygon> build({
    required AreaModel area,
    required List<Color> colors,
  }) {
    debugPrint(
      "AreaPolygonBuilder -> Area: ${area.postOffice}",
    );

    debugPrint(
      "AreaPolygonBuilder -> Boundary Count: ${area.outerBoundary.length}",
    );

    if (area.outerBoundary.isNotEmpty) {
      for (int i = 0; i < area.outerBoundary.length; i++) {
        final point = area.outerBoundary[i];

        debugPrint(
          "AreaPolygonBuilder -> Point[$i] "
              "Lat: ${point.latitude}, "
              "Lng: ${point.longitude}",
        );
      }
    }

    if (area.outerBoundary.length < 3) {
      debugPrint(
        "AreaPolygonBuilder -> Skipping ${area.postOffice}. "
            "Need at least 3 boundary points.",
      );
      return [];
    }

    final points = area.outerBoundary
        .map(
          (e) => LatLng(
        e.latitude,
        e.longitude,
      ),
    )
        .toList();

    debugPrint(
      "AreaPolygonBuilder -> Drawing polygon for ${area.postOffice} "
          "with ${points.length} points.",
    );

    final fillColor = colors.isNotEmpty
        ? colors.first.withOpacity(.28)
        : Colors.red.withOpacity(.4); // temporary debug color

    final borderColor = colors.isNotEmpty
        ? colors.first
        : Colors.red;

    return [
      Polygon(
        points: points,
        color: fillColor,
        borderColor: borderColor,
        borderStrokeWidth: 5, // temporary debug
      ),
    ];
  }
}