import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_master_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('beat-list area links drive colors without top-level beatAreas', () {
    final master = parseMapBeatMaster({
      'areas': [
        {
          'id': 'a',
          'pincode': '847101',
          'colors': ['#FF0000']
        }
      ],
      'beats': [
        {
          'id': 'b',
          'color': '#4363D8',
          'areaIds': ['a']
        },
        {
          'id': 'c',
          'color': '#3CB44B',
          'areas': [
            {'id': 'a'}
          ]
        },
      ],
    });
    expect(mapBeatMembershipsForPincode(master, '847101').map((b) => b.color),
        ['#4363D8', '#3CB44B']);
  });

  test('shared pincode retains all active beat memberships and colors', () {
    final master = parseMapBeatMaster({
      'areas': [
        {'id': 'a', 'pincode': '846004'},
        {'id': 'b', 'pincode': '846004'},
      ],
      'beats': [
        {'id': 'first', 'color': '#4363D8'},
        {'id': 'second', 'color': '#F58231'},
        {'id': 'inactive', 'color': '#E6194B', 'active': false},
      ],
      'beatAreas': [
        {
          'beatId': 'first',
          'areaId': ['a', 'b']
        },
        {
          'beatId': 'second',
          'areaId': ['a']
        },
        {
          'beatId': 'inactive',
          'areaId': ['a']
        },
      ],
    });
    final beats = mapBeatMembershipsForPincode(master, '846004');
    expect(beats.map((b) => b.id), ['first', 'second']);
    expect(beats.map((b) => b.color), ['#4363D8', '#F58231']);
  });

  test('all 39 Darbhanga postal pincodes match API areas without visit data',
      () async {
    // Pincodes from the supplied territory/master areas response.
    final registeredPins =
        '847337 847115 847422 847407 847204 847405 847427 846010 '
                '847203 847105 847202 847103 847201 847423 847233 846009 '
                '847429 846001 846002 846008 846006 846004 847428 846003 '
                '847301 847101 847106 847107 847302 847307 847123 847104 '
                '847306 846005 846007 847122 847121 847304 847303'
            .split(' ');
    final registry = MapBeatAreaRegistry.fromJson({
      'areas': [
        for (final pin in registeredPins)
          {
            'id': 'area-$pin',
            'pincode': pin,
            'doctorCount': 0,
            'latitude': 0,
            'longitude': 0,
            'colors': [],
            'geoJSON': null,
          },
      ],
      'doctors': [],
      'chemists': [],
      'stockists': [],
      'beats': [],
      'beatAreas': [],
    });
    final asset = jsonDecode(await rootBundle
        .loadString('lib/utils/json_data/datagov_pincodes.geojson')) as Map;
    final darbhanga = (asset['features'] as List)
        .map((feature) => feature['properties'] as Map)
        .where((properties) =>
            properties['Division'].toString().trim() == 'Darbhanga')
        .toList();
    expect(darbhanga, hasLength(39));
    for (final properties in darbhanga) {
      final pin = properties['Pincode'].toString();
      expect(registry.colorFor(pin), TColors.success, reason: pin);
    }
    expect(registry.colorFor('847239'), TColors.error);
  });

  test('Darbhanga registered pincodes are green without doctors or geometry',
      () {
    final registry = MapBeatAreaRegistry.fromJson({
      'success': true,
      'areas': [
        {
          'id': '3f2d3886-abcb-4f83-88f7-f6c274cce2dd',
          'postOffice': 'Darbhanga HO',
          'pincode': '846004',
          'latitude': 0,
          'longitude': 0,
          'doctorCount': 0,
          'colors': [],
          'geoJSON': null
        },
        {
          'id': '45e36ab3-039c-4681-9ff5-d9a9edc96225',
          'postOffice': 'Laheriasarai HO',
          'pincode': '846001',
          'doctorCount': 0
        },
        {
          'id': '1db2540c-1708-4a7a-9095-1bd11293b418',
          'postOffice': 'Anandpur SO',
          'pincode': '847101',
          'doctorCount': 0
        },
      ],
      'doctors': [],
      'chemists': [],
      'stockists': [],
    });
    for (final pincode in ['846004', '846001', '847101']) {
      expect(registry.colorFor(pincode), TColors.success);
      expect(registry.idsFor(pincode), hasLength(1));
    }
  });

  test('missing or empty area ID is red even if visit entities exist', () {
    final registry = MapBeatAreaRegistry.fromJson({
      'areas': [
        {'pincode': '846004', 'id': ''},
        {'pincode': '846001', 'id': '   '},
      ],
      'doctors': [
        {'id': 'doctor', 'areaId': 'doctor-area', 'pincode': '846004'}
      ],
      'chemists': [
        {'id': 'chemist', 'pincode': '847101'}
      ],
    });
    for (final pincode in ['846004', '846001', '847101']) {
      expect(registry.colorFor(pincode), TColors.error);
      expect(registry.idsFor(pincode), isEmpty);
    }
  });

  test('multiple registered areas sharing a pincode retain all their IDs', () {
    final registry = MapBeatAreaRegistry.fromJson({
      'areas': [
        {'id': 'first', 'pincode': ' 846004 '},
        {'id': 'second', 'pincode': '846004'},
        {'id': '', 'pincode': '846004'},
      ]
    });
    expect(registry.idsFor('846004'), {'first', 'second'});
    expect(registry.colorFor(' 846004 '), TColors.success);
  });

  test('missing areas list is not treated as every pincode being unregistered',
      () {
    expect(() => MapBeatAreaRegistry.fromJson({'success': true}),
        throwsFormatException);
  });

  test(
      'API grouped beat links preserve every area for existing beat operations',
      () {
    final master = parseMapBeatMaster({
      'areas': [],
      'beatAreas': [
        {
          'beatId': 'beat-1',
          'areaId': ['area-1', 'area-2']
        },
        {
          'beatId': 'beat-2',
          'areaId': ['area-3']
        },
      ]
    });
    expect(master.beatAreas.map((link) => '${link.beatId}:${link.areaId}'),
        ['beat-1:area-1', 'beat-1:area-2', 'beat-2:area-3']);
  });

  test('legacy scalar beat links continue to work', () {
    final master = parseMapBeatMaster({
      'areas': [],
      'beatAreas': [
        {'beat_id': 'beat-1', 'area_id': 'area-1'},
        {'beatId': 'beat-2', 'areaId': 'area-2'},
      ]
    });
    expect(master.beatAreas.map((link) => '${link.beatId}:${link.areaId}'),
        ['beat-1:area-1', 'beat-2:area-2']);
  });
}
