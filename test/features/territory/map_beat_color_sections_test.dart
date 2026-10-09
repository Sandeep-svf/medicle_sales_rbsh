import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_geometry.dart';

void main() {
  test('shared fill covers the territory and preserves its hole', () {
    final area = MapBeatRegion(
        '123456',
        [
          [
            [
              const LatLng(0, 0),
              const LatLng(0, 6),
              const LatLng(6, 6),
              const LatLng(6, 0),
              const LatLng(0, 0),
            ],
            [
              const LatLng(2, 2),
              const LatLng(4, 2),
              const LatLng(4, 4),
              const LatLng(2, 4),
              const LatLng(2, 2),
            ]
          ]
        ],
        'Office',
        'Division');
    final sections = mapBeatColorSections(area, 3);
    expect(sections, hasLength(3));
    for (var i = 0; i < 3; i++) {
      expect(sections[i], isNotEmpty);
      expect(sections[i].any((p) => p.contains(LatLng(1, i * 2 + 1))), isTrue);
    }
    for (var lat = 0.5; lat < 6; lat++) {
      for (var lon = 0.5; lon < 6; lon++) {
        final point = LatLng(lat, lon);
        expect(sections.expand((s) => s).any((p) => p.contains(point)),
            area.contains(point));
      }
    }
    expect(area.parts.single, hasLength(2));
    expect(mapBeatColorSections(area, 1).single.single, same(area));
  });
}
