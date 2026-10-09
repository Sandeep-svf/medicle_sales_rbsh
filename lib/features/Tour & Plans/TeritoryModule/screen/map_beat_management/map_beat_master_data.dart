import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../model/territory_master_model.dart';
import '../../model/beat_model.dart';

List<BeatModel> mapBeatMembershipsForPincode(
    TerritoryMasterModel? master, String pincode) {
  if (master == null) return [];
  final areaIds = master.areas
      .where((area) => area.pincode.trim() == pincode.trim())
      .map((area) => area.id)
      .toSet();
  final beatIds = master.beatAreas
      .where((link) => areaIds.contains(link.areaId))
      .map((link) => link.beatId)
      .toSet();
  return master.beats
      .where((beat) => beat.active && beatIds.contains(beat.id))
      .toList();
}

/// Registration comes exclusively from the API's areas, not visit entities.
class MapBeatAreaRegistry {
  MapBeatAreaRegistry.fromJson(Map<String, dynamic> response) {
    final areas = response['areas'];
    if (areas is! List) {
      throw const FormatException(
          'Territory response is missing its areas list.');
    }
    for (final entry in areas) {
      if (entry is! Map) continue;
      final id = entry['id']?.toString().trim() ?? '';
      final pincode = entry['pincode']?.toString().trim() ?? '';
      if (id.isEmpty || pincode.isEmpty) continue;
      areaIdsByPincode.putIfAbsent(pincode, () => <String>{}).add(id);
    }
  }

  final Map<String, Set<String>> areaIdsByPincode = {};

  Set<String> idsFor(String pincode) =>
      areaIdsByPincode[pincode.trim()] ?? const <String>{};

  Color colorFor(String pincode) =>
      idsFor(pincode).isNotEmpty ? TColors.success : TColors.error;
}

/// Adapt grouped API links locally; shared models and request formats stay intact.
TerritoryMasterModel parseMapBeatMaster(Map<String, dynamic> response) {
  final links = <Map<String, dynamic>>[];
  for (final entry in (response['beatAreas'] as List? ?? const [])) {
    if (entry is! Map) continue;
    final beatId = entry['beatId'] ?? entry['beat_id'];
    final areaIds = entry['areaId'] ?? entry['area_id'];
    for (final id in (areaIds is List ? areaIds : [areaIds])) {
      if (beatId == null || id == null) continue;
      final beat = beatId.toString().trim();
      final area = id.toString().trim();
      if (beat.isEmpty || area.isEmpty) continue;
      links.add({'beat_id': beat, 'area_id': area});
    }
  }
  // Some beat-list responses include their links directly on each beat.
  // The beat list supplies colors; area records supply pincode geometry lookup.
  for (final entry in (response['beats'] as List? ?? const [])) {
    if (entry is! Map) continue;
    final ids = entry['areaIds'] ?? entry['areas'];
    if (ids is! List) continue;
    for (final value in ids) {
      final id = value is Map ? value['id'] ?? value['areaId'] : value;
      if (id == null || entry['id'] == null) continue;
      links.add({
        'beat_id': entry['id'].toString().trim(),
        'area_id': id.toString().trim()
      });
    }
  }
  return TerritoryMasterModel.fromJson({...response, 'beatAreas': links});
}
