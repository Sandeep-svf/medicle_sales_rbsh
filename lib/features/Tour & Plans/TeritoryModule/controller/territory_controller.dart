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
import '../model/doctor_location_model.dart';
import '../model/headquarter_model.dart';
import '../repository/territory_repository.dart';
import '../utils/enumsclass.dart';
import '../wigets/area_details_bottom_sheet.dart';
import '../wigets/create_beat_bottom_sheet.dart';

class TerritoryController extends GetxController {


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
      BeatColor.blue.obs;

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
      const LatLng(28.5706, 77.3272).obs;

  @override
  void onInit() {
    super.onInit();

    loadAssignedHeadOffices();

    loadData();
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

  void loadData() {

    headquarters.assignAll(
      repository.getHeadquarters(),
    );

    areas.assignAll(
      repository.getAreas(),
    );

    doctors.assignAll(
      repository.getDoctors(),
    );

    beats.assignAll(
      repository.getBeats(),
    );

    beatAreas.assignAll(
      repository.getBeatAreas(),
    );

    if (headquarters.isNotEmpty) {
      selectedHeadquarter.value = null;

      moveCamera(
        const LatLng(28.60, 77.25), // between Noida & Delhi
        10.5,
      );
    }

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

  Color beatColor(
      BeatModel beat) {

    switch (beat.color) {

      case BeatColor.blue:
        return Colors.blue;

      case BeatColor.green:
        return Colors.green;

      case BeatColor.orange:
        return Colors.orange;

      case BeatColor.purple:
        return Colors.purple;

      case BeatColor.red:
        return Colors.red;

      case BeatColor.cyan:
        return Colors.cyan;

    }

  }

  List<AreaModel> get beatCreationAreas {

    return selectedAreas;

  }

  void moveCamera(
      LatLng center,
      double zoom,
      ) {

    currentCenter.value = center;

    currentZoom.value = zoom;

    if (_mapReady) {

      mapController.move(
        center,
        zoom,
      );

    }

  }


  ///////////////////////////////////////////////////////////////////////////
  /// MAP ZOOM
///////////////////////////////////////////////////////////////////////////

  bool get showDoctorMarkers {

    return currentZoom.value >= 14;

  }

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

  Future<void> createBeat() async {

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
        BeatColor.blue;

  }

  Future<void> updateBeat() async {

    if (editingBeat.value == null) return;

    final beat = editingBeat.value!;

    final index = beats.indexWhere(
          (e) => e.id == beat.id,
    );

    if (index == -1) return;

    beats[index] = beat.copyWith(

      beatName: beatNameController.text.trim(),

      color: selectedBeatColor.value,

      areaCount: selectedAreaCount,

      doctorCount: selectedDoctorCount,

    );

    beatAreas.removeWhere(
          (e) => e.beatId == beat.id,
    );

    for (final area in selectedAreas) {

      beatAreas.add(

        BeatAreaModel(

          beatId: beat.id,

          areaId: area.id,

        ),

      );

    }

    editingBeat.value = null;

    update();

    Get.snackbar(
      "Success",
      "Beat Updated Successfully",
    );

    Future.delayed(
      const Duration(milliseconds: 300),
          () {
        cancelBeatCreation();
      },
    );

  }

  bool isAreaSelected(String areaId) {
    return selectedAreas.any(
          (area) => area.id == areaId,
    );
  }




}