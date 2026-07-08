import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AreaPolygonBuilder {

  static List<Polygon> build({

    required LatLng center,

    required double radius,

    required List<Color> colors,

  }) {

    if (colors.isEmpty) {

      return [

        _sector(

          center: center,

          radius: radius,

          startAngle: 0,

          sweepAngle: 360,

          color: Colors.grey.withOpacity(.12),

          border: Colors.grey,

        ),

      ];

    }

    final sweep = 360 / colors.length;

    final List<Polygon> polygons = [];

    for (int i = 0; i < colors.length; i++) {

      polygons.add(

        _sector(

          center: center,

          radius: radius,

          startAngle: sweep * i,

          sweepAngle: sweep,

          color: colors[i].withOpacity(.28),

          border: colors[i],

        ),

      );

    }

    return polygons;

  }

  static Polygon _sector({

    required LatLng center,

    required double radius,

    required double startAngle,

    required double sweepAngle,

    required Color color,

    required Color border,

  }) {

    const earthRadius = 6378137.0;

    final List<LatLng> points = [];

    points.add(center);

    for (double a = startAngle;
    a <= startAngle + sweepAngle;
    a += 4) {

      final rad = a * pi / 180;

      final dx = radius * cos(rad);

      final dy = radius * sin(rad);

      final lat =
          center.latitude +
              (dy / earthRadius) * 180 / pi;

      final lng =
          center.longitude +
              (dx /
                  (earthRadius *
                      cos(center.latitude * pi / 180))) *
                  180 /
                  pi;

      points.add(
        LatLng(lat, lng),
      );

    }

    points.add(center);

    return Polygon(

      points: points,

      color: color,

      borderColor: border,

      borderStrokeWidth: 2,

    );

  }

}