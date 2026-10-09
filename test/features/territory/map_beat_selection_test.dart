import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/model/area_model.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_geometry.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_selection.dart';

MapBeatRegion office(String code) => MapBeatRegion(
    code,
    [
      [
        [
          const LatLng(26, 85),
          const LatLng(26, 86),
          const LatLng(27, 86),
        ]
      ]
    ],
    'Office $code',
    'Darbhanga',
    circle: 'Bihar');
AreaModel area(String id, String pin) => AreaModel(
    id: id,
    headquarterId: 'hq',
    postOffice: 'Office $pin',
    pincode: pin,
    latitude: 0,
    longitude: 0);

void main() {
  test(
      'multiple map taps accumulate IDs; tapping selected pincode removes only it',
      () {
    final draft = MapBeatSelection();
    draft.toggle(office('846004'), [area('a', '846004'), area('b', '846004')]);
    draft.toggle(office('847101'), [area('c', '847101')]);
    expect(draft.areaIds, {'a', 'b', 'c'});
    expect(draft.postOffices.keys, containsAll(['846004', '847101']));
    draft.toggle(office('846004'), [area('a', '846004'), area('b', '846004')]);
    expect(draft.areaIds, {'c'});
    expect(draft.postOffices.keys, ['847101']);
    draft.toggle(office('846004'), [area('a', '846004'), area('b', '846004')]);
    expect(draft.areaIds, {'a', 'b', 'c'});
  });
  test('area already assigned to another beat remains selectable', () {
    final draft = MapBeatSelection();
    draft.toggle(office('846004'), [
      area('shared', '846004').copyWith(beatIds: ['existing-beat'])
    ]);
    expect(draft.areaIds, {'shared'});
  });
  test('unregistered postoffice toggles visually without inventing API IDs',
      () {
    final draft = MapBeatSelection();
    draft.toggle(office('846004'), [area('', '846004')]);
    expect(draft.areaIds, isEmpty);
    expect(draft.postOffices, hasLength(1));
    draft.toggle(office('846004'), []);
    expect(draft.postOffices, isEmpty);
  });
}
