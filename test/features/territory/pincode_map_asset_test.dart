import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_geometry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Map Beat Management startup assets produce usable map geometry', () async {
    final districts = parseMapBeatDistricts(await rootBundle.loadString(
        'lib/utils/json_data/bihar_json.geojson'));
    final pincodes = parseMapBeatPincodes(await rootBundle.loadString(
        'lib/utils/json_data/datagov_pincodes.geojson'));
    expect(districts.areas, isNotEmpty);
    expect(pincodes.areas, isNotEmpty);
    expect(districts.bounds.north, greaterThan(districts.bounds.south));
    expect(pincodes.bounds.east, greaterThan(pincodes.bounds.west));
  });

  test('Pincode Territory bundles usable pincode boundaries', () async {
    final source = await rootBundle.loadString(
        'lib/utils/json_data/datagov_pincodes.geojson');
    expect(source.trim(), isNotEmpty);
    final data = jsonDecode(source) as Map<String, dynamic>;
    expect(data['type'], 'FeatureCollection');
    final features = data['features'] as List<dynamic>;
    expect(features, isNotEmpty);
    for (final feature in features) {
      final properties = feature['properties'] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      expect(properties['Pincode'].toString(), matches(RegExp(r'^\d{6}$')));
      expect(geometry['type'], anyOf('Polygon', 'MultiPolygon'));
      expect(geometry['coordinates'] as List, isNotEmpty);
    }
  });
}
