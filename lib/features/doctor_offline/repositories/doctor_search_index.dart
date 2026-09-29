import '../models/doctor.dart';

class DoctorSearchIndex {
  DoctorSearchIndex(Iterable<Doctor> doctors) {
    rebuild(doctors);
  }

  final Map<String, Doctor> _byLocalId = <String, Doctor>{};
  final Map<String, List<String>> _searchFields = <String, List<String>>{};
  final Map<String, Set<String>> _priorities = <String, Set<String>>{};
  final Map<String, Set<String>> _headOffices = <String, Set<String>>{};
  final Map<String, Set<String>> _areas = <String, Set<String>>{};
  List<String> _orderedIds = const [];

  void rebuild(Iterable<Doctor> doctors) {
    _byLocalId.clear();
    _searchFields.clear();
    _priorities.clear();
    _headOffices.clear();
    _areas.clear();

    final ordered = List<Doctor>.of(doctors)
      ..sort((first, second) {
        final byName = first.displayName.toLowerCase().compareTo(
              second.displayName.toLowerCase(),
            );
        if (byName != 0) return byName;
        return first.localId.compareTo(second.localId);
      });
    _orderedIds = List<String>.unmodifiable(
      ordered.map((doctor) => doctor.localId),
    );

    for (final doctor in ordered) {
      _byLocalId[doctor.localId] = doctor;
      _addExact(_priorities, doctor.priority, doctor.localId);
      _addExact(_headOffices, doctor.headOfficeId, doctor.localId);
      _addExact(_areas, doctor.areaId, doctor.localId);
      _searchFields[doctor.localId] = [
        doctor.name,
        doctor.clinicName,
        doctor.specialization,
        doctor.location,
        doctor.clinicAddress,
        doctor.headOfficeName,
        doctor.areaName,
        doctor.registrationNumber,
      ].whereType<String>().map((value) => value.toLowerCase()).toList();
    }
  }

  List<Doctor> query(DoctorQuery query) {
    Set<String>? candidates;
    candidates = _intersect(candidates, _lookup(_priorities, query.priority));
    candidates = _intersect(
      candidates,
      _lookup(_headOffices, query.headOfficeId),
    );
    candidates = _intersect(candidates, _lookup(_areas, query.areaId));

    final sourceIds = candidates ?? _orderedIds.toSet();
    final normalizedSearch = query.search.trim().toLowerCase();
    final result = <Doctor>[];
    for (final localId in _orderedIds) {
      if (!sourceIds.contains(localId)) continue;
      final doctor = _byLocalId[localId]!;
      if (normalizedSearch.isNotEmpty &&
          !(_searchFields[localId]?.any(
                (field) => field.contains(normalizedSearch),
              ) ??
              false)) {
        continue;
      }
      if (query.priority != null && doctor.priority != query.priority) continue;
      if (query.headOfficeId != null &&
          doctor.headOfficeId != query.headOfficeId) {
        continue;
      }
      if (query.areaId != null && doctor.areaId != query.areaId) continue;
      result.add(doctor);
    }
    return List<Doctor>.unmodifiable(result);
  }

  Doctor? find(String localId) => _byLocalId[localId];

  void _addExact(
    Map<String, Set<String>> index,
    String? value,
    String localId,
  ) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return;
    (index[normalized] ??= <String>{}).add(localId);
  }

  Set<String>? _lookup(Map<String, Set<String>> index, String? value) {
    if (value == null) return null;
    return index[value] ?? <String>{};
  }

  Set<String>? _intersect(Set<String>? first, Set<String>? second) {
    if (second == null) return first;
    if (first == null) return Set<String>.of(second);
    return first.intersection(second);
  }
}
