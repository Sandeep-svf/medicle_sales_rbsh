import '../models/doctor.dart';

class DoctorSearchIndex {
  DoctorSearchIndex(Iterable<Doctor> doctors) {
    rebuild(doctors);
  }

  final Map<String, Doctor> _byLocalId = <String, Doctor>{};
  final Map<String, Set<String>> _searchGrams = <String, Set<String>>{};
  final Map<String, Set<String>> _priorities = <String, Set<String>>{};
  final Map<String, Set<String>> _headOffices = <String, Set<String>>{};
  final Map<String, Set<String>> _areas = <String, Set<String>>{};
  List<String> _orderedIds = const [];

  void rebuild(Iterable<Doctor> doctors) {
    _byLocalId.clear();
    _searchGrams.clear();
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
      final searchable = [
        doctor.name,
        doctor.clinicName,
        doctor.specialization,
        doctor.location,
        doctor.clinicAddress,
        doctor.headOfficeName,
        doctor.areaName,
        doctor.registrationNumber,
      ].whereType<String>().join(' ').toLowerCase();
      for (final gram in _grams(searchable)) {
        (_searchGrams[gram] ??= <String>{}).add(doctor.localId);
      }
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

    final normalizedSearch = query.search.trim().toLowerCase();
    if (normalizedSearch.length >= 3) {
      for (final gram in _grams(normalizedSearch)) {
        candidates = _intersect(candidates, _searchGrams[gram] ?? <String>{});
        if (candidates?.isEmpty ?? false) break;
      }
    }

    final sourceIds = candidates ?? _orderedIds.toSet();
    final result = <Doctor>[];
    for (final localId in _orderedIds) {
      if (!sourceIds.contains(localId)) continue;
      final doctor = _byLocalId[localId]!;
      if (query.matches(doctor)) result.add(doctor);
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

  Set<String> _grams(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const <String>{};
    if (normalized.length < 3) return <String>{normalized};
    final grams = <String>{};
    for (var index = 0; index <= normalized.length - 3; index++) {
      grams.add(normalized.substring(index, index + 3));
    }
    return grams;
  }
}
