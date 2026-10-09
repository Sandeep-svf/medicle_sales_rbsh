import 'dart:convert';
import 'package:clipper2/clipper2.dart' as clip;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBeatGeoData {
  const MapBeatGeoData(this.areas, this.bounds);
  final List<MapBeatRegion> areas;
  final LatLngBounds bounds;
}

/// Bihar's district picker opens postal territories, not geometric overlaps.
/// Preserve the complete pincode polygons belonging to the chosen division.
List<MapBeatRegion> selectMapBeatDistrictPincodes(
    List<MapBeatRegion> areas, String districtName) {
  String normalize(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final district = normalize(districtName);
  const aliases = <String, Set<String>>{
    'aurangabad': {'aurangabad', 'aurangabadbihar'},
    'purnia': {'purnia', 'purnea'},
    'nawada': {'nawada', 'nawadha'},
    'patna': {'patna', 'patna sahib', 'patna gpo'},
    // This is the literal Katihar division name in the bundled GeoJSON.
    'katihar': {'katihar', 'al office katihar'},
  };
  final divisions = aliases[district] ?? {district};
  return areas
      .where((area) =>
          normalize(area.circle) == 'bihar' &&
          divisions.contains(normalize(area.division)))
      .toList();
}

MapBeatGeoData parseMapBeatDistricts(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  final features = json['features'] as List<dynamic>? ?? const [];
  final districts = <MapBeatRegion>[];
  final allPoints = <LatLng>[];

  for (final feature in features) {
    if (feature is! Map<String, dynamic>) continue;
    final properties = feature['properties'];
    final geometry = feature['geometry'];
    if (properties is! Map<String, dynamic> ||
        geometry is! Map<String, dynamic>) {
      continue;
    }

    final name = properties['district']?.toString().trim();
    final coordinates = geometry['coordinates'];
    if (name == null || name.isEmpty || coordinates is! List) continue;

    final type = geometry['type'];
    final rawPolygons = type == 'Polygon'
        ? <dynamic>[coordinates]
        : type == 'MultiPolygon'
            ? coordinates
            : const <dynamic>[];
    final parts = <List<List<LatLng>>>[];

    for (final rawPolygon in rawPolygons) {
      if (rawPolygon is! List) continue;
      final rings = <List<LatLng>>[];
      for (final rawRing in rawPolygon) {
        if (rawRing is! List) continue;
        final points = <LatLng>[];
        for (final coordinate in rawRing) {
          if (coordinate is! List ||
              coordinate.length < 2 ||
              coordinate[0] is! num ||
              coordinate[1] is! num) {
            continue;
          }
          // GeoJSON stores longitude first; flutter_map uses latitude first.
          points.add(LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          ));
        }
        if (points.length >= 3) {
          rings.add(points);
          allPoints.addAll(points);
        }
      }
      if (rings.isNotEmpty) parts.add(rings);
    }
    if (parts.isNotEmpty) districts.add(MapBeatRegion(name, parts, "", ""));
  }

  if (districts.isEmpty) {
    throw const FormatException('No Bihar district boundaries were found.');
  }

  return MapBeatGeoData(districts, LatLngBounds.fromPoints(allPoints));
}

class MapBeatRegion {
  MapBeatRegion(this.name, this.parts, this.office, this.division,
      {this.circle = ''})
      : bounds = LatLngBounds.fromPoints(
            parts.expand((rings) => rings.first).toList());

  final String name;
  final String office;
  final String division;
  final String circle;
  final LatLngBounds bounds;
  final List<List<List<LatLng>>> parts;

  bool contains(LatLng point) {
    if (!bounds.contains(point)) return false;
    for (final rings in parts) {
      if (_insideRing(rings.first, point) &&
          !rings.skip(1).any((hole) => _insideRing(hole, point))) {
        return true;
      }
    }
    return false;
  }

  static bool _insideRing(List<LatLng> ring, LatLng point) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final a = ring[i];
      final b = ring[j];
      final crossesLatitude =
          (a.latitude > point.latitude) != (b.latitude > point.latitude);
      if (crossesLatitude &&
          point.longitude <
              (b.longitude - a.longitude) *
                      (point.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude) {
        inside = !inside;
      }
    }
    return inside;
  }
}

MapBeatGeoData parseMapBeatPincodes(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  final features = json['features'] as List<dynamic>? ?? const [];
  final areas = <MapBeatRegion>[];
  final allPoints = <LatLng>[];

  for (final feature in features) {
    if (feature is! Map<String, dynamic>) continue;
    final properties = feature['properties'];
    final geometry = feature['geometry'];
    if (properties is! Map<String, dynamic> ||
        geometry is! Map<String, dynamic>) {
      continue;
    }

    final name = properties['Pincode']?.toString().trim();
    final coordinates = geometry['coordinates'];
    if (name == null || name.isEmpty || coordinates is! List) continue;

    final type = geometry['type'];
    final rawPolygons = type == 'Polygon'
        ? <dynamic>[coordinates]
        : type == 'MultiPolygon'
            ? coordinates
            : const <dynamic>[];
    final parts = <List<List<LatLng>>>[];

    for (final rawPolygon in rawPolygons) {
      if (rawPolygon is! List) continue;
      final rings = <List<LatLng>>[];
      for (final rawRing in rawPolygon) {
        if (rawRing is! List) continue;
        final points = <LatLng>[];
        for (final coordinate in rawRing) {
          if (coordinate is! List ||
              coordinate.length < 2 ||
              coordinate[0] is! num ||
              coordinate[1] is! num) {
            continue;
          }
          // GeoJSON stores longitude first; flutter_map uses latitude first.
          points.add(LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          ));
        }
        if (points.length >= 3) {
          rings.add(points);
          allPoints.addAll(points);
        }
      }
      if (rings.isNotEmpty) parts.add(rings);
    }
    if (parts.isNotEmpty) {
      areas.add(MapBeatRegion(
        name,
        parts,
        properties['Office_Name']?.toString().trim() ?? '',
        properties['Division']?.toString().trim() ?? '',
        circle: properties['Circle']?.toString().trim() ?? '',
      ));
    }
  }

  if (areas.isEmpty) {
    throw const FormatException('No pincode boundaries were found.');
  }
  return MapBeatGeoData(areas, LatLngBounds.fromPoints(allPoints));
}

// Work off the UI thread. Both rendering and hit testing consume these areas.
List<MapBeatRegion> clipMapBeatPincodes(
    ({
      List<MapBeatRegion> areas,
      List<List<List<LatLng>>> districtParts
    }) input) {
  const scale = 10000000.0;
  clip.Paths64 paths(List<List<List<LatLng>>> parts) {
    final result = <clip.Path64>[];
    for (final rings in parts) {
      for (var index = 0; index < rings.length; index++) {
        final path = rings[index]
            .map((point) => clip.Point64((point.longitude * scale).round(),
                (point.latitude * scale).round()))
            .toList();
        // Non-zero filling requires holes to have opposite winding.
        final positive = clip.Path64Ext(path).isPositive;
        result.add(positive == (index == 0) ? path : path.reversed.toList());
      }
    }
    return result;
  }

  final districtPaths = paths(input.districtParts);
  final bounds = LatLngBounds.fromPoints(
      input.districtParts.expand((rings) => rings.first).toList());
  final clipped = <MapBeatRegion>[];
  for (final area in input.areas) {
    if (!area.bounds.isOverlapping(bounds)) continue;
    final engine = clip.Clipper64()
      ..addSubjects(paths(area.parts))
      ..addClips(districtPaths);
    final solution =
        engine.executeTree(clip.ClipType.intersection, clip.FillRule.nonZero);
    if (solution == null) {
      throw FormatException('Unable to clip pincode ${area.name}.');
    }
    final parts = <List<List<LatLng>>>[];
    List<LatLng> ring(clip.Path64 path) =>
        path.map((point) => LatLng(point.y / scale, point.x / scale)).toList();
    void collect(clip.PolyPath64 node) {
      final polygon = node.polygon;
      if (!node.isHole && polygon != null && polygon.length >= 3) {
        parts.add([
          ring(polygon),
          for (final child in node.children)
            if (child.isHole &&
                child.polygon != null &&
                child.polygon!.length >= 3)
              ring(child.polygon!),
        ]);
      }
      // Islands inside holes become separate polygon parts.
      for (final child in node.children) {
        collect(child);
      }
    }

    for (final node in solution.tree.children) {
      collect(node);
    }
    if (parts.isNotEmpty) {
      clipped.add(MapBeatRegion(area.name, parts, area.office, area.division,
          circle: area.circle));
    }
  }
  return clipped;
}

/// Split only the display fill; the original territory remains selectable as one.
List<List<MapBeatRegion>> mapBeatColorSections(
    MapBeatRegion region, int count) {
  if (count < 1) return [];
  if (count == 1) {
    return [
      [region]
    ];
  }
  final bounds = region.bounds;
  final width = (bounds.east - bounds.west) / count;
  return List.generate(count, (index) {
    final west = bounds.west + width * index;
    final east = index == count - 1 ? bounds.east : west + width;
    return clipMapBeatPincodes((
      areas: [region],
      districtParts: [
        [
          [
            LatLng(bounds.south, west),
            LatLng(bounds.south, east),
            LatLng(bounds.north, east),
            LatLng(bounds.north, west),
            LatLng(bounds.south, west),
          ]
        ]
      ]
    ));
  });
}
