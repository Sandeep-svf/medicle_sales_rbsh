import 'dart:convert';
import 'dart:async';

import 'package:clipper2/clipper2.dart' as clip;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../../utils/loder/fieldomni_loader.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../../../doctor_offline/doctor_offline_module.dart';
import '../../../doctor_offline/models/doctor.dart';

const _geoJsonAsset = 'lib/utils/json_data/datagov_pincodes.geojson';
const _ink = Color(0xFF17453F);
const _boundary = Color(0xFF317B72);
const _background = Color(0xFFF3F7F4);
const _patna = LatLng(25.5941, 85.1376);
final _indiaBounds = LatLngBounds(
  const LatLng(6.5, 68.0),
  const LatLng(37.5, 97.5),
);
const _pincodeColors = [
  Color(0xFFD7ECE4),
  Color(0xFFE3F0DA),
  Color(0xFFCCE6E4),
  Color(0xFFE9EEDB),
];

/// Pincode boundaries and saved doctor locations over a Flutter map.
class PincodeTerritoryScreen extends StatefulWidget {
  const PincodeTerritoryScreen(
      {super.key,
      this.districtBounds,
      this.districtName,
      this.districtParts = const []});

  final LatLngBounds? districtBounds;
  final String? districtName;

  /// Polygon parts containing an outer ring followed by any hole rings.
  final List<List<List<LatLng>>> districtParts;

  @override
  State<PincodeTerritoryScreen> createState() => _PincodeTerritoryScreenState();
}

class _PincodeTerritoryScreenState extends State<PincodeTerritoryScreen> {
  final MapController _mapController = MapController();
  late Future<_PincodeMapData> _mapData;
  _PincodeArea? _selectedPincode;
  final Map<String, _PincodeArea> _selectedAreas = {};
  DoctorOfflineModule? _doctorModule;
  VoidCallback? _removeDoctorListener;
  List<Doctor> _sourceDoctors = const [];
  List<Doctor> _mappedDoctors = const [];
  List<Marker> _doctorMarkers = const [];
  bool _districtOnly = true;
  List<_PincodeArea> _districtAreas = const [];
  String _doctorStatus = 'Loading saved doctors...';

  @override
  void initState() {
    super.initState();
    _mapData = _loadMapData();
    unawaited(_loadDoctors());
  }

  @override
  void dispose() {
    _removeDoctorListener?.call();
    final module = _doctorModule;
    if (module != null) unawaited(module.dispose());
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final accountId = await AuthManager().getUserId();
      if (!mounted) return;
      if (accountId == null || accountId.trim().isEmpty) {
        setState(() => _doctorStatus = 'Sign in to show saved doctors');
        return;
      }
      final module = await DoctorOfflineModule.acquire(accountId: accountId);
      if (!mounted) {
        await module.dispose();
        return;
      }
      _doctorModule = module;
      _removeDoctorListener = module.controller.addListener(_updateDoctors);
      _updateDoctors();
    } catch (error) {
      if (mounted) {
        setState(() => _doctorStatus = 'Saved doctors could not be loaded');
      }
      debugPrint('Pincode map doctor cache: $error');
    }
  }

  void _updateDoctors() {
    if (!mounted) return;
    final doctors = _doctorModule!.controller.allDoctors;
    if (identical(_sourceDoctors, doctors) &&
        _doctorStatus != 'Loading saved doctors...') {
      return;
    }
    _sourceDoctors = doctors;
    final mapped = doctors
        .where((doctor) =>
            doctor.hasValidCoordinates &&
            doctor.latitude!.toDouble().isFinite &&
            doctor.longitude!.toDouble().isFinite &&
            !(doctor.latitude == 0 && doctor.longitude == 0) &&
            (!_districtOnly ||
                _inDistrict(LatLng(doctor.latitude!.toDouble(),
                    doctor.longitude!.toDouble()))))
        .toList();
    setState(() {
      _mappedDoctors = mapped;
      _doctorStatus = '${mapped.length} saved doctors on map';
      _doctorMarkers = mapped
          .map((doctor) => Marker(
                key: ValueKey(doctor.localId),
                point: LatLng(
                    doctor.latitude!.toDouble(), doctor.longitude!.toDouble()),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _showDoctor(doctor),
                  child: Tooltip(
                    message: doctor.displayName,
                    child: const Icon(Icons.location_on,
                        color: Color(0xFFC71D52), size: 42),
                  ),
                ),
              ))
          .toList();
    });
  }

  bool _inDistrict(LatLng point) {
    if (widget.districtParts.isEmpty) return true;
    if (widget.districtBounds != null &&
        !widget.districtBounds!.contains(point)) {
      return false;
    }
    return widget.districtParts.any((rings) =>
        _PincodeArea._insideRing(rings.first, point) &&
        !rings.skip(1).any((hole) => _PincodeArea._insideRing(hole, point)));
  }

  List<_PincodeArea> _visibleAreas(_PincodeMapData data) =>
      _districtOnly ? _districtAreas : data.areas;

  List<Doctor> _doctorsIn(_PincodeArea area) => _mappedDoctors
      .where((doctor) => area.contains(
          LatLng(doctor.latitude!.toDouble(), doctor.longitude!.toDouble())))
      .toList();

  void _showPincodeDoctors(_PincodeArea area) {
    final doctors = _doctorsIn(area);
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
                child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: Column(children: [
                Text('Pincode ${area.name} · ${doctors.length} doctors',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Expanded(
                    child: doctors.isEmpty
                        ? const Center(
                            child: Text('No saved doctors in this pincode.'))
                        : ListView.builder(
                            itemCount: doctors.length,
                            itemBuilder: (_, index) {
                              final doctor = doctors[index];
                              return ListTile(
                                  leading: const Icon(
                                      Icons.medical_services_outlined),
                                  title: Text(doctor.displayName),
                                  subtitle: Text(doctor.displayClinic),
                                  onTap: () {
                                    Navigator.pop(sheetContext);
                                    _showDoctor(doctor);
                                  });
                            })),
              ]),
            )));
  }

  Future<void> _search(_PincodeMapData data) async {
    final areas = _visibleAreas(data);
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          var query = '';
          return StatefulBuilder(builder: (context, update) {
            final pincodes = areas
                .where((area) =>
                    '${area.name} ${area.office}'.toLowerCase().contains(query))
                .toList();
            final doctors = _mappedDoctors
                .where((doctor) =>
                    doctor.displayName.toLowerCase().contains(query))
                .toList();
            return SafeArea(
                child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom),
                    child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.65,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                      labelText:
                                          'Search pincode, post office or doctor',
                                      prefixIcon: Icon(Icons.search)),
                                  onChanged: (value) => update(() =>
                                      query = value.trim().toLowerCase()))),
                          Expanded(
                              child: pincodes.isEmpty && doctors.isEmpty
                                  ? const Center(
                                      child: Text(
                                          'No matching pincodes or doctors.'))
                                  : ListView(children: [
                                      for (final area in pincodes)
                                        ListTile(
                                            leading:
                                                const Icon(Icons.map_outlined),
                                            title: Text(area.name),
                                            subtitle: Text(area.office),
                                            onTap: () {
                                              Navigator.pop(sheetContext);
                                              _toggleArea(area);
                                              _mapController.fitCamera(
                                                  CameraFit.bounds(
                                                      bounds: area.bounds,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          24, 210, 24, 200),
                                                      maxZoom: 15));
                                            }),
                                      for (final doctor in doctors)
                                        ListTile(
                                            leading: const Icon(Icons
                                                .medical_services_outlined),
                                            title: Text(doctor.displayName),
                                            subtitle:
                                                Text(doctor.displayClinic),
                                            onTap: () {
                                              Navigator.pop(sheetContext);
                                              _mapController.move(
                                                  LatLng(
                                                      doctor.latitude!
                                                          .toDouble(),
                                                      doctor.longitude!
                                                          .toDouble()),
                                                  16);
                                              _showDoctor(doctor);
                                            }),
                                    ])),
                        ]))));
          });
        });
  }

  void _showDoctor(Doctor doctor) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(doctor.displayName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(doctor.displaySpecialization),
              const Divider(height: 28),
              _doctorInfo('Clinic', doctor.clinicName),
              _doctorInfo('Address', doctor.clinicAddress ?? doctor.location),
              _doctorInfo('Phone', doctor.phone),
              _doctorInfo('Email', doctor.email),
              _doctorInfo('Area', doctor.areaName),
              _doctorInfo('Head office', doctor.headOfficeName),
              _doctorInfo('Qualification', doctor.qualification),
              _doctorInfo('Registration', doctor.registrationNumber),
              _doctorInfo('Priority', doctor.priority),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doctorInfo(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value.trim()),
        ],
      ),
    );
  }

  void _fitDoctors() {
    if (_mappedDoctors.isEmpty) return;
    _mapController.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(_mappedDoctors
          .map((doctor) =>
              LatLng(doctor.latitude!.toDouble(), doctor.longitude!.toDouble()))
          .toList()),
      padding: const EdgeInsets.fromLTRB(32, 210, 32, 200),
      maxZoom: 14,
    ));
  }

  Future<_PincodeMapData> _loadMapData() async {
    final source = await rootBundle.loadString(_geoJsonAsset);
    final data = await compute(_parsePincodeMap, source);
    _districtAreas = widget.districtParts.isEmpty
        ? data.areas
        : await compute(_clipDistrictPincodes,
            (areas: data.areas, districtParts: widget.districtParts));
    return data;
  }

  void _selectPincode(_PincodeMapData data, LatLng point) {
    _PincodeArea? selected;
    for (final area in _visibleAreas(data).reversed) {
      if (area.contains(point)) {
        selected = area;
        break;
      }
    }
    if (selected != null) _toggleArea(selected);
  }

  void _toggleArea(_PincodeArea area) {
    setState(() {
      if (_selectedAreas.containsKey(area.name)) {
        _selectedAreas.remove(area.name);
      } else {
        _selectedAreas[area.name] = area;
      }
      _selectedPincode =
          _selectedAreas.isEmpty ? null : _selectedAreas.values.last;
    });
  }

  Widget _selectionDetails() => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                child: Text('${_selectedAreas.length} areas selected',
                    style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _selectedAreas.clear();
                  _selectedPincode = null;
                }),
                child: const Text('Clear all'),
              ),
            ]),
            const Text('Tap a selected area again to deselect it.',
                style: TextStyle(color: _ink, fontSize: 12)),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final area in _selectedAreas.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          area.office.isEmpty ? 'Post office' : area.office),
                      subtitle: Text('Pincode: ${area.name}'
                          '${area.division.isEmpty ? '' : '\nDivision: ${area.division}'}'),
                      trailing: IconButton(
                        tooltip: 'Deselect ${area.name}',
                        onPressed: () => _toggleArea(area),
                        icon: const Icon(Icons.close, color: _ink),
                      ),
                      onTap: () => _showPincodeDoctors(area),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.medical_services_outlined,
                              color: _ink),
                          Text('${_doctorsIn(area).length}',
                              style: const TextStyle(color: _ink)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ]),
        ),
      );

  List<Polygon> _pincodePolygons(_PincodeMapData data) {
    final polygons = <Polygon>[];
    final areas = _visibleAreas(data);
    for (var index = 0; index < areas.length; index++) {
      final area = areas[index];
      final selected = _selectedAreas.containsKey(area.name);
      for (var partIndex = 0; partIndex < area.parts.length; partIndex++) {
        final rings = area.parts[partIndex];
        polygons.add(Polygon(
          points: rings.first,
          holePointsList: rings.length > 1 ? rings.skip(1).toList() : null,
          color: selected
              ? const Color(0xFFFFB300).withValues(alpha: 0.6)
              : _pincodeColors[index % _pincodeColors.length]
                  .withValues(alpha: 0.32),
          borderColor: selected ? const Color(0xFFB45309) : _boundary,
          borderStrokeWidth: selected ? 3.5 : 1.15,
          label: partIndex == 0
              ? '${area.office.isEmpty ? 'Post office' : area.office}\n(${area.name})'
              : null,
          labelStyle: const TextStyle(
            color: _ink,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ));
      }
    }
    return polygons;
  }

  void _fitAll(_PincodeMapData data) {
    _mapController.fitCamera(CameraFit.bounds(
      bounds: widget.districtBounds ?? data.bounds,
      padding: const EdgeInsets.fromLTRB(20, 180, 20, 170),
      maxZoom: 9,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.districtName == null
          ? null
          : AppBar(title: Text('${widget.districtName} pincodes')),
      backgroundColor: _background,
      body: FutureBuilder<_PincodeMapData>(
        future: _mapData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to open Pincode territories data.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _mapData = _loadMapData()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return const FieldOmniLoader(
                message: 'Loading pincode boundaries...');
          }

          return Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    backgroundColor: _background,
                    initialCenter: _patna,
                    initialZoom: 11,
                    initialCameraFit: widget.districtBounds == null
                        ? null
                        : CameraFit.bounds(
                            bounds: widget.districtBounds!,
                            padding:
                                const EdgeInsets.fromLTRB(24, 210, 24, 100),
                            maxZoom: 13,
                          ),
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _indiaBounds,
                    ),
                    minZoom: 5,
                    maxZoom: 18,
                    onTap: (_, point) => _selectPincode(data, point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rbsh.medicle_sales_rbsh',
                    ),
                    PolygonLayer(
                      polygons: _pincodePolygons(data),
                      drawLabelsLast: true,
                    ),
                    if (widget.districtParts.isNotEmpty)
                      PolygonLayer(
                        polygons: [
                          for (final rings in widget.districtParts)
                            if (rings.isNotEmpty)
                              Polygon(
                                points: rings.first,
                                holePointsList: rings.length > 1
                                    ? rings.skip(1).toList()
                                    : null,
                                color: Colors.transparent,
                                borderColor: const Color(0xFF7C3AED),
                                borderStrokeWidth: 3,
                              ),
                        ],
                      ),
                    if (_doctorMarkers.isNotEmpty)
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          markers: _doctorMarkers,
                          maxClusterRadius: 45,
                          size: const Size(44, 44),
                          showPolygon: false,
                          builder: (context, markers) => Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _ink,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text('${markers.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('© OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MapInfoCard(
                      pincodeCount: _visibleAreas(data).length,
                      doctorStatus: _doctorStatus,
                      onShowDoctors:
                          _mappedDoctors.isEmpty ? null : _fitDoctors,
                    ),
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(children: [
                              Expanded(
                                  child: Text(
                                      widget.districtName == null
                                          ? 'Pincode map'
                                          : 'Bihar → ${widget.districtName}${_selectedPincode == null ? "" : " → ${_selectedPincode!.name}"}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                              if (widget.districtParts.isNotEmpty)
                                FilterChip(
                                    label: const Text('District only'),
                                    selected: _districtOnly,
                                    onSelected: (value) {
                                      setState(() {
                                        _districtOnly = value;
                                        _selectedPincode = null;
                                        _selectedAreas.clear();
                                      });
                                      _sourceDoctors = const [];
                                      if (_doctorModule != null) {
                                        _updateDoctors();
                                      }
                                    }),
                              IconButton(
                                  onPressed: () => _search(data),
                                  icon: const Icon(Icons.search),
                                  tooltip: 'Search pincodes or doctors'),
                            ]))),
                    const Card(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                                'Purple: district · Green: pincodes · Amber: selected · Pink: doctors',
                                style: TextStyle(fontSize: 11)))),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: _selectedAreas.isEmpty
                    ? 32
                    : MediaQuery.sizeOf(context).height * 0.24 + 130,
                child: FloatingActionButton.small(
                  heroTag: 'pincode_territory_fit',
                  backgroundColor: Colors.white,
                  foregroundColor: _ink,
                  onPressed: () => _fitAll(data),
                  tooltip: widget.districtBounds == null
                      ? 'Show all pincodes'
                      : 'Zoom back to district',
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
              if (_selectedPincode != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _selectionDetails(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MapInfoCard extends StatelessWidget {
  const _MapInfoCard(
      {required this.pincodeCount,
      required this.doctorStatus,
      this.onShowDoctors});

  final int pincodeCount;
  final String doctorStatus;
  final VoidCallback? onShowDoctors;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.map_outlined, color: _ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pincode territories',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('$pincodeCount pincodes · Tap an area'),
                  Text(doctorStatus),
                ],
              ),
            ),
            IconButton(
              onPressed: onShowDoctors,
              tooltip: 'Show all saved doctors',
              icon: const Icon(Icons.medical_services_outlined, color: _ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _PincodeMapData {
  const _PincodeMapData(this.areas, this.bounds);

  final List<_PincodeArea> areas;
  final LatLngBounds bounds;
}

class _PincodeArea {
  _PincodeArea(this.name, this.parts, this.office, this.division)
      : bounds = LatLngBounds.fromPoints(
            parts.expand((rings) => rings.first).toList());

  final String name;
  final String office;
  final String division;
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

_PincodeMapData _parsePincodeMap(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  final features = json['features'] as List<dynamic>? ?? const [];
  final areas = <_PincodeArea>[];
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
      areas.add(_PincodeArea(
        name,
        parts,
        properties['Office_Name']?.toString().trim() ?? '',
        properties['Division']?.toString().trim() ?? '',
      ));
    }
  }

  if (areas.isEmpty) {
    throw const FormatException('No pincode boundaries were found.');
  }
  return _PincodeMapData(areas, LatLngBounds.fromPoints(allPoints));
}

// Work off the UI thread. Both rendering and hit testing consume these areas.
List<_PincodeArea> _clipDistrictPincodes(
    ({
      List<_PincodeArea> areas,
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
  final clipped = <_PincodeArea>[];
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
      clipped.add(_PincodeArea(area.name, parts, area.office, area.division));
    }
  }
  return clipped;
}
