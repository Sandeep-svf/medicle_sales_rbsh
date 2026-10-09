import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../../utils/loder/fieldomni_loader.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../../../doctor_offline/doctor_offline_module.dart';
import '../../../doctor_offline/models/doctor.dart';
import 'pincode_territory_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BiharTerritoryTestScreen(),
    ),
  );
}

const _geoJsonAsset = 'lib/utils/json_data/bihar_json.geojson';
const _ink = Color(0xFF17453F);
const _boundary = Color(0xFF317B72);
const _background = Color(0xFFF3F7F4);
final _indiaBounds = LatLngBounds(
  const LatLng(6.5, 68.0),
  const LatLng(37.5, 97.5),
);
const _districtColors = [
  Color(0xFFD7ECE4),
  Color(0xFFE3F0DA),
  Color(0xFFCCE6E4),
  Color(0xFFE9EEDB),
];

/// India basemap with bundled Bihar boundaries and saved doctor markers.
class BiharTerritoryTestScreen extends StatefulWidget {
  const BiharTerritoryTestScreen({super.key});

  @override
  State<BiharTerritoryTestScreen> createState() =>
      _BiharTerritoryTestScreenState();
}

class _BiharTerritoryTestScreenState extends State<BiharTerritoryTestScreen> {
  final MapController _mapController = MapController();
  late Future<_BiharMapData> _mapData;
  String? _selectedDistrict;
  DoctorOfflineModule? _doctorModule;
  VoidCallback? _removeDoctorListener;
  List<Doctor> _sourceDoctors = const [];
  List<Doctor> _mappedDoctors = const [];
  List<Marker> _doctorMarkers = const [];
  _BiharMapData? _loadedData;
  final Map<String, int> _districtDoctorCounts = {};
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
      debugPrint('Bihar map doctor cache: $error');
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
            !(doctor.latitude == 0 && doctor.longitude == 0))
        .toList();
    setState(() {
      _mappedDoctors = mapped;
      _countDistrictDoctors();
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
      padding: const EdgeInsets.fromLTRB(32, 180, 32, 160),
      maxZoom: 14,
    ));
  }

  Future<_BiharMapData> _loadMapData() async {
    final source = await rootBundle.loadString(_geoJsonAsset);
    final json = jsonDecode(source) as Map<String, dynamic>;
    final features = json['features'] as List<dynamic>? ?? const [];
    final districts = <_BiharDistrict>[];
    final allPoints = <LatLng>[];

    for (final feature in features) {
      if (feature is! Map<String, dynamic>) continue;
      final properties = feature['properties'];
      final geometry = feature['geometry'];
      if (properties is! Map<String, dynamic> ||
          geometry is! Map<String, dynamic>) {
        continue;
      }

      final name = properties['district']?.toString().trim();
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
      if (parts.isNotEmpty) districts.add(_BiharDistrict(name, parts));
    }

    if (districts.isEmpty) {
      throw const FormatException('No Bihar district boundaries were found.');
    }
    final data = _BiharMapData(districts, LatLngBounds.fromPoints(allPoints));
    _loadedData = data;
    _countDistrictDoctors();
    return data;
  }

  void _selectDistrict(_BiharMapData data, LatLng point) {
    String? selected;
    for (final district in data.districts.reversed) {
      if (district.contains(point)) {
        selected = district.name;
        _openDistrict(district);
        return;
      }
    }
    setState(() => _selectedDistrict = selected);
  }

  List<Polygon> _districtPolygons(_BiharMapData data) {
    final polygons = <Polygon>[];
    for (var index = 0; index < data.districts.length; index++) {
      final district = data.districts[index];
      final selected = district.name == _selectedDistrict;
      for (var partIndex = 0; partIndex < district.parts.length; partIndex++) {
        final rings = district.parts[partIndex];
        polygons.add(Polygon(
          points: rings.first,
          holePointsList: rings.length > 1 ? rings.skip(1).toList() : null,
          color: selected
              ? const Color(0xFF6AC9A6).withValues(alpha: 0.55)
              : _districtColors[index % _districtColors.length]
                  .withValues(alpha: 0.32),
          borderColor: selected ? _ink : _boundary,
          borderStrokeWidth: selected ? 2.5 : 1.15,
          label: partIndex == 0
              ? '${district.name}\n${_districtDoctorCounts[district.name] ?? 0} doctors'
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

  void _countDistrictDoctors() {
    _districtDoctorCounts.clear();
    final data = _loadedData;
    if (data == null) return;
    for (final district in data.districts) {
      _districtDoctorCounts[district.name] = _mappedDoctors
          .where((doctor) => district.contains(LatLng(
              doctor.latitude!.toDouble(), doctor.longitude!.toDouble())))
          .length;
    }
  }

  void _openDistrict(_BiharDistrict district) {
    setState(() => _selectedDistrict = district.name);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PincodeTerritoryScreen(
        districtName: district.name,
        districtParts: district.parts,
        districtBounds: district.bounds,
      ),
    ));
  }

  void _searchDistrict(_BiharMapData data) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          var query = '';
          return StatefulBuilder(builder: (context, update) {
            final districts = data.districts
                .where(
                    (district) => district.name.toLowerCase().contains(query))
                .toList();
            return SafeArea(
                child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom),
                    child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Search Bihar districts',
                                      prefixIcon: Icon(Icons.search)),
                                  onChanged: (value) => update(() =>
                                      query = value.trim().toLowerCase()))),
                          Expanded(
                              child: districts.isEmpty
                                  ? const Center(
                                      child: Text('No matching districts.'))
                                  : ListView.builder(
                                      itemCount: districts.length,
                                      itemBuilder: (_, index) {
                                        final district = districts[index];
                                        return ListTile(
                                            title: Text(district.name),
                                            subtitle: Text(
                                                '${_districtDoctorCounts[district.name] ?? 0} saved doctors'),
                                            trailing:
                                                const Icon(Icons.chevron_right),
                                            onTap: () {
                                              Navigator.pop(sheetContext);
                                              _openDistrict(district);
                                            });
                                      })),
                        ]))));
          });
        });
  }

  void _fitBihar(_BiharMapData data) {
    _mapController.fitCamera(CameraFit.bounds(
      bounds: data.bounds,
      padding: const EdgeInsets.fromLTRB(20, 180, 20, 112),
      maxZoom: 9,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: FutureBuilder<_BiharMapData>(
        future: _mapData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to open Bihar territory data.'),
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
                message: 'Loading Bihar boundaries...');
          }

          return Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    backgroundColor: _background,
                    initialCameraFit: CameraFit.bounds(
                      bounds: data.bounds,
                      padding: const EdgeInsets.fromLTRB(20, 180, 20, 112),
                      maxZoom: 9,
                    ),
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _indiaBounds,
                    ),
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: (_, point) => _selectDistrict(data, point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rbsh.medicle_sales_rbsh',
                    ),
                    PolygonLayer(
                      polygons: _districtPolygons(data),
                      drawLabelsLast: true,
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
                      districtCount: data.districts.length,
                      doctorStatus: _doctorStatus,
                      onShowDoctors:
                          _mappedDoctors.isEmpty ? null : _fitDoctors,
                    ),
                    Card(
                        child: Row(children: [
                      Expanded(
                          child: TextButton.icon(
                              onPressed: () => _searchDistrict(data),
                              icon: const Icon(Icons.search),
                              label: const Text('Search district'))),
                      const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                              'Green: districts\nPink: doctors · Circles: clusters',
                              style: TextStyle(fontSize: 11))),
                    ])),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: _selectedDistrict == null ? 16 : 92,
                child: FloatingActionButton.small(
                  heroTag: 'bihar_territory_fit',
                  backgroundColor: Colors.white,
                  foregroundColor: _ink,
                  onPressed: () => _fitBihar(data),
                  tooltip: 'Show all Bihar districts',
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
              if (_selectedDistrict != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: _ink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedDistrict!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                              '${_districtDoctorCounts[_selectedDistrict] ?? 0} doctors'),
                        ],
                      ),
                    ),
                  ),
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
      {required this.districtCount,
      required this.doctorStatus,
      this.onShowDoctors});

  final int districtCount;
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
                    'Bihar territory',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('$districtCount districts · India map'),
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

class _BiharMapData {
  const _BiharMapData(this.districts, this.bounds);

  final List<_BiharDistrict> districts;
  final LatLngBounds bounds;
}

class _BiharDistrict {
  _BiharDistrict(this.name, this.parts)
      : bounds = LatLngBounds.fromPoints(
            parts.expand((rings) => rings.first).toList());

  final LatLngBounds bounds;

  final String name;
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
