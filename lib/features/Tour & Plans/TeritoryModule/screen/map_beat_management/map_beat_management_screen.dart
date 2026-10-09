import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/http/http_client.dart';
import '../../../../../utils/local_storage/auth_manager.dart';
import '../../../../../utils/loder/fieldomni_loader.dart';
import '../../../../doctor_offline/doctor_offline_module.dart';
import '../../model/area_model.dart';
import '../../model/beat_model.dart';
import '../../model/territory_master_model.dart';
import '../../repository/territory_repository.dart';
import 'map_beat_geometry.dart';
import 'beat_area_table.dart';
import 'map_beat_master_data.dart';
import 'map_beat_creation_page.dart';
import 'map_beat_selection.dart';
import 'map_beat_browser.dart';
import 'map_area_hold.dart';
import 'map_area_info_dialog.dart';

const _ink = TColors.textPrimary;
const _purple = TColors.materialBlueAccent;
const _pink = TColors.materialRed;
const _beatPalette = TColors.mapBeatPalette;
String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Independent map workflow. Does not register or modify TerritoryController.
class MapBeatManagementScreen extends StatefulWidget {
  const MapBeatManagementScreen({super.key});

  @override
  State<MapBeatManagementScreen> createState() =>
      _MapBeatManagementScreenState();
}

class _MapBeatManagementScreenState extends State<MapBeatManagementScreen> {
  final _map = MapController();
  bool _holdingArea = false;
  bool _areaInfoOpen = false;
  LatLng? _cameraCenter;
  double _cameraZoom = 8;
  Size _mapViewport = Size.zero;
  final _name = TextEditingController();
  final _search = TextEditingController();
  final _panelScroll = ScrollController();
  final _selection = MapBeatSelection();
  Set<String> get _selectedIds => _selection.areaIds;
  Map<String, MapBeatRegion> get _selectedPostOffices => _selection.postOffices;
  bool _tableMode = false;
  final _colorSections = <(MapBeatRegion, int), List<List<MapBeatRegion>>>{};
  final _districtCache = <String, List<MapBeatRegion>>{};
  final _districtCounts = <String, int>{};
  final _pincodeCounts = <String, int>{};
  MapBeatGeoData? _districts;
  MapBeatGeoData? _pincodes;
  TerritoryMasterModel? _master;
  MapBeatAreaRegistry? _areaRegistry;
  MapBeatRegion? _district;
  MapBeatRegion? _pincode;
  List<MapBeatRegion> _visiblePincodes = [];
  List<_MapDoctor> _doctors = [];
  List<Marker> _markers = [];
  DoctorOfflineModule? _offline;
  VoidCallback? _removeListener;
  BeatModel? _editing;
  BeatModel? _previewBeat;
  List<MapBeatRegion> _previewRegions = [];
  List<MapBeatRegion> _previewDistricts = [];
  String? _geometryError;
  String? _masterError;
  String _color = _hex(_beatPalette.values.first);
  String _query = '';
  bool _loadingMaster = false;
  bool _clipping = false;
  bool _saving = false;
  bool _mapReady = false;
  bool _showDoctors = true;
  bool _showBoundaries = true;
  bool _showBeatColors = true;
  List<({String name, LatLng point})> _headOffices = [];
  bool _showBeats = false;
  bool _panelOpen = false;
  int _districtRequest = 0;
  bool _indiaMode = false;
  Timer? _viewportTimer;
  List<MapBeatRegion> _indiaMapRegions = [];

  bool get _isPincodeMode => _indiaMode || _district != null;

  List<MapBeatRegion> get _availablePincodes => _district != null
      ? _visiblePincodes
      : _indiaMode
          ? (_pincodes?.areas ?? [])
          : [];

  void _scheduleViewportRefresh() {
    _viewportTimer?.cancel();
    _viewportTimer = Timer(const Duration(milliseconds: 160), () {
      if (!mounted || !_mapReady) return;
      final bounds = _map.camera.visibleBounds;
      setState(() {
        if (_indiaMode && _district == null && _pincodes != null) {
          _indiaMapRegions = _cameraZoom < 7
              ? []
              : _pincodes!.areas
                  .where((region) => region.bounds.isOverlapping(bounds))
                  .toList();
        }
      });
    });
  }

  void _showIndia() {
    ++_districtRequest;
    setState(() {
      _indiaMode = true;
      _district = null;
      _pincode = null;
      _previewBeat = null;
      _visiblePincodes = [];
      _clipping = false;
      _query = '';
      _search.clear();
      _rebuildVisibleDoctors();
    });
    _fit(_pincodes!.bounds);
    _scheduleViewportRefresh();
  }

  int _mappedDoctorCount(MapBeatRegion region) => _pincodeCounts.putIfAbsent(
      region.name,
      () => _doctors
          .where((doctor) =>
              doctor.point != null && region.contains(doctor.point!))
          .length);

  @override
  void initState() {
    super.initState();
    unawaited(_loadGeometry());
    unawaited(_loadHeadOffices());
    unawaited(_loadMaster());
    unawaited(_loadOfflineDoctors());
  }

  @override
  void dispose() {
    _viewportTimer?.cancel();
    _removeListener?.call();
    final offline = _offline;
    if (offline != null) unawaited(offline.dispose());
    _map.dispose();
    _name.dispose();
    _search.dispose();
    _panelScroll.dispose();
    super.dispose();
  }

  Future<void> _loadGeometry() async {
    setState(() => _geometryError = null);
    try {
      final sources = await Future.wait([
        rootBundle.loadString('lib/utils/json_data/bihar_json.geojson'),
        rootBundle.loadString('lib/utils/json_data/datagov_pincodes.geojson'),
      ]);
      final results = await Future.wait([
        compute(parseMapBeatDistricts, sources[0]),
        compute(parseMapBeatPincodes, sources[1]),
      ]);
      if (!mounted) return;
      setState(() {
        _districts = results[0];
        _pincodes = results[1];
        _rebuildDoctors();
      });
      unawaited(_loadNationwideGeometry());
    } catch (error, stack) {
      debugPrint('Map beat boundaries: $error\n$stack');
      if (mounted) {
        setState(() => _geometryError = 'Unable to load map boundaries.');
      }
    }
  }

  // Keep the initial map usable while the much larger India dataset loads.
  // A nationwide asset failure must not hide the working Bihar map.
  Future<void> _loadNationwideGeometry() async {
    try {
      final source = await rootBundle
          .loadString('lib/utils/json_data/Datagov_Pincode_Boundaries.geojson');
      if (!mounted) return;
      final data = await compute(parseMapBeatPincodes, source);
      if (!mounted) return;
      setState(() {
        _pincodes = data;
        if (_district != null && !_clipping) {
          _visiblePincodes =
              selectMapBeatDistrictPincodes(data.areas, _district!.name);
          _rebuildVisibleDoctors();
        }
      });
      if (_indiaMode) _fit(data.bounds);
      _scheduleViewportRefresh();
    } catch (error, stack) {
      debugPrint('Map beat nationwide boundaries: $error\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('India boundaries could not load. Bihar map is available.'),
        ));
      }
    }
  }

  Future<void> _loadHeadOffices() async {
    try {
      final user = await AuthManager().getUserData();
      if (!mounted) return;
      final offices = <({String name, LatLng point})>[];
      for (final office in user?.user?.headOffices ?? []) {
        final point = _validPoint(
            office.latitude.toDouble(), office.longitude.toDouble());
        if (point != null) {
          offices.add((name: office.name ?? 'Head office', point: point));
        }
      }
      setState(() => _headOffices = offices);
    } catch (_) {
      // Head-office navigation is optional; beat loading still proceeds.
    }
  }

  Future<void> _goToHeadOffice() async {
    if (_headOffices.isEmpty) {
      _message('No head-office location is available.');
      return;
    }
    final office = _headOffices.length == 1
        ? _headOffices.first
        : await showDialog<({String name, LatLng point})>(
            context: context,
            builder: (dialogContext) =>
                SimpleDialog(title: const Text('Go to head office'), children: [
                  for (final office in _headOffices)
                    SimpleDialogOption(
                        onPressed: () => Navigator.pop(dialogContext, office),
                        child: Text(office.name)),
                ]));
    if (office == null || !mounted) return;
    setState(() => _panelOpen = false);
    final districts =
        _districts!.areas.where((district) => district.contains(office.point));
    if (districts.isNotEmpty) {
      await _openDistrict(districts.first);
    } else {
      _showIndia();
    }
    if (mounted && _mapReady) _map.move(office.point, 11);
  }

  Future<bool> _loadMaster() async {
    if (_loadingMaster) return false;
    setState(() => _loadingMaster = true);
    try {
      debugPrint('MAP_BEAT_TERITORY REQUEST '
          '${THttpHelper.baseUrl}/territory/master');
      final json = await THttpHelper.authGet('territory/master');
      debugPrint('MAP_BEAT_TERITORY RESPONSE '
          'success=${json['success']} keys=${json.keys.join(',')}');
      if (json['success'] == false) {
        throw const FormatException(
            'Territory master request was unsuccessful.');
      }
      final registry = MapBeatAreaRegistry.fromJson(json);
      debugPrint('MAP_BEAT_TERITORY AREAS '
          '${(json['areas'] as List).length} API areas, '
          '${registry.areaIdsByPincode.length} pincodes with valid area IDs.');
      for (final area in json['areas'] as List) {
        if (area is! Map) continue;
        debugPrint('MAP_BEAT_TERITORY API_AREA ${jsonEncode({
              'pincode': area['pincode'],
              'id': area['id'],
              'postOffice': area['postOffice'],
            })}');
      }
      if (!mounted) return false;
      // Publish registration separately so other entity parsing cannot make
      // a valid area appear unregistered on the map.
      setState(() => _areaRegistry = registry);
      _logTerritoryMatches('areas loaded');
      final data = parseMapBeatMaster(json);
      if (!mounted) return false;
      setState(() {
        _master = data;
        _showBeatColors = true;
        _masterError = null;
        for (final office in _selectedPostOffices.values) {
          _selectedIds.addAll(_areasOf(office.name).map((area) => area.id));
        }
        _rebuildDoctors();
      });
      return true;
    } catch (error) {
      debugPrint('MAP_BEAT_TERITORY ERROR $error');
      if (mounted) {
        setState(() => _masterError =
            'Beat data could not be refreshed. Check your connection and retry.');
      }
      return false;
    } finally {
      if (mounted) setState(() => _loadingMaster = false);
    }
  }

  void _logTerritoryMatches(String event) {
    final registry = _areaRegistry;
    final regions =
        _isPincodeMode ? _mapRegions : (_districts?.areas ?? <MapBeatRegion>[]);
    final matched = regions
        .where((region) => registry?.idsFor(region.name).isNotEmpty == true)
        .length;
    debugPrint('MAP_BEAT_TERITORY MAP '
        'event=$event district=${_district?.name ?? 'none'} '
        'pincodeMode=$_isPincodeMode registryLoaded=${registry != null} '
        'clipping=$_clipping displayed=${regions.length} matched=$matched '
        'boundaries=$_showBoundaries');
    if (!_isPincodeMode) return;
    for (final region in regions.take(250)) {
      _logTerritoryPincode(region);
    }
    if (regions.length > 250) {
      debugPrint('MAP_BEAT_TERITORY MAP '
          '${regions.length - 250} additional pincodes omitted; '
          'tap a pincode to log its individual match.');
    }
  }

  void _logTerritoryPincode(MapBeatRegion region) {
    final ids = _areaRegistry?.idsFor(region.name);
    debugPrint('MAP_BEAT_TERITORY PINCODE ${jsonEncode({
          'mapPincode': region.name,
          'lookupPincode': region.name.trim(),
          'postOffice': region.office,
          'postalDivision': region.division,
          'areaIds': ids?.toList(),
          'color': ids == null
              ? 'WAITING_FOR_API'
              : ids.isNotEmpty
                  ? 'GREEN'
                  : 'RED',
        })}');
  }

  Future<void> _loadOfflineDoctors() async {
    try {
      final account = await AuthManager().getUserId();
      if (!mounted || account == null || account.isEmpty) return;
      final module = await DoctorOfflineModule.acquire(accountId: account);
      if (!mounted) {
        await module.dispose();
        return;
      }
      _offline = module;
      _removeListener = module.controller.addListener(() {
        if (mounted) setState(_rebuildDoctors);
      });
      setState(_rebuildDoctors);
    } catch (_) {
      // Territory master doctors are still available if the local store fails.
    }
  }

  void _rebuildDoctors() {
    final byId = <String, _MapDoctor>{};
    for (final doctor in _master?.doctors ?? []) {
      byId[doctor.id] = _MapDoctor(
        id: doctor.id,
        name: doctor.doctorName,
        clinic: doctor.clinicName,
        speciality: doctor.speciality,
        areaId: doctor.areaId,
        point: _validPoint(doctor.latitude, doctor.longitude),
      );
    }
    for (final doctor in _offline?.controller.allDoctors ?? []) {
      final id = doctor.serverId ?? 'local:${doctor.localId}';
      byId[id] = _MapDoctor(
        id: id,
        name: doctor.displayName,
        clinic: doctor.displayClinic,
        speciality: doctor.displaySpecialization,
        areaId: doctor.areaId ?? byId[id]?.areaId ?? '',
        phone: doctor.phone,
        point: _validPoint(
                doctor.latitude?.toDouble(), doctor.longitude?.toDouble()) ??
            byId[id]?.point,
      );
    }
    _doctors = byId.values.toList();
    _districtCounts.clear();
    for (final district in _districts?.areas ?? <MapBeatRegion>[]) {
      _districtCounts[district.name] = _doctors
          .where((d) => d.point != null && district.contains(d.point!))
          .length;
    }
    _rebuildVisibleDoctors();
  }

  static LatLng? _validPoint(double? lat, double? lng) {
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180 ||
        (lat == 0 && lng == 0)) {
      return null;
    }
    return LatLng(lat, lng);
  }

  void _rebuildVisibleDoctors() {
    final visible = _doctors
        .where((d) =>
            d.point != null &&
            (_district == null || _district!.contains(d.point!)))
        .toList();
    _markers = visible
        .map((doctor) => Marker(
              key: ValueKey(doctor.id),
              point: doctor.point!,
              width: 44,
              height: 44,
              child: GestureDetector(
                  onTap: () => _doctorDetails(doctor),
                  child: Tooltip(
                      message: doctor.name,
                      child: const Icon(Icons.location_on,
                          color: _pink, size: 40))),
            ))
        .toList();
    _pincodeCounts.clear();
    for (final area in _visiblePincodes) {
      _pincodeCounts[area.name] =
          visible.where((d) => area.contains(d.point!)).length;
    }
  }

  Future<void> _openDistrict(MapBeatRegion district,
      {bool showSaved = false}) async {
    if (_saving) return;
    // Refresh the API area registry when entering the district pincode view.
    // Boundary geometry and doctor counts never determine registration colors.
    unawaited(_loadMaster());
    final request = ++_districtRequest;
    setState(() {
      _district = district;
      _indiaMode = false;
      if (!showSaved) _panelOpen = false;
      if (!showSaved) _previewBeat = null;
      _pincode = null;
      _query = '';
      _search.clear();
      _showBeats = showSaved;
      _clipping = true;
      _visiblePincodes = [];
      _rebuildVisibleDoctors();
    });
    _fit(district.bounds, minZoom: 8);
    try {
      final areas =
          selectMapBeatDistrictPincodes(_pincodes!.areas, district.name);
      if (!mounted || request != _districtRequest) return;
      setState(() {
        _visiblePincodes = areas;
        _clipping = false;
        _rebuildVisibleDoctors();
      });
      if (areas.isNotEmpty && !showSaved) {
        _fit(LatLngBounds.fromPoints(areas
            .expand((area) => area.parts.expand((rings) => rings.first))
            .toList()));
      }
      _logTerritoryMatches('district opened');
    } catch (_) {
      if (!mounted || request != _districtRequest) return;
      setState(() => _clipping = false);
      _message('Unable to prepare this district. Please select it again.');
    }
  }

  void _backToBihar() {
    ++_districtRequest;
    setState(() {
      _district = null;
      _indiaMode = false;
      _previewBeat = null;
      _pincode = null;
      _visiblePincodes = [];
      _clipping = false;
      _query = '';
      _search.clear();
      _rebuildVisibleDoctors();
    });
    if (_districts != null) _fit(_districts!.bounds);
  }

  void _fit(LatLngBounds bounds, {double minZoom = 0}) {
    if (!_mapReady) return;
    final landscape =
        _mapViewport.width >= 840 && _mapViewport.width > _mapViewport.height;
    final padding = !_panelOpen
        ? const EdgeInsets.fromLTRB(36, 72, 36, 120)
        : landscape
            ? const EdgeInsets.fromLTRB(36, 72, 450, 36)
            : EdgeInsets.fromLTRB(36, 72, 36, _mapViewport.height * 0.62 + 24);
    _map.fitCamera(CameraFit.bounds(
        bounds: bounds, padding: padding, minZoom: minZoom, maxZoom: 15));
  }

  void _focusPincode(MapBeatRegion pincode,
      {bool zoom = false, bool openPanel = false}) {
    _logTerritoryPincode(pincode);
    setState(() {
      _pincode = pincode;
      _showBeats = false;
      if (openPanel) _panelOpen = true;
    });
    if (!openPanel) setState(() => _panelOpen = false);
    if (zoom) _fit(pincode.bounds);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _panelScroll.hasClients) {
        _panelScroll.animateTo(0,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _tapMap(LatLng point) {
    if (_holdingArea || _clipping || _saving || !_showBoundaries) return;
    if (_district == null && !_indiaMode) {
      for (final district in _districts!.areas.reversed) {
        if (district.contains(point)) {
          unawaited(_openDistrict(district));
          return;
        }
      }
    } else {
      for (final pincode
          in (_district == null ? _indiaMapRegions : _visiblePincodes)
              .reversed) {
        if (pincode.contains(point)) {
          _togglePincode(pincode);
          _focusPincode(pincode);
          return;
        }
      }
    }
  }

  void _holdArea(Offset offset) {
    if (!_mapReady ||
        !_isPincodeMode ||
        _clipping ||
        _saving ||
        !_showBoundaries ||
        _areaInfoOpen) {
      return;
    }
    final point = _map.camera.screenOffsetToLatLng(offset);
    final hits = _mapRegions.where((region) => region.contains(point));
    if (hits.isEmpty) return;
    final region = hits.last;
    final areas = _areasOf(region.name);
    final ids = areas.map((area) => area.id).toSet();
    _holdingArea = true;
    _areaInfoOpen = true;
    HapticFeedback.mediumImpact();
    final beats = _master?.beats
            .where((beat) => _master!.beatAreas.any(
                (link) => link.beatId == beat.id && ids.contains(link.areaId)))
            .toList() ??
        <BeatModel>[];
    unawaited(showMapAreaInfo(
      context,
      title: areas.isEmpty
          ? region.office
          : areas.map((area) => area.postOffice).toSet().join(', '),
      pincode: region.name,
      doctors: areas.fold(0, (sum, area) => sum + area.doctorCount),
      chemists: areas.fold(0, (sum, area) => sum + area.chemistCount),
      stockists: areas.fold(0, (sum, area) => sum + area.stockistCount),
      dataAvailable: _master != null && _masterError == null,
      beats: [
        for (final beat in beats)
          (
            id: beat.id,
            name: beat.beatName,
            color: _parseColor(beat.color),
            areas: <String>[]
          )
      ],
    ).whenComplete(() {
      _areaInfoOpen = false;
      _holdingArea = false;
    }));
  }

  void _togglePincode(MapBeatRegion pincode) {
    if (_saving) return;
    final areas = _areasOf(pincode.name);
    setState(() {
      _showBeats = false;
      _selection.toggle(pincode, areas);
    });
  }

  void _selectVisiblePincodes(List<MapBeatRegion> pincodes,
      {required bool add}) {
    if (_saving) return;
    final ids = pincodes
        .expand((pincode) => _areasOf(pincode.name))
        .map((area) => area.id)
        .toSet();
    setState(() {
      if (add) {
        for (final pincode in pincodes) {
          _selectedPostOffices[pincode.name] = pincode;
        }
        _selectedIds.addAll(ids);
      } else {
        for (final pincode in pincodes) {
          _selectedPostOffices.remove(pincode.name);
        }
        _selectedIds.removeAll(ids);
      }
      _showBeats = false;
    });
  }

  List<AreaModel> _areasOf(String pincode) => (_master?.areas ?? [])
      .where(
          (area) => area.id.isNotEmpty && area.pincode.trim() == pincode.trim())
      .toList();

  List<AreaModel> get _selectedAreas =>
      (_master?.areas ?? []).where((a) => _selectedIds.contains(a.id)).toList();

  int get _selectedDoctorCount => (_master?.doctors ?? [])
      .where((doctor) => _selectedIds.contains(doctor.areaId))
      .length;

  int _areaDoctorCount(String id) =>
      (_master?.doctors ?? []).where((doctor) => doctor.areaId == id).length;

  int _beatDoctorCount(BeatModel beat) {
    final ids = (_master?.beatAreas ?? [])
        .where((link) => link.beatId == beat.id)
        .map((link) => link.areaId)
        .toSet();
    return (_master?.doctors ?? [])
        .where((doctor) => ids.contains(doctor.areaId))
        .length;
  }

  List<BeatModel> _beatsForArea(String id) {
    final ids = (_master?.beatAreas ?? [])
        .where((link) => link.areaId == id)
        .map((link) => link.beatId)
        .toSet();
    return (_master?.beats ?? [])
        .where((beat) => ids.contains(beat.id))
        .toList();
  }

  List<BeatModel> _beatsForPincode(String code) =>
      mapBeatMembershipsForPincode(_master, code);

  bool? _pincodeSelection(String code) {
    if (_selectedPostOffices.containsKey(code)) return true;
    final areas = _areasOf(code);
    final count = areas.where((area) => _selectedIds.contains(area.id)).length;
    if (count == 0 || areas.isEmpty) return false;
    return count == areas.length ? true : null;
  }

  Set<String> get _selectedPincodes => {
        ..._selectedPostOffices.keys,
        ..._selectedAreas.map((a) => a.pincode.trim())
      };

  Color _parseColor(String hex) =>
      Color(int.tryParse(hex.replaceFirst('#', 'FF'), radix: 16) ??
          TColors.textPrimary.toARGB32());

  List<MapBeatRegion> get _mapRegions =>
      _showBeats && _previewRegions.isNotEmpty && _previewBeat != null
          ? _previewRegions
          : _district != null
              ? _visiblePincodes
              : _indiaMode
                  ? _indiaMapRegions
                  : _districts!.areas;

  Widget _postOfficeLabel(MapBeatRegion region, {bool showPincode = true}) =>
      Text.rich(
        TextSpan(children: [
          TextSpan(text: region.office.isEmpty ? 'Post office' : region.office),
          if (showPincode)
            TextSpan(
              text: '\n(${region.name})',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
        ]),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            color: _ink, fontSize: 12, fontWeight: FontWeight.w600),
      );

  List<Marker> _pincodeLabels() {
    if (!_mapReady || !_showBoundaries || !_isPincodeMode || _cameraZoom < 8) {
      return [];
    }
    final camera = _map.camera;
    final showPincode = _cameraZoom >= 11;
    final occupied = <Rect>[];
    final markers = <Marker>[];
    final regions = _mapRegions.toList()
      ..sort((a, b) {
        if (a.name == _pincode?.name) return -1;
        if (b.name == _pincode?.name) return 1;
        return a.name.compareTo(b.name);
      });
    for (final region in regions) {
      final point = Polygon(points: region.parts.first.first).labelPosition;
      if (!camera.visibleBounds.contains(point)) continue;
      final center = camera.latLngToScreenOffset(point);
      final beats =
          _showBeatColors ? _beatsForPincode(region.name) : <BeatModel>[];
      final shared = beats.length > 1;
      final rect = Rect.fromCenter(
          center: center,
          width: 164,
          height: (showPincode ? 56 : 42) + (shared ? 16 : 0));
      if (occupied.any((other) => other.overlaps(rect))) continue;
      occupied.add(rect);
      markers.add(Marker(
        point: point,
        width: 156,
        height: (showPincode ? 48 : 34) + (shared ? 16 : 0),
        child: IgnorePointer(
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            _postOfficeLabel(region, showPincode: showPincode),
            if (shared) ...[
              const SizedBox(height: 3),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (final beat in beats)
                  Container(
                      width: 10,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                          color: _parseColor(beat.color),
                          borderRadius: BorderRadius.circular(2))),
              ]),
            ],
          ])),
        ),
      ));
    }
    return markers;
  }

  List<Polygon> _polygons() {
    if (!_showBoundaries) return [];
    final regions = _mapRegions;
    final selectedPincodes = _selectedPincodes;
    final previewIds = _master?.beatAreas
            .where((link) => link.beatId == _previewBeat?.id)
            .map((link) => link.areaId)
            .toSet() ??
        <String>{};
    final previewPincodes = _master?.areas
            .where((area) => previewIds.contains(area.id))
            .map((area) => area.pincode.trim())
            .toSet() ??
        <String>{};
    final polygons = <Polygon>[];
    for (final region in regions) {
      final chosen = !_showBeats &&
          _isPincodeMode &&
          selectedPincodes.contains(region.name);
      final preview = _showBeatColors &&
          _showBeats &&
          _isPincodeMode &&
          previewPincodes.contains(region.name);
      final focused = region.name == _pincode?.name;
      final memberships =
          _isPincodeMode ? _beatsForPincode(region.name) : <BeatModel>[];
      final color = _isPincodeMode
          ? preview
              ? _parseColor(_previewBeat!.color)
              : _showBeatColors && memberships.isNotEmpty
                  ? _parseColor(memberships.first.color)
                  : _areaRegistry?.colorFor(region.name) ?? _ink
          : chosen
              ? TColors.success
              : preview
                  ? _parseColor(_previewBeat!.color)
                  : focused
                      ? TColors.secondary
                      : _showBeatColors && memberships.isNotEmpty
                          ? _parseColor(memberships.first.color)
                          : _ink;
      final shared = _isPincodeMode &&
          _showBeatColors &&
          memberships.length > 1 &&
          !preview;
      final fillAlpha = chosen || preview
          ? 0.38
          : focused
              ? 0.3
              : 0.25;
      if (shared) {
        final sections = _colorSections.putIfAbsent(
          (region, memberships.length),
          () => mapBeatColorSections(region, memberships.length),
        );
        for (var index = 0; index < sections.length; index++) {
          for (final section in sections[index]) {
            for (final rings in section.parts) {
              polygons.add(Polygon(
                points: rings.first,
                holePointsList:
                    rings.length > 1 ? rings.skip(1).toList() : null,
                color: _parseColor(memberships[index].color)
                    .withValues(alpha: fillAlpha),
                borderStrokeWidth: 0,
              ));
            }
          }
        }
      }
      for (var i = 0; i < region.parts.length; i++) {
        final rings = region.parts[i];
        polygons.add(Polygon(
          points: rings.first,
          holePointsList: rings.length > 1 ? rings.skip(1).toList() : null,
          color: shared
              ? TColors.transparent
              : color.withValues(
                  alpha: chosen || preview
                      ? 0.38
                      : focused
                          ? 0.3
                          : _isPincodeMode
                              ? 0.25
                              : 0.12),
          borderColor: color,
          borderStrokeWidth: chosen || preview || focused ? 2.8 : 1.1,
          label: i == 0 && !_isPincodeMode
              ? '${region.name}\n${_districtCounts[region.name] ?? 0} doctors'
              : null,
          labelStyle: const TextStyle(
              color: _ink, fontSize: 11, fontWeight: FontWeight.w600),
        ));
        if (chosen) {
          polygons.add(Polygon(
              points: rings.first,
              holePointsList: rings.length > 1 ? rings.skip(1).toList() : null,
              color: TColors.transparent,
              borderColor: TColors.primary,
              borderStrokeWidth: 2.5));
        }
      }
    }
    if (_district != null) {
      final outlines =
          _showBeats && _previewBeat != null && _previewDistricts.isNotEmpty
              ? _previewDistricts
              : [_district!];
      for (final rings in outlines.expand((district) => district.parts)) {
        polygons.add(Polygon(
            points: rings.first,
            holePointsList: rings.length > 1 ? rings.skip(1).toList() : null,
            color: TColors.transparent,
            borderColor: _purple,
            borderStrokeWidth: 3));
      }
    }
    return polygons;
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDiscard() async {
    if (_selectedIds.isEmpty && _name.text.trim().isEmpty && _editing == null) {
      return true;
    }
    return await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: const Text('Discard this draft?'),
                  content: const Text(
                      'Your unsaved name and area selections will be cleared.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Keep draft')),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Discard'))
                  ],
                )) ??
        false;
  }

  void _clearDraft() {
    setState(() {
      _selectedIds.clear();
      _selectedPostOffices.clear();
      _editing = null;
      _previewBeat = null;
      _name.clear();
      _color = _hex(_beatPalette.values.first);
    });
  }

  void _removeSelectedPincode(String code) {
    setState(() {
      _selectedPostOffices.remove(code);
      _selectedIds.removeAll(_areasOf(code).map((area) => area.id));
    });
  }

  Widget _selectionTray() {
    final pins = _selectedPincodes.toList()..sort();
    return Material(
      color: TColors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MapBeatBrowser(
            beats: [
              for (final beat in _master?.beats ?? <BeatModel>[])
                (
                  id: beat.id,
                  name: beat.beatName,
                  color: _parseColor(beat.color),
                  areas: _beatAreas(beat)
                      .map((area) => '${area.postOffice} (${area.pincode})')
                      .toList(),
                )
            ],
            busy: _clipping || _loadingMaster,
            onView: (id) =>
                _viewBeat(_master!.beats.firstWhere((beat) => beat.id == id)),
          ),
          const Divider(height: 16),
          Row(children: [
            const Icon(Icons.layers_outlined, color: TColors.primary),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    '${pins.length} pincodes · ${_selectedIds.length} areas',
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            IconButton(
                onPressed: () => setState(() => _panelOpen = true),
                tooltip: 'Browse areas and beat details',
                icon: const Icon(Icons.tune)),
            if (pins.isNotEmpty)
              TextButton(onPressed: _clearDraft, child: const Text('Clear')),
          ]),
          if (pins.isEmpty)
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Tap areas to select. Tap selected areas again to remove.'))
          else
            SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pins.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final pin = pins[index];
                    final areas = _areasOf(pin);
                    final name = areas.isEmpty
                        ? (_selectedPostOffices[pin]?.office ?? 'Post office')
                        : areas
                            .where((a) => _selectedIds.contains(a.id))
                            .map((a) => a.postOffice)
                            .toSet()
                            .join(', ');
                    return InputChip(
                      label: Text('$name ($pin)'),
                      avatar: Icon(
                          areas.isEmpty
                              ? Icons.info_outline
                              : Icons.check_circle,
                          color:
                              areas.isEmpty ? TColors.warning : TColors.success,
                          size: 18),
                      onDeleted: () => _removeSelectedPincode(pin),
                    );
                  },
                )),
          if (pins.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: Text('$_selectedDoctorCount assigned doctors',
                      style: const TextStyle(color: TColors.textSecondary))),
              FilledButton.icon(
                onPressed: _selectedIds.isEmpty ||
                        _loadingMaster ||
                        _masterError != null
                    ? null
                    : _openBeatForm,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_editing == null ? 'Continue' : 'Review changes'),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Future<void> _openBeatForm() async {
    if (_selectedIds.isEmpty) {
      _message('Select multiple areas on the map first.');
      return;
    }
    if (_master == null || _masterError != null || _loadingMaster || _saving) {
      return;
    }
    FocusScope.of(context).unfocus();
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MapBeatCreationPage(
        areas: List<AreaModel>.of(_selectedAreas),
        initialName: _name.text,
        initialColor: _color,
        editing: _editing != null,
        onDraftChanged: (name, color) {
          _name.text = name;
          _color = color;
        },
        onSave: (name, color) async {
          _name.text = name;
          _color = color;
          await _save();
          return _selectedIds.isEmpty && _name.text.isEmpty;
        },
      ),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (_saving || _master == null || _masterError != null) return;
    final name = _name.text.trim();
    if (name.isEmpty) {
      _message('Enter a beat name.');
      return;
    }
    if (_selectedIds.isEmpty) {
      _message('Select at least one registered area.');
      return;
    }
    final available = _master!.areas.map((a) => a.id).toSet();
    if (!_selectedIds.every(available.contains)) {
      _message(
          'Some selected areas are no longer available. Refresh and review the draft.');
      return;
    }
    final editing = _editing;
    setState(() => _saving = true);
    try {
      final repository = TerritoryRepository.instance;
      if (editing == null) {
        await repository.createBeat(
            name: name, areaIds: _selectedIds.toList(), color: _color);
      } else {
        await repository.updateBeat(
            beatId: editing.id,
            name: name,
            areaIds: _selectedIds.toList(),
            color: _color);
      }
      if (!mounted) return;
      _clearDraft();
      final refreshed = await _loadMaster();
      if (!mounted) return;
      setState(() {
        _showBeats = false;
        _panelOpen = false;
      });
      _message(refreshed
          ? 'Beat ${editing == null ? 'created' : 'updated'} successfully.'
          : 'Beat saved. Refresh to see the latest list.');
    } catch (_) {
      _message(
          'Beat could not be saved. Your draft is retained; check your connection and retry.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit(BeatModel beat) async {
    if (!await _confirmDiscard() || !mounted) return;
    final ids = _master!.beatAreas
        .where((link) => link.beatId == beat.id)
        .map((link) => link.areaId)
        .toSet();
    setState(() {
      _editing = beat;
      _panelOpen = true;
      _previewBeat = null;
      _name.text = beat.beatName;
      _color = beat.color;
      _selectedIds
        ..clear()
        ..addAll(ids);
      _selectedPostOffices.clear();
      _showBeats = false;
    });
    final areas = _selectedAreas;
    if (areas.isNotEmpty && _districts != null) {
      final area = areas.first;
      final point = _validPoint(area.latitude, area.longitude);
      final districts =
          _districts!.areas.where((d) => point != null && d.contains(point));
      if (districts.isNotEmpty) {
        await _openDistrict(districts.first);
      } else {
        _showIndia();
        final regions = _pincodes!.areas
            .where((region) => region.name == area.pincode.trim());
        if (regions.isNotEmpty) {
          _focusPincode(regions.first, zoom: true, openPanel: true);
        }
      }
    }
  }

  Future<void> _delete(BeatModel beat) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Delete beat?'),
              content: Text('Delete “${beat.beatName}”?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Delete'))
              ],
            ));
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await TerritoryRepository.instance.deleteBeat(beat.id);
      if (!mounted) return;
      if (_editing?.id == beat.id) _clearDraft();
      if (_previewBeat?.id == beat.id) setState(() => _previewBeat = null);
      final refreshed = await _loadMaster();
      _message(refreshed ? 'Beat deleted.' : 'Beat deleted. Refresh the list.');
    } catch (_) {
      _message('Unable to delete the beat. Please retry.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _doctorDetails(_MapDoctor doctor) {
    if (doctor.point != null && _mapReady) _map.move(doctor.point!, 16.5);
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(doctor.speciality),
                      Text(doctor.clinic),
                      if (doctor.phone != null) Text(doctor.phone!),
                      const SizedBox(height: 12),
                      Text(_selectedIds.contains(doctor.areaId)
                          ? 'Included in the current beat draft'
                          : 'Not included in the current beat draft'),
                    ]))));
  }

  Widget _mapView() {
    return Stack(children: [
      MapAreaHold(
          onHold: _holdArea,
          onRelease: () {
            Future<void>.delayed(const Duration(milliseconds: 100), () {
              _holdingArea = false;
            });
          },
          child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _cameraCenter ?? const LatLng(25.5941, 85.1376),
                initialZoom: _cameraZoom,
                onPositionChanged: (camera, _) {
                  _cameraCenter = camera.center;
                  _cameraZoom = camera.zoom;
                  _scheduleViewportRefresh();
                },
                initialCameraFit: _cameraCenter != null
                    ? null
                    : CameraFit.bounds(
                        bounds: _districts!.bounds,
                        padding: const EdgeInsets.all(36)),
                minZoom: 3,
                maxZoom: 18,
                cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                        const LatLng(6.5, 68), const LatLng(37.5, 97.5))),
                onMapReady: () {
                  _mapReady = true;
                  _cameraZoom = _map.camera.zoom;
                  _scheduleViewportRefresh();
                },
                onTap: (_, point) => _tapMap(point),
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.rbsh.medicle_sales_rbsh'),
                PolygonLayer(polygons: _polygons(), drawLabelsLast: true),
                MarkerLayer(markers: _pincodeLabels()),
                if (_showDoctors && _markers.isNotEmpty)
                  MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                    markers: _markers,
                    maxClusterRadius: 45,
                    size: const Size(44, 44),
                    showPolygon: false,
                    builder: (_, markers) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: _ink,
                            shape: BoxShape.circle,
                            border: Border.all(color: TColors.white, width: 2)),
                        child: Text('${markers.length}',
                            style: const TextStyle(
                                color: TColors.white,
                                fontWeight: FontWeight.bold))),
                  )),
                if (_headOffices.isNotEmpty)
                  MarkerLayer(markers: [
                    for (final office in _headOffices)
                      Marker(
                        point: office.point,
                        width: 42,
                        height: 42,
                        child: Tooltip(
                            message: office.name,
                            child: const Icon(Icons.location_city,
                                color: TColors.materialBlueAccent, size: 32)),
                      ),
                  ]),
                const RichAttributionWidget(attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors')
                ]),
              ])),
      Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ChoiceChip(
                            label: const Text('Bihar territory'),
                            selected: !_indiaMode,
                            onSelected: (_) => _backToBihar()),
                        ChoiceChip(
                            label: const Text('All India pincodes'),
                            selected: _indiaMode,
                            onSelected: (_) => _showIndia()),
                        TextButton.icon(
                            onPressed: () => setState(() {
                                  _showBeats = true;
                                  _panelOpen = true;
                                }),
                            icon: const Icon(Icons.route_outlined),
                            label: const Text('Saved beats')),
                        Text(
                            _district == null && !_indiaMode
                                ? 'Choose a district → select multiple pincode areas'
                                : 'Tap to select · hold 1.5s for area details',
                            style: const TextStyle(
                                fontSize: 12, color: TColors.textSecondary)),
                      ])))),
      Positioned(
          right: 12,
          bottom: 112,
          child: Column(children: [
            IconButton.filledTonal(
                onPressed: _goToHeadOffice,
                tooltip: 'Go to head office',
                icon: const Icon(Icons.location_city)),
            const SizedBox(height: 8),
            IconButton.filledTonal(
                onPressed: () => setState(() => _showDoctors = !_showDoctors),
                tooltip: _showDoctors ? 'Hide doctors' : 'Show doctors',
                icon: Icon(
                    _showDoctors ? Icons.location_on : Icons.location_off)),
            const SizedBox(height: 8),
            IconButton.filledTonal(
                onPressed: () => _fit(_district?.bounds ??
                    (_indiaMode ? _pincodes!.bounds : _districts!.bounds)),
                tooltip: 'Reset map view',
                icon: const Icon(Icons.center_focus_strong)),
          ])),
      Positioned(
          left: 12,
          bottom: 106,
          child: IgnorePointer(
              child: Card(
                  child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
                _district == null
                    ? 'Navy: districts · Red: doctors'
                    : 'Ocean: district\nTeal: focused · Beat color: selected',
                style: const TextStyle(fontSize: 11)),
          )))),
      if (_clipping)
        const Positioned.fill(
            child: ColoredBox(
                color: Color(0xDDFFFFFF),
                child: FieldOmniLoader(
                    message: 'Preparing district pincodes...'))),
    ]);
  }

  Widget _heading(String title, String subtitle) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: TColors.textSecondary)),
      ]));

  void _areaDetails(AreaModel area) {
    final doctors = (_master?.doctors ?? [])
        .where((doctor) => doctor.areaId == area.id)
        .toList();
    final chemists = (_master?.chemists ?? [])
        .where((chemist) => chemist.areaId == area.id)
        .toList();
    final stockists = (_master?.stockists ?? [])
        .where((stockist) => stockist.areaId == area.id)
        .toList();
    final beats = _beatsForArea(area.id);
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
            child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.72,
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  Text(area.postOffice,
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('Pincode ${area.pincode}'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    Chip(label: Text('${doctors.length} doctors')),
                    Chip(label: Text('${chemists.length} chemists')),
                    Chip(label: Text('${stockists.length} stockists')),
                  ]),
                  if (_selectedPostOffices.isNotEmpty) ...[
                    const Text('Selected post offices',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final office in _selectedPostOffices.values)
                        InputChip(
                          backgroundColor: TColors.successBg,
                          avatar: const Icon(Icons.check_circle,
                              color: TColors.success, size: 18),
                          label: Text(
                              '${office.office.isEmpty ? 'Post office' : office.office}\n(${office.name})'
                              '${office.division.isEmpty ? '' : '\n${office.division}'}'),
                          onDeleted: () => _togglePincode(office),
                        ),
                    ]),
                    const Divider(height: 24),
                  ],
                  const Text('Assigned beats',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  if (beats.isEmpty) const Text('No beat assigned.'),
                  Wrap(spacing: 6, children: [
                    for (final beat in beats.take(8))
                      Chip(
                          avatar: CircleAvatar(
                              backgroundColor: _parseColor(beat.color),
                              radius: 8),
                          label: Text(beat.beatName))
                  ]),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_selectedIds.contains(area.id)) {
                            _selectedIds.remove(area.id);
                          } else {
                            _selectedIds.add(area.id);
                          }
                          _showBeats = false;
                        });
                        Navigator.pop(sheetContext);
                      },
                      icon: Icon(_selectedIds.contains(area.id)
                          ? Icons.remove_circle_outline
                          : Icons.add_location_alt_outlined),
                      label: Text(_selectedIds.contains(area.id)
                          ? 'Remove from draft'
                          : 'Add to beat draft')),
                  const Divider(height: 24),
                  ExpansionTile(
                      title: Text('Doctors (${doctors.length})'),
                      initiallyExpanded: true,
                      children: [
                        for (final doctor in doctors)
                          ListTile(
                              title: Text(doctor.doctorName),
                              subtitle: Text(
                                  '${doctor.clinicName} · ${doctor.speciality}')),
                      ]),
                  ExpansionTile(
                      title: Text('Chemists (${chemists.length})'),
                      children: [
                        for (final chemist in chemists)
                          ListTile(
                              title: Text(chemist.chemistName),
                              subtitle: Text(chemist.shopName)),
                      ]),
                  ExpansionTile(
                      title: Text('Stockists (${stockists.length})'),
                      children: [
                        for (final stockist in stockists)
                          ListTile(
                              title: Text(stockist.stockistName),
                              subtitle: Text(stockist.firmName)),
                      ]),
                ]))));
  }

  Widget _layerControls() => Wrap(spacing: 8, runSpacing: 8, children: [
        if (_isPincodeMode) ...[
          const Chip(
              avatar: Icon(Icons.circle, color: TColors.success, size: 14),
              label: Text('Registered area ID')),
          const Chip(
              avatar: Icon(Icons.circle, color: TColors.error, size: 14),
              label: Text('No registered area ID')),
          if (_showBeatColors)
            const Text(
                'Assigned areas use beat colors · shared areas show each beat color across the fill'),
          if (_areaRegistry == null)
            Text(_masterError == null
                ? 'Loading area IDs…'
                : 'Area IDs unavailable. Retry loading beat data.'),
          if (_areaRegistry != null && _district != null && !_clipping)
            Text(
                '${_visiblePincodes.where((p) => _areaRegistry!.idsFor(p.name).isNotEmpty).length} of ${_visiblePincodes.length} map pincodes match API area IDs'),
          if (_areaRegistry != null && _masterError != null)
            Text(_masterError!, style: const TextStyle(color: TColors.error)),
        ],
        ActionChip(
            label: const Text('India pincodes'),
            avatar: const Icon(Icons.public),
            onPressed: _showIndia),
        ActionChip(
            label: const Text('Bihar districts'),
            avatar: const Icon(Icons.map_outlined),
            onPressed: _backToBihar),
        FilterChip(
            label: const Text('Boundaries'),
            selected: _showBoundaries,
            onSelected: (value) => setState(() => _showBoundaries = value)),
        FilterChip(
            label: const Text('Doctors'),
            selected: _showDoctors,
            onSelected: (value) => setState(() => _showDoctors = value)),
        FilterChip(
            label: const Text('Beat colors'),
            selected: _showBeatColors,
            onSelected: (value) => setState(() => _showBeatColors = value)),
      ]);

  Widget _panel() {
    final districts = (_districts?.areas ?? [])
        .where((d) => d.name.toLowerCase().contains(_query))
        .toList();
    final matchingPincodes = _availablePincodes
        .where((p) => '${p.name} ${p.office} ${p.division} ${p.circle}'
            .toLowerCase()
            .contains(_query))
        .toList();
    final pincodes = matchingPincodes.take(100).toList();
    return Material(
        color: TColors.white,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Expanded(
                    child: Text(
                        _district == null
                            ? (_indiaMode
                                ? 'India${_pincode == null ? '' : ' → ${_pincode!.name}'}'
                                : 'Bihar')
                            : 'Bihar → ${_district!.name}${_pincode == null ? '' : ' → ${_pincode!.name}'}',
                        style: const TextStyle(
                            color: _ink, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _panelOpen = false);
                    },
                    tooltip: 'Minimize beat panel',
                    icon: const Icon(Icons.close_fullscreen)),
                if (_district != null)
                  IconButton(
                      onPressed: _backToBihar,
                      tooltip: 'Choose another district',
                      icon: const Icon(Icons.arrow_back)),
              ])),
          Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                      value: false,
                      label: Text('Plan beat'),
                      icon: Icon(Icons.edit_location_alt_outlined)),
                  ButtonSegment(
                      value: true,
                      label: Text('Saved beats'),
                      icon: Icon(Icons.route_outlined))
                ],
                selected: {_showBeats},
                onSelectionChanged: (value) =>
                    setState(() => _showBeats = value.first),
              )),
          Expanded(
              child: ListView(
                  controller: _panelScroll,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                if (_masterError != null)
                  Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          color: TColors.primary_shade50,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_masterError!),
                            TextButton(
                                onPressed: _loadingMaster ? null : _loadMaster,
                                child: const Text('Retry beat data'))
                          ])),
                if (_loadingMaster)
                  const Text('Refreshing registered areas and beats…'),
                if (_master != null)
                  Wrap(spacing: 8, children: [
                    Chip(label: Text('${_master!.areas.length} areas')),
                    Chip(label: Text('${_master!.doctors.length} doctors')),
                    Chip(label: Text('${_master!.beats.length} beats')),
                  ]),
                _layerControls(),
                const SizedBox(height: 12),
                if (_showBeats)
                  ..._beatList()
                else ...[
                  _heading(
                      _editing == null
                          ? 'Select multiple areas'
                          : 'Select areas for ${_editing!.beatName}',
                      '1. Select multiple areas. 2. Tap Create beat. 3. Enter name and choose color.'),
                  if (_pincode != null) ..._pincodeDetails(_pincode!),
                  Wrap(spacing: 8, children: [
                    Chip(label: Text('${_selectedPincodes.length} pincodes')),
                    Chip(label: Text('${_selectedIds.length} areas')),
                    Chip(label: Text('$_selectedDoctorCount doctors'))
                  ]),
                  if (_selectedAreas.isNotEmpty) ...[
                    const Text('Selected areas',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Wrap(spacing: 6, children: [
                      for (final area in _selectedAreas)
                        InputChip(
                            label: Text('${area.postOffice} · ${area.pincode}'),
                            onDeleted: () => setState(() {
                                  _selectedIds.remove(area.id);
                                  _selectedPostOffices
                                      .remove(area.pincode.trim());
                                }))
                    ]),
                    const Divider(height: 24),
                  ],
                  TextField(
                      controller: _search,
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      decoration: InputDecoration(
                          hintText: !_isPincodeMode
                              ? 'Search district'
                              : 'Search pincode, office or postal circle',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => setState(() {
                                        _query = '';
                                        _search.clear();
                                      }),
                                  icon: const Icon(Icons.close)),
                          border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  if (!_isPincodeMode) ...[
                    if (districts.isEmpty) const Text('No matching districts.'),
                    for (final district in districts)
                      ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.map_outlined, color: _ink),
                          title: Text(district.name),
                          subtitle: Text(
                              '${_districtCounts[district.name] ?? 0} mapped doctors'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDistrict(district)),
                  ] else ...[
                    if (matchingPincodes.length > pincodes.length)
                      Text(
                          'Showing first ${pincodes.length} of ${matchingPincodes.length} pincodes. Search to narrow the list.'),
                    if (!_clipping && pincodes.isNotEmpty)
                      Wrap(spacing: 8, children: [
                        TextButton.icon(
                            onPressed: () =>
                                _selectVisiblePincodes(pincodes, add: true),
                            icon: const Icon(Icons.playlist_add_check),
                            label: const Text('Select shown pincodes')),
                        TextButton(
                            onPressed: () =>
                                _selectVisiblePincodes(pincodes, add: false),
                            child: const Text('Remove shown pincodes')),
                      ]),
                    if (!_clipping && pincodes.isEmpty)
                      Text(_district != null && _query.trim().isEmpty
                          ? 'No matching postal division is available for ${_district!.name} in the boundary data.'
                          : 'No pincode boundaries found for this selection.'),
                    for (final pincode in pincodes)
                      ListTile(
                          contentPadding: EdgeInsets.zero,
                          selected: _selectedPincodes.contains(pincode.name),
                          selectedTileColor: TColors.successBg,
                          leading: Icon(
                              _selectedPincodes.contains(pincode.name)
                                  ? Icons.check_circle
                                  : Icons.markunread_mailbox_outlined,
                              color: _areaRegistry?.colorFor(pincode.name) ??
                                  _ink),
                          title: _postOfficeLabel(pincode),
                          subtitle: Text(
                              '${_areasOf(pincode.name).length} registered areas · ${_mappedDoctorCount(pincode)} mapped doctors'),
                          trailing: Checkbox(
                            tristate: true,
                            value: _pincodeSelection(pincode.name),
                            onChanged: (_) => _togglePincode(pincode),
                          ),
                          onTap: () {
                            _togglePincode(pincode);
                            _focusPincode(pincode);
                          }),
                  ],
                ],
              ])),
          if (!_showBeats)
            SafeArea(
                top: false,
                child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: TColors.borderPrimary))),
                    child: Row(children: [
                      OutlinedButton(
                          onPressed: () async {
                            if (await _confirmDiscard() && mounted) {
                              _clearDraft();
                            }
                          },
                          child: const Text('Clear')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: FilledButton.icon(
                        onPressed: _master == null ||
                                _masterError != null ||
                                _loadingMaster ||
                                _selectedIds.isEmpty
                            ? null
                            : _openBeatForm,
                        icon: const Icon(Icons.check),
                        label: Text(_editing == null
                            ? 'Create beat'
                            : 'Continue editing'),
                      ))
                    ]))),
        ]));
  }

  List<Widget> _pincodeDetails(MapBeatRegion pincode) {
    final areas = _areasOf(pincode.name);
    final registeredIds = _areaRegistry?.idsFor(pincode.name);
    final doctors = _doctors
        .where((d) => d.point != null && pincode.contains(d.point!))
        .toList();
    return [
      Card(
          color: TColors.primaryBackground,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text('Pincode ${pincode.name}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))),
                      IconButton(
                          onPressed: () => setState(() => _pincode = null),
                          tooltip: 'Close pincode details',
                          icon: const Icon(Icons.close))
                    ]),
                    Text(pincode.office),
                    const SizedBox(height: 8),
                    Text(
                      registeredIds == null
                          ? 'Area registration has not loaded.'
                          : registeredIds.isEmpty
                              ? 'No matching area ID in the loaded API areas list.'
                              : 'Matched ${registeredIds.length} area ID(s) in the API areas list.',
                      style: TextStyle(
                        color: _areaRegistry?.colorFor(pincode.name) ?? _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (registeredIds != null && registeredIds.isNotEmpty)
                      SelectableText('Area IDs: ${registeredIds.join(', ')}'),
                    if (pincode.circle.isNotEmpty)
                      Text('Postal circle: ${pincode.circle}'),
                    const SizedBox(height: 8),
                    const Text(
                        'Choose registered areas to include in this beat.'),
                    if (areas.isEmpty)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(_master == null
                              ? 'Load beat data to see registered areas.'
                              : 'No registered areas for this pincode. It cannot be added to a beat yet.')),
                    if (areas.isNotEmpty)
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Select all areas in this pincode'),
                          tristate: true,
                          value: _pincodeSelection(pincode.name),
                          onChanged: (_) => _togglePincode(pincode)),
                    for (final area in areas)
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _selectedIds.contains(area.id),
                          title: Text(area.postOffice),
                          subtitle: Text(
                              '${_areaDoctorCount(area.id)} assigned doctors'),
                          onChanged: (value) => setState(() {
                                if (value == true) {
                                  _selectedIds.add(area.id);
                                } else {
                                  _selectedIds.remove(area.id);
                                }
                              })),
                    for (final area in areas)
                      ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${area.postOffice} details'),
                          subtitle: Text(_beatsForArea(area.id).isEmpty
                              ? 'No beat assigned'
                              : _beatsForArea(area.id)
                                  .map((beat) => beat.beatName)
                                  .join(' · ')),
                          trailing: const Icon(Icons.info_outline),
                          onTap: () => _areaDetails(area)),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                            '${doctors.length} doctors inside this pincode'),
                        children: [
                          if (doctors.isEmpty)
                            const ListTile(
                                title:
                                    Text('No saved doctors in this boundary.')),
                          for (final doctor in doctors)
                            ListTile(
                                title: Text(doctor.name),
                                subtitle: Text(doctor.clinic),
                                onTap: () => _doctorDetails(doctor))
                        ]),
                  ]))),
    ];
  }

  List<AreaModel> _beatAreas(BeatModel beat) {
    final ids = _master!.beatAreas
        .where((link) => link.beatId == beat.id)
        .map((link) => link.areaId)
        .toSet();
    return _master!.areas.where((area) => ids.contains(area.id)).toList();
  }

  Future<void> _viewBeat(BeatModel beat) async {
    setState(() {
      _previewBeat = beat;
      _previewRegions = [];
      _previewDistricts = [];
    });
    final areas = _beatAreas(beat);
    final codes = areas.map((a) => a.pincode.trim()).toSet();
    final mappedRegions = _pincodes!.areas
        .where((region) => codes.contains(region.name))
        .toList();
    final points = mappedRegions.isNotEmpty
        ? mappedRegions
            .expand((region) => region.parts.expand((rings) => rings.first))
            .toList()
        : areas
            .map((a) => _validPoint(a.latitude, a.longitude))
            .whereType<LatLng>()
            .toList();
    if (points.isEmpty) {
      _message('This beat has no mapped registered areas.');
      return;
    }
    final districts =
        _districts!.areas.where((d) => points.any(d.contains)).toList();
    if (districts.isEmpty ||
        points.any((point) =>
            !districts.any((district) => district.contains(point)))) {
      ++_districtRequest;
      final regions = _pincodes!.areas
          .where((region) => codes.contains(region.name))
          .toList();
      setState(() {
        _indiaMode = true;
        _district = null;
        _pincode = null;
        _clipping = false;
        _previewRegions = regions;
        _previewDistricts = [];
        _showBeats = true;
        _rebuildVisibleDoctors();
      });
      final polygonPoints = regions
          .expand((region) => region.parts.expand((rings) => rings.first))
          .toList();
      _fit(LatLngBounds.fromPoints(
          polygonPoints.isEmpty ? points : polygonPoints));
      return;
    }
    await _openDistrict(districts.first, showSaved: true);
    if (!mounted || _previewBeat?.id != beat.id) return;
    final request = _districtRequest;
    setState(() => _clipping = true);
    try {
      final regions = <MapBeatRegion>[];
      for (final district in districts) {
        final List<MapBeatRegion> clipped = _districtCache[district.name] ??
            await compute(clipMapBeatPincodes, (
              areas: _pincodes!.areas
                  .where(
                      (region) => region.bounds.isOverlapping(district.bounds))
                  .toList(),
              districtParts: district.parts
            ));
        if (!mounted ||
            request != _districtRequest ||
            _previewBeat?.id != beat.id) {
          return;
        }
        _districtCache[district.name] = clipped;
        regions.addAll(clipped.where((region) => codes.contains(region.name)));
      }
      setState(() {
        _previewRegions = regions;
        _previewDistricts = districts;
      });
      final polygonPoints = regions
          .expand((region) => region.parts.expand((rings) => rings.first))
          .toList();
      _fit(LatLngBounds.fromPoints(
          polygonPoints.isEmpty ? points : polygonPoints));
    } catch (_) {
      _message('Unable to prepare the beat boundaries. Please retry.');
    } finally {
      if (mounted && request == _districtRequest) {
        setState(() => _clipping = false);
      }
    }
  }

  List<Widget> _beatList() {
    final beats = _master?.beats ?? [];
    return [
      _heading('Saved beats', '${beats.length} beats · Review, edit or delete'),
      if (_master == null && !_loadingMaster)
        const Text('Load beat data to view saved beats.'),
      if (_master != null && beats.isEmpty)
        const Text('No beats yet. Select Plan beat to create your first one.'),
      for (final beat in beats)
        Card(
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: _parseColor(beat.color),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(beat.beatName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17)))
                      ]),
                      const SizedBox(height: 8),
                      Text(DateFormat('dd MMM yyyy').format(beat.createdAt),
                          style: const TextStyle(color: TColors.textSecondary)),
                      Text(
                          '${_master!.beatAreas.where((link) => link.beatId == beat.id).length} areas · ${_beatDoctorCount(beat)} doctors'),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Areas in this beat'),
                        children: [
                          for (final area in _beatAreas(beat))
                            ListTile(
                                dense: true,
                                title: Text(area.postOffice),
                                subtitle: Text(area.pincode),
                                onTap: () => _areaDetails(area)),
                        ],
                      ),
                      Wrap(spacing: 8, children: [
                        TextButton.icon(
                            onPressed: _clipping ? null : () => _viewBeat(beat),
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Show on map')),
                        TextButton.icon(
                            onPressed: _masterError == null && !_loadingMaster
                                ? () => _edit(beat)
                                : null,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit')),
                        TextButton.icon(
                            onPressed: _masterError == null && !_loadingMaster
                                ? () => _delete(beat)
                                : null,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'))
                      ]),
                    ]))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _selectedIds.isEmpty &&
            _name.text.trim().isEmpty &&
            !_saving &&
            _editing == null,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop || _saving) return;
          if (await _confirmDiscard() && mounted) {
            _clearDraft();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
          }
        },
        child: Scaffold(
          backgroundColor: TColors.primaryBackground,
          appBar: AppBar(
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                          value: false,
                          icon: Icon(Icons.map_outlined),
                          label: Text('Graphical')),
                      ButtonSegment(
                          value: true,
                          icon: Icon(Icons.table_rows_outlined),
                          label: Text('Table')),
                    ],
                    selected: {_tableMode},
                    onSelectionChanged: _saving
                        ? null
                        : (value) => setState(() {
                              _tableMode = value.first;
                              _mapReady = false;
                              _viewportTimer?.cancel();
                            }),
                  ),
                ),
              ),
              title: const Text('MAP BEAT MANAGEMENT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                    onPressed: _loadingMaster || _saving ? null : _loadMaster,
                    tooltip: 'Refresh beat data',
                    icon: const Icon(Icons.refresh))
              ]),
          body: _tableMode
              ? _master == null
                  ? _masterError != null
                      ? Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(_masterError!),
                          TextButton(
                              onPressed: _loadMaster,
                              child: const Text('Retry'))
                        ]))
                      : const FieldOmniLoader(
                          message: 'Loading registered areas...')
                  : Column(children: [
                      if (_masterError != null)
                        Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(_masterError!,
                                style: const TextStyle(color: TColors.error))),
                      Expanded(
                          child: BeatAreaTable(
                        areas: _master!.areas,
                        selectedIds: _selectedIds,
                        busy: _saving || _loadingMaster || _masterError != null,
                        editing: _editing != null,
                        onDetails: _areaDetails,
                        onCreate: _openBeatForm,
                        onClear: _clearDraft,
                        onSelection: (ids, selected) => setState(() {
                          if (selected) {
                            _selectedIds.addAll(ids);
                          } else {
                            _selectedIds.removeAll(ids);
                          }
                          // Table choices are individual registered areas;
                          // do not retain whole-pincode visual selections.
                          _selectedPostOffices.clear();
                          _showBeats = false;
                        }),
                      )),
                    ])
              : _geometryError != null
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_geometryError!),
                      TextButton(
                          onPressed: _loadGeometry, child: const Text('Retry'))
                    ]))
                  : _districts == null
                      ? const FieldOmniLoader(message: 'Loading beat map...')
                      : Stack(children: [
                          AbsorbPointer(
                              absorbing: _saving,
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                _mapViewport = constraints.biggest;
                                final landscape = constraints.maxWidth >= 840 &&
                                    constraints.maxWidth >
                                        constraints.maxHeight;
                                return Stack(children: [
                                  Positioned.fill(child: _mapView()),
                                  if (!_panelOpen)
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      bottom: 12,
                                      child: SafeArea(
                                          top: false, child: _selectionTray()),
                                    ),
                                  if (_panelOpen)
                                    Positioned(
                                      top: landscape ? 12 : null,
                                      left: landscape ? null : 12,
                                      right: 12,
                                      bottom: 12,
                                      width: landscape ? 410 : null,
                                      height: landscape
                                          ? null
                                          : constraints.maxHeight * 0.38,
                                      child: Material(
                                          elevation: 12,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          clipBehavior: Clip.antiAlias,
                                          child: _panel()),
                                    ),
                                ]);
                              })),
                          if (_saving)
                            const Positioned.fill(
                                child: ColoredBox(
                                    color: Color(0xDDFFFFFF),
                                    child: FieldOmniLoader(
                                        message: 'Saving beat changes...'))),
                        ]),
        ));
  }
}

class _MapDoctor {
  const _MapDoctor(
      {required this.id,
      required this.name,
      required this.clinic,
      required this.speciality,
      required this.areaId,
      this.point,
      this.phone});
  final String id;
  final String name;
  final String clinic;
  final String speciality;
  final String areaId;
  final LatLng? point;
  final String? phone;
}
