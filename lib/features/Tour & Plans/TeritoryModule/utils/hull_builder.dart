import 'dart:math';

import 'package:latlong2/latlong.dart';

class HullBuilder {

  static List<LatLng> convexHull(List<LatLng> points) {

    if (points.length <= 3) {
      return List.from(points);
    }

    final pts = List<LatLng>.from(points);

    pts.sort((a, b) {

      if (a.longitude == b.longitude) {
        return a.latitude.compareTo(b.latitude);
      }

      return a.longitude.compareTo(b.longitude);

    });

    final lower = <LatLng>[];

    for (final p in pts) {

      while (
      lower.length >= 2 &&
          _cross(
            lower[lower.length - 2],
            lower.last,
            p,
          ) <=
              0) {

        lower.removeLast();

      }

      lower.add(p);

    }

    final upper = <LatLng>[];

    for (final p in pts.reversed) {

      while (
      upper.length >= 2 &&
          _cross(
            upper[upper.length - 2],
            upper.last,
            p,
          ) <=
              0) {

        upper.removeLast();

      }

      upper.add(p);

    }

    lower.removeLast();

    upper.removeLast();

    return [
      ...lower,
      ...upper,
    ];

  }

  static double _cross(
      LatLng o,
      LatLng a,
      LatLng b,
      ) {

    return (a.longitude - o.longitude) *
        (b.latitude - o.latitude) -
        (a.latitude - o.latitude) *
            (b.longitude - o.longitude);

  }

}