import '../../model/area_model.dart';
import 'map_beat_geometry.dart';

/// Local map draft; API area IDs remain independent of display boundaries.
class MapBeatSelection {
  final areaIds = <String>{};
  final postOffices = <String, MapBeatRegion>{};

  void toggle(MapBeatRegion pincode, List<AreaModel> areas) {
    final registered = areas.where((a) => a.id.trim().isNotEmpty).toList();
    final selected = postOffices.containsKey(pincode.name) ||
        registered.any((a) => areaIds.contains(a.id));
    if (selected) {
      postOffices.remove(pincode.name);
      areaIds.removeAll(registered.map((a) => a.id));
    } else {
      postOffices[pincode.name] = pincode;
      areaIds.addAll(registered.map((a) => a.id));
    }
  }
}
