import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';


import '../../../../utils/local_storage/auth_manager.dart';
import '../../../addClinic/model/clinic.dart';
import '../model/area_model.dart';
import '../model/beat_area_model.dart';
import '../model/beat_model.dart';
import '../model/chemist_location_model.dart';
import '../model/doctor_location_model.dart';
import '../model/headquarter_model.dart';
import '../model/stockist_location_model.dart';
import '../repository/territory_repository.dart';
import '../screen/area_detail_map_screen.dart';
import '../service/area_polygon_builder.dart';
import '../utils/enumsclass.dart';
import '../wigets/area_details_bottom_sheet.dart';
import '../wigets/create_beat_bottom_sheet.dart';

class TerritoryController extends GetxController {

  final RxBool showBottomTools = false.obs;
  final RxBool showTools = false.obs;
  final authManager = AuthManager();

  final assignedHeadOffices = <HeadOffice>[].obs;

  /// offline map support
  final isOfflineMode = false.obs;

  final offlineMapDownloaded = false.obs;

  final downloadProgress = 0.0.obs;

  final downloading = false.obs;

  ///////////////////////////////////////////////////////////////////////////
  /// FORM
///////////////////////////////////////////////////////////////////////////

  final beatNameController = TextEditingController();
  ////////////////////////////////////////////////////////
  /// SELECTED BEAT
////////////////////////////////////////////////////////

 // final selectedBeat = Rxn<BeatModel>();

  final remarkController = TextEditingController();

  final selectedBeatColor =
      "#FF0000".obs;

  final repository = TerritoryRepository.instance;

  /////////////////////////////////////////////////////////////////////////////
  /// MAP
  /////////////////////////////////////////////////////////////////////////////

  final MapController mapController = MapController();

  /////////////////////////////////////////////////////////////////////////////
  /// DATA
  /////////////////////////////////////////////////////////////////////////////

  final headquarters = <HeadquarterModel>[].obs;

  final areas = <AreaModel>[].obs;

  final doctors = <DoctorLocationModel>[].obs;

  final chemists = <ChemistLocationModel>[].obs;

  final stockists = <StockistLocationModel>[].obs;

  final beats = <BeatModel>[].obs;

  final beatAreas = <BeatAreaModel>[].obs;

  bool _mapReady = false;

  /////////////////////////////////////////////////////////////////////////////
  /// SELECTION
  /////////////////////////////////////////////////////////////////////////////

  final selectedHeadquarter = Rxn<HeadquarterModel>();

  final selectedBeat = Rxn<BeatModel>();

  final editingBeat = Rxn<BeatModel>();

  final selectedArea = Rxn<AreaModel>();

  final selectedDoctor = Rxn<DoctorLocationModel>();

  final hoveredArea = Rxn<AreaModel>();

  final highlightedBeat = Rxn<BeatModel>();


  /////////////////////////////////////////////////////////////////////////////
  /// CREATE BEAT
  /////////////////////////////////////////////////////////////////////////////

  final selectedAreas = <AreaModel>[].obs;

  final mapMode = TerritoryMapMode.view.obs;

  /////////////////////////////////////////////////////////////////////////////
  /// MAP LAYERS
  /////////////////////////////////////////////////////////////////////////////

  final showAreas = true.obs;

  final showDoctors = true.obs;

  final showBeats = true.obs;

  /////////////////////////////////////////////////////////////////////////////
  /// MAP
  /////////////////////////////////////////////////////////////////////////////

  final currentZoom = 13.0.obs;

  final currentCenter =
      const LatLng(25.5941, 85.1376).obs; // Patna, Bihar

  @override
  void onInit() {
    super.onInit();
    _setHeadOfficeLocation();
    Future.microtask(loadData);
  }

  Future<void> _setHeadOfficeLocation() async {
    final userModel = await AuthManager().getUserData();

    debugPrint(
      "[TerritoryController] UserModel: ${userModel?.user?.headOffices}",
    );

    if (userModel == null ||
        userModel.user == null ||
        userModel.user!.headOffices.isEmpty) {
      debugPrint(
        "[TerritoryController] No head office found for logged in user.",
      );
      return;
    }

    final headOffice = userModel.user!.headOffices[0];

    debugPrint(
      "[TerritoryController] HeadOffice -> "
          "Name: ${headOffice.name}, "
          "Lat: ${headOffice.latitude}, "
          "Lng: ${headOffice.longitude}",
    );

    currentCenter.value = LatLng(
      headOffice.latitude.toDouble(),
      headOffice.longitude.toDouble(),
    );

    debugPrint(
      "[TerritoryController] currentCenter -> "
          "${currentCenter.value.latitude}, "
          "${currentCenter.value.longitude}",
    );
  }


  Future<void> loadAssignedHeadOffices() async {

    final user = await authManager.getUserData();

    assignedHeadOffices.assignAll(

      List<HeadOffice>.from(
        user?.user?.headOffices ?? const <HeadOffice>[],
      ),

    );

  }

  Future<void> toggleOfflineMode(bool value) async {

    isOfflineMode.value = value;

    if (!value) {
      return;
    }

    await checkOfflineAvailability();

  }

  Future<void> checkOfflineAvailability() async{

  }

  Future<void> downloadOfflineMap() async{

  }

  Future<void> deleteOfflineMap() async{

  }



  /// old one for beat edge
  /*LatLng beatCenter(List<AreaModel> areas) {
    if (areas.isEmpty) {
      return currentCenter.value;
    }

    double lat = 0;
    double lng = 0;

    for (final area in areas) {
      lat += area.latitude;
      lng += area.longitude;
    }

    return LatLng(
      lat / areas.length,
      lng / areas.length,
    );
  }*/

  bool isAreaInSelectedHeadquarter(AreaModel area) {
    if (selectedHeadquarter.value == null) return false;

    return area.headquarterId == selectedHeadquarter.value!.id;
  }

  void onMapReady() {

    _mapReady = true;

    if (selectedHeadquarter.value != null) {

      moveCamera(

        LatLng(
          selectedHeadquarter.value!.latitude,
          selectedHeadquarter.value!.longitude,
        ),

        selectedHeadquarter.value!.zoom,

      );

    }

  }


  void editBeat(BeatModel beat) {

    editingBeat.value = beat;

    /////////////////////////////////////////////////////
    /// Fill Form
    /////////////////////////////////////////////////////

    beatNameController.text = beat.beatName;

    selectedBeatColor.value = beat.color;

    remarkController.clear();

    /////////////////////////////////////////////////////
    /// Load Areas
    /////////////////////////////////////////////////////

    selectedAreas.assignAll(
      beatAreasOf(beat),
    );

    /////////////////////////////////////////////////////
    /// Switch Mode
    /////////////////////////////////////////////////////

    mapMode.value = TerritoryMapMode.editBeat;

    /////////////////////////////////////////////////////
    /// Open Bottom Sheet
    /////////////////////////////////////////////////////

    Get.bottomSheet(

      const CreateBeatBottomSheet(),

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

    );

  }

  /////////////////////////////////////////////////////////////////////////////
  /// LOAD
  /////////////////////////////////////////////////////////////////////////////

  Future<void> loadData() async {



    //////////////////////////////////////////////////////
    /// LOAD HEAD OFFICES FROM LOGIN
    //////////////////////////////////////////////////////

    final user = await AuthManager().getUserData();

    debugPrint("[TerritoryController] ===== USER FROM SHARED PREF =====");
    debugPrint("[TerritoryController] User Null: ${user == null}");
    debugPrint("[TerritoryController] Head Office Count: ${user?.user?.headOffices.length}");
    debugPrint("[TerritoryController] HQ Latitude: ${user?.user?.headOffices.first.latitude}");
    debugPrint("[TerritoryController] HQ Longitude: ${user?.user?.headOffices.first.longitude}");

    if (user == null) {
      debugPrint("[TerritoryController] User data not found.");
    } else if (user.user == null) {
      debugPrint("[TerritoryController] User object is null.");
    } else if (user.user!.headOffices.isEmpty) {
      debugPrint("[TerritoryController] No head offices found.");
    } else {
      final hq = user.user!.headOffices.first;

      headquarters.assignAll([
        HeadquarterModel(
          id: hq.id ?? "",
          code: "",
          name: hq.name ?? "",
          state: "",
          latitude: hq.latitude.toDouble(),
          longitude: hq.longitude.toDouble(),
          zoom: 11,
        ),
      ]);

      selectedHeadquarter.value = headquarters.first;

      // initial map load
      if (_mapReady) {
        goToHeadquarter();
      }

      debugPrint(
        "[TerritoryController] Selected HQ: ${hq.name} "
            "(${hq.latitude}, ${hq.longitude})",
      );
    }

    //////////////////////////////////////////////////////
    /// LOAD TERRITORY FROM API
    //////////////////////////////////////////////////////

    final territory = await repository.loadTerritory();

    areas.assignAll(
      territory.areas,
    );

    doctors.assignAll(
      territory.doctors,
    );

    chemists.assignAll(
      territory.chemists,
    );

    stockists.assignAll(
      territory.stockists,
    );

    beats.assignAll(
      territory.beats,
    );

    beatAreas.assignAll(
      territory.beatAreas,
    );

    //////////////////////////////////////////////////////
    /// INITIAL MAP POSITION first area
    //////////////////////////////////////////////////////

   /* if (areas.isNotEmpty) {

      moveCamera(

        LatLng(
          areas.first.latitude,
          areas.first.longitude,
        ),

        11,

      );

    }*/

    update();
  }

  /////////////////////////////////////////////////////////////////////////////
  /// HQ
  /////////////////////////////////////////////////////////////////////////////

  void changeHeadquarter(
      HeadquarterModel headquarter) {

    selectedHeadquarter.value = headquarter;

    currentCenter.value = LatLng(
      headquarter.latitude,
      headquarter.longitude,
    );

    currentZoom.value = headquarter.zoom;

    moveCamera(

      LatLng(

        headquarter.latitude,

        headquarter.longitude,

      ),

      headquarter.zoom,

    );

  }

  void openAreaDetails(AreaModel area) {

    selectedArea.value = area;

    Get.bottomSheet(

      AreaDetailsBottomSheet(
        area: area,
      ),

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

    );

  }

  List<BeatModel> beatsForArea(String areaId) {

    final beatIds = beatAreas

        .where((mapping) => mapping.areaId == areaId)

        .map((mapping) => mapping.beatId)

        .toSet();

    return beats

        .where((beat) => beatIds.contains(beat.id))

        .toList();

  }

  /////////////////////////////////////////////////////////////////////////////
  /// AREA
  /////////////////////////////////////////////////////////////////////////////

  void selectArea(AreaModel area) {

    selectedArea.value = area;

    if (selectedAreas.any((e) => e.id == area.id)) {
      selectedAreas.removeWhere((e) => e.id == area.id);
    } else {
      selectedAreas.add(area);
    }

    if (selectedAreas.isEmpty) return;

    double minLat = selectedAreas.first.latitude;
    double maxLat = selectedAreas.first.latitude;
    double minLng = selectedAreas.first.longitude;
    double maxLng = selectedAreas.first.longitude;

    for (final area in selectedAreas) {

      minLat = area.latitude < minLat ? area.latitude : minLat;
      maxLat = area.latitude > maxLat ? area.latitude : maxLat;

      minLng = area.longitude < minLng ? area.longitude : minLng;
      maxLng = area.longitude > maxLng ? area.longitude : maxLng;

    }

    moveCamera(
      LatLng(
        (minLat + maxLat) / 2,
        (minLng + maxLng) / 2,
      ),
      currentZoom.value < 12 ? 12 : currentZoom.value,
    );

    update();
  }

  /////////////////////////////////////////////////////////////////////////////
  /// DOCTOR
  /////////////////////////////////////////////////////////////////////////////

  void selectDoctor(
      DoctorLocationModel doctor) {

    selectedDoctor.value = doctor;

    moveCamera(

      LatLng(
        doctor.latitude,
        doctor.longitude,
      ),

      16.5,

    );

  }


  void zoomToAreas(List<AreaModel> areas) {
    if (areas.isEmpty) return;

    double minLat = areas.first.latitude;
    double maxLat = areas.first.latitude;
    double minLng = areas.first.longitude;
    double maxLng = areas.first.longitude;

    for (final area in areas) {
      if (area.latitude < minLat) minLat = area.latitude;
      if (area.latitude > maxLat) maxLat = area.latitude;

      if (area.longitude < minLng) minLng = area.longitude;
      if (area.longitude > maxLng) maxLng = area.longitude;
    }

    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    moveCamera(center, 11.8);
  }

  int beatCountOfArea(String areaId) {
    return beatAreas
        .where((e) => e.areaId == areaId)
        .length;
  }


  final Distance distance = const Distance();

  AreaModel? areaFromPoint(LatLng point) {

    for (final area in visibleAreas) {

      final meter = distance.as(
        LengthUnit.Meter,
        point,
        LatLng(
          area.latitude,
          area.longitude,
        ),
      );

      if (meter <= area.radius) {
        return area;
      }

    }

    return null;
  }



  /////////////////////////////////////////////////////////////////////////////
  /// BEAT
  /////////////////////////////////////////////////////////////////////////////

  void selectBeat(BeatModel beat) {

    selectedBeat.value = beat;

    final areas = beatAreasOf(beat);

    selectedAreas.assignAll(areas);

    if (areas.isNotEmpty) {
      zoomToAreas(areas);
    }

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

  }

  /////////////////////////////////////////////////////////////////////////////
  /// MODE
  /////////////////////////////////////////////////////////////////////////////

  void startBeatCreation() {

    editingBeat.value = null;

    selectedBeat.value = null;

    selectedArea.value = null;

    selectedDoctor.value = null;

    // DON'T clear selectedAreas here.
    // User has already selected Areas on the map.

    resetBeatForm();

    mapMode.value = TerritoryMapMode.createBeat;

    Get.bottomSheet(
      const CreateBeatBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void cancelBeatCreation() {

    if (editingBeat.value == null) {
      selectedAreas.clear();
    }

    beatNameController.clear();

    remarkController.clear();

    mapMode.value = TerritoryMapMode.view;

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

  }

  /////////////////////////////////////////////////////////////////////////////
  /// LAYERS
  /////////////////////////////////////////////////////////////////////////////

  void toggleLayer(
      TerritoryLayer layer) {

    switch (layer) {

      case TerritoryLayer.area:
        showAreas.toggle();
        break;

      case TerritoryLayer.doctor:
        showDoctors.toggle();
        break;

      case TerritoryLayer.beat:
        showBeats.toggle();
        break;

    }

  }


  /// old
  /*List<AreaModel> get visibleAreas {

    if (selectedHeadquarter.value == null) {
      return [];
    }

    return areas
        .where(
          (e) =>
      e.headquarterId ==
          selectedHeadquarter.value!.id,
    )
        .toList();

  }*/

  /// new
  List<AreaModel> get visibleAreas => areas;

  ///old
 /* List<DoctorLocationModel> get visibleDoctors {

    if (selectedHeadquarter.value == null) {
      return [];
    }

    return doctors
        .where(
          (e) =>
      e.headquarterId ==
          selectedHeadquarter.value!.id,
    )
        .toList();

  }*/

  ///new
  List<DoctorLocationModel> get visibleDoctors => doctors;

  ///old
  /*List<BeatModel> get visibleBeats {

    if (selectedHeadquarter.value == null) {
      return [];
    }

    return beats
        .where(
          (e) =>
      e.headquarterId ==
          selectedHeadquarter.value!.id,
    )
        .toList();

  }*/

  /// new
  List<BeatModel> get visibleBeats => beats;

  List<AreaModel> beatAreasOf(
      BeatModel beat) {

    final ids = beatAreas

        .where(
          (e) => e.beatId == beat.id,
    )

        .map(
          (e) => e.areaId,
    )

        .toSet();

    return areas

        .where(
          (e) => ids.contains(e.id),
    )

        .toList();

  }

  int doctorCountOfBeat(
      BeatModel beat) {

    final ids = beatAreas

        .where(
          (e) => e.beatId == beat.id,
    )

        .map(
          (e) => e.areaId,
    )

        .toSet();

    return doctors

        .where(
          (e) => ids.contains(e.areaId),
    )

        .length;

  }

  Color beatColor(BeatModel beat) {
    try {
      return Color(
        int.parse(
          beat.color.replaceFirst("#", "0xFF"),
        ),
      );
    } catch (_) {
      return Colors.grey;
    }
  }

  List<AreaModel> get beatCreationAreas {

    return selectedAreas;

  }

  void moveCamera(
      LatLng center,
      double zoom,
      ) {
    debugPrint("[TerritoryController] ===== moveCamera =====");
    debugPrint("[TerritoryController] Center: ${center.latitude}, ${center.longitude}");
    debugPrint("[TerritoryController] Zoom: $zoom");
    debugPrint("[TerritoryController] _mapReady: $_mapReady");

    currentCenter.value = center;
    currentZoom.value = zoom;

    if (_mapReady) {
      debugPrint("[TerritoryController] Calling mapController.move()");
      mapController.move(center, zoom);
    } else {
      debugPrint("[TerritoryController] Map is NOT ready");
    }
  }


  ///////////////////////////////////////////////////////////////////////////
  /// MAP ZOOM
///////////////////////////////////////////////////////////////////////////

  bool get showDoctorMarkers {

    return currentZoom.value >= 14;

  }

  //temp chnage

  bool get showAreaLabels {

    return currentZoom.value >= 11;

  }

  bool get showBeatPolygon {

    return currentZoom.value >= 10;

  }

  int get totalDoctors {

    return visibleDoctors.length;

  }

  int get totalAreas {

    return visibleAreas.length;

  }

  int get totalBeats {

    return visibleBeats.length;

  }

  // new one for beat circle
  LatLng beatCenter(List<AreaModel> areas) {

    final lat = areas
        .map((e) => e.latitude)
        .reduce((a, b) => a + b) /
        areas.length;

    final lng = areas
        .map((e) => e.longitude)
        .reduce((a, b) => a + b) /
        areas.length;

    return LatLng(lat, lng);
  }

  double beatRadius(List<AreaModel> areas) {

    final center = beatCenter(areas);

    final distance = const Distance();

    double radius = 0;

    for (final area in areas) {

      final d = distance.as(
        LengthUnit.Meter,
        center,
        LatLng(
          area.latitude,
          area.longitude,
        ),
      );

      if (d + area.radius > radius) {
        radius = d + area.radius;
      }
    }

    return radius;
  }

  ///////////////////////////////////////////////////////////////////////////////
  /// BEAT CREATION
///////////////////////////////////////////////////////////////////////////////

  int get selectedAreaCount => selectedAreas.length;

  int get selectedDoctorCount {

    if (selectedAreas.isEmpty) {
      return 0;
    }

    return doctors.where((doctor) {

      return selectedAreas.any(
            (area) => area.id == doctor.areaId,
      );

    }).length;

  }

  double get estimatedDistance {

    return selectedAreas.length * 2.8;

  }

  bool get canSaveBeat {

    return selectedAreas.isNotEmpty;

  }

  /*Future<void> createBeat() async {

    if (beatNameController.text.trim().isEmpty) {

      Get.snackbar(
        "Beat Name",
        "Please enter beat name.",
      );

      return;

    }

    //////////////////////////////////////////////////////
    /// CREATE BEAT
    //////////////////////////////////////////////////////

    final beatId =
        "BEAT${DateTime.now().millisecondsSinceEpoch}";

    final beat = BeatModel(

      id: beatId,

        headquarterId: "MULTI",

      beatName:
      beatNameController.text.trim(),

      color:
      selectedBeatColor.value,

      doctorCount:
      selectedDoctorCount,

      areaCount:
      selectedAreaCount,

      createdBy: "Demo User",

      createdAt: DateTime.now(),

    );

    beats.add(beat);
    selectedBeat.value = beat;

    //////////////////////////////////////////////////////
    /// CREATE BEAT AREA
    //////////////////////////////////////////////////////

    for (int i = 0; i < selectedAreas.length; i++) {

      beatAreas.add(

        BeatAreaModel(

          beatId: beatId,

          areaId: selectedAreas[i].id,

        ),

      );

    }

    beats.refresh();
    beatAreas.refresh();
    selectedAreas.refresh();

    zoomToAreas(selectedAreas);

    Get.snackbar(

      "Success",

      "${beat.beatName} created successfully.",

      snackPosition: SnackPosition.BOTTOM,

    );

    Future.delayed(
      const Duration(milliseconds: 300),
          () {
        cancelBeatCreation();
      },
    );

    update();

  }*/

  Future<void> deleteBeat(BeatModel beat) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Delete Beat"),
        content: Text(
          "Are you sure you want to delete '${beat.beatName}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await repository.deleteBeat(beat.id);

      await loadData();

      if (selectedBeat.value?.id == beat.id) {
        selectedBeat.value = null;
      }

      Get.snackbar(
        "Success",
        "Beat deleted successfully.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  /// updated one for apis
  Future<void> createBeat() async {
    if (beatNameController.text.trim().isEmpty) {
      Get.snackbar(
        "Beat Name",
        "Please enter beat name.",
      );
      return;
    }

    if (selectedAreas.isEmpty) {
      Get.snackbar(
        "Areas",
        "Please select at least one area.",
      );
      return;
    }

    try {
      await repository.createBeat(
        name: beatNameController.text.trim(),
        areaIds: selectedAreas.map((e) => e.id).toList(),
        color: selectedBeatColor.value,
      );

      await loadData();

      Get.snackbar(
        "Success",
        "Beat created successfully.",
        snackPosition: SnackPosition.BOTTOM,
      );

      cancelBeatCreation();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }




  List<LatLng> beatTerritoryPoints(BeatModel beat) {

    final areas = beatAreasOf(beat);

    if (areas.length < 3) {
      return [];
    }

    final points = areas
        .map(
          (e) => LatLng(
        e.latitude,
        e.longitude,
      ),
    )
        .toList();

    // Sort clockwise around center
    final center = beatCenter(areas);

    points.sort((a, b) {

      final angleA = atan2(
        a.latitude - center.latitude,
        a.longitude - center.longitude,
      );

      final angleB = atan2(
        b.latitude - center.latitude,
        b.longitude - center.longitude,
      );

      return angleA.compareTo(angleB);

    });

    return points;
  }

  void resetBeatForm() {

    beatNameController.clear();

    remarkController.clear();

    selectedBeatColor.value =
    "#FF0000";

  }

  bool areaBelongsToSelectedBeat(String areaId) {
    if (selectedBeat.value == null) {
      return false;
    }

    return beatAreas.any(
          (e) =>
      e.areaId == areaId &&
          e.beatId == selectedBeat.value!.id,
    );
  }

  Color? selectedBeatColorForArea(String areaId) {
    if (selectedBeat.value == null) {
      return null;
    }

    try {
      return Color(
        int.parse(
          selectedBeat.value!.color.replaceFirst("#", "0xFF"),
        ),
      );
    } catch (_) {
      return Colors.grey;
    }
  }

  String beatNamesForArea(String areaId) {
    final list = beatsForArea(areaId);

    if (list.isEmpty) {
      return "";
    }

    return list
        .map((e) => e.beatName)
        .join(" | ");
  }

  bool hasBeat(String areaId) {
    return beatsForArea(areaId).isNotEmpty;
  }

  List<Color> colorsForArea(String areaId) {
    final area = areas.firstWhereOrNull(
          (e) => e.id == areaId,
    );

    if (area == null) {
      return [];
    }

    return area.colors.map((hex) {
      try {
        return Color(
          int.parse(
            hex.replaceFirst("#", "0xFF"),
          ),
        );
      } catch (_) {
        return Colors.grey;
      }
    }).toList();
  }


  Future<void> updateBeat() async {
    if (editingBeat.value == null) {
      return;
    }

    if (beatNameController.text.trim().isEmpty) {
      Get.snackbar(
        "Beat Name",
        "Please enter beat name.",
      );
      return;
    }

    if (selectedAreas.isEmpty) {
      Get.snackbar(
        "Areas",
        "Please select at least one area.",
      );
      return;
    }

    try {
      await repository.updateBeat(
        beatId: editingBeat.value!.id,
        name: beatNameController.text.trim(),
        areaIds: selectedAreas.map((e) => e.id).toList(),
        color: selectedBeatColor.value,
      );

      await loadData();

      editingBeat.value = null;

      Get.snackbar(
        "Success",
        "Beat updated successfully.",
        snackPosition: SnackPosition.BOTTOM,
      );

      cancelBeatCreation();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  bool isAreaSelected(String areaId) {
    return selectedAreas.any(
          (area) => area.id == areaId,
    );
  }


  // draw circle
  List<Polygon> buildAreaPolygons() {
    final List<Polygon> polygons = [];

    for (final area in visibleAreas) {
      final colors = area.colors.map((hex) {
        try {
          return Color(
            int.parse(
              hex.replaceFirst("#", "0xFF"),
            ),
          );
        } catch (_) {
          return Colors.grey;
        }
      }).toList();

      polygons.addAll(
        AreaPolygonBuilder.build(
          center: LatLng(
            area.latitude,
            area.longitude,
          ),
          radius: area.radius, // getting from api dynamic value.
        //  radius: 700, // this is for test
          colors: colors,
        ),
      );
    }

    return polygons;
  }

  // draw territory

  /*List<Polygon> buildAreaPolygons() {
    final List<Polygon> polygons = [];

    for (final area in visibleAreas) {
      final doctorsOfArea = visibleDoctors
          .where((d) => d.areaId == area.id)
          .toList();

      if (doctorsOfArea.length < 3) {
        continue;
      }

      final points = doctorsOfArea
          .map((d) => LatLng(d.latitude, d.longitude))
          .toList();

      final hull = buildDoctorHull(points);

      polygons.add(
        Polygon(
          points: hull,
          color: Colors.blue.withOpacity(0.20),
          borderColor: Colors.blue,
          borderStrokeWidth: 3,
        ),
      );
    }

    return polygons;
  }*/


  List<LatLng> _createCircle(
      LatLng center,
      double radiusMeters,
      ) {
    const earthRadius = 6378137.0;

    final List<LatLng> points = [];

    for (int i = 0; i <= 72; i++) {
      final angle = 2 * pi * i / 72;

      final dx = radiusMeters * cos(angle);
      final dy = radiusMeters * sin(angle);

      final lat =
          center.latitude +
              (dy / earthRadius) * 180 / pi;

      final lng =
          center.longitude +
              (dx /
                  (earthRadius *
                      cos(center.latitude * pi / 180))) *
                  180 /
                  pi;

      points.add(
        LatLng(lat, lng),
      );
    }

    return points;
  }




  Color areaFillColor(AreaModel area) {
    final beatList = beatsForArea(area.id);

    if (beatList.isEmpty) {
      return isAreaInSelectedHeadquarter(area)
          ? Colors.blue.withOpacity(.22)
          : Colors.grey.withOpacity(.08);
    }

    return beatColor(beatList.first).withOpacity(.25);
  }

  Color areaBorderColor(AreaModel area) {
    final beatList = beatsForArea(area.id);

    if (beatList.isEmpty) {
      return isAreaInSelectedHeadquarter(area)
          ? Colors.blue
          : Colors.grey;
    }

    return beatColor(beatList.first);
  }



  List<LatLng> buildDoctorHull(List<LatLng> points) {
    if (points.length < 3) {
      return List.from(points);
    }

    final pts = List<LatLng>.from(points);

    pts.sort((a, b) {
      final cmpLng = a.longitude.compareTo(b.longitude);
      if (cmpLng != 0) return cmpLng;
      return a.latitude.compareTo(b.latitude);
    });

    double cross(LatLng o, LatLng a, LatLng b) {
      return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
          (a.latitude - o.latitude) * (b.longitude - o.longitude);
    }

    final List<LatLng> lower = [];

    for (final p in pts) {
      while (lower.length >= 2 &&
          cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    final List<LatLng> upper = [];

    for (final p in pts.reversed) {
      while (upper.length >= 2 &&
          cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    lower.removeLast();
    upper.removeLast();

    return [...lower, ...upper];
  }

  void showAreaActions(AreaModel area) {
    Get.dialog(
      AlertDialog(
        title: Text(area.postOffice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text("View Details"),
              onTap: () {
                Get.back();

                Get.to(
                      () => AreaDetailMapScreen(
                    area: area,
                        doctors: doctors,
                        chemists: chemists,
                        stockists: stockists,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_location_alt),
              title: const Text("Add To Beat"),
              onTap: () {
                Get.back();
                selectArea(area);
              },
            ),
          ],
        ),
      ),
    );
  }

  void goToHeadquarter() {
    final hq = selectedHeadquarter.value ??
        headquarters.firstOrNull;

    if (hq == null) return;

    selectedHeadquarter.value = hq;

    moveCamera(
      LatLng(hq.latitude, hq.longitude),
      hq.zoom,
    );
  }



}