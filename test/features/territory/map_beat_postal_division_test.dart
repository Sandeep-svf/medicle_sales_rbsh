import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_geometry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MapBeatRegion> pincodes;

  setUpAll(() async {
    pincodes = parseMapBeatPincodes(await rootBundle
            .loadString('lib/utils/json_data/datagov_pincodes.geojson'))
        .areas;
  });

  test('Darbhanga contains all 39 postal pincodes and excludes Singhia', () {
    final selected = selectMapBeatDistrictPincodes(pincodes, 'Darbhanga');
    expect(selected, hasLength(39));
    expect(selected.every((p) => p.division.trim() == 'Darbhanga'), isTrue);
    expect(selected.map((p) => p.name), isNot(contains('848209')));
    expect(selected.map((p) => p.name), contains('847122'));
    for (final region in selected) {
      // Keep original full geometry, including portions outside district bounds.
      expect(
          identical(region, pincodes.firstWhere((p) => p.name == region.name)),
          isTrue);
    }
  });

  test('Singhia belongs only to the Samastipur postal view', () {
    final selected = selectMapBeatDistrictPincodes(pincodes, 'Samastipur');
    expect(selected.map((p) => p.name), contains('848209'));
    expect(selected.every((p) => p.division.trim() == 'Samastipur'), isTrue);
    expect(selected.map((p) => p.name), isNot(contains('846004')));
  });

  test('known district spelling aliases select the bundled postal divisions',
      () {
    for (final entry in {
      'Purnia': 'Purnea',
      'Nawada': 'Nawadha',
      'Aurangabad': 'AurangabadBihar',
      'Katihar': 'al Office Katihar',
    }.entries) {
      final selected = selectMapBeatDistrictPincodes(pincodes, entry.key);
      expect(selected, isNotEmpty, reason: entry.key);
      expect(selected.every((p) => p.division.trim() == entry.value), isTrue);
    }
  });

  test('Patna includes its three explicitly named postal divisions', () {
    final selected = selectMapBeatDistrictPincodes(pincodes, 'Patna');
    expect(selected.map((p) => p.division.trim()).toSet(),
        {'Patna', 'PATNA SAHIB', 'Patna GPO'});
  });

  test('unmapped districts do not fall back to overlapping neighboring areas',
      () {
    expect(selectMapBeatDistrictPincodes(pincodes, 'Araria'), isEmpty);
    expect(
        selectMapBeatDistrictPincodes(pincodes, 'Unknown district'), isEmpty);
  });

  test('matching tolerates whitespace and case but excludes other circles', () {
    final source = pincodes.firstWhere((p) => p.name == '846004');
    final otherCircle = MapBeatRegion(
        source.name, source.parts, source.office, 'Darbhanga',
        circle: 'Other state');
    final selected =
        selectMapBeatDistrictPincodes([source, otherCircle], '  DARBHANGA  ');
    expect(selected, [source]);
  });
}
