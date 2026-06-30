import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';


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

    loadData();
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
      changeHeadquarter(
        headquarters.first,
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

  void selectArea(
      AreaModel area) {

    selectedArea.value = area;

    if (mapMode.value != TerritoryMapMode.createBeat) {
      return;
    }

    if (selectedAreas.contains(area)) {
      selectedAreas.remove(area);
    } else {
      selectedAreas.add(area);
    }

    moveCamera(

      LatLng(

        area.latitude,

        area.longitude,

      ),

      15,

    );

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

  /////////////////////////////////////////////////////////////////////////////
  /// BEAT
  /////////////////////////////////////////////////////////////////////////////

  void selectBeat(BeatModel beat) {

    selectedBeat.value = beat;

    final areas = beatAreasOf(beat);

    selectedAreas.assignAll(areas);

    if (areas.isNotEmpty) {

      moveCamera(

        LatLng(
          areas.first.latitude,
          areas.first.longitude,
        ),

        13.5,

      );

    }

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

  }

  /////////////////////////////////////////////////////////////////////////////
  /// MODE
  /////////////////////////////////////////////////////////////////////////////

  void startBeatCreation() {

    selectedAreas.clear();

    resetBeatForm();

    mapMode.value =
        TerritoryMapMode.createBeat;

  }

  void cancelBeatCreation() {

    selectedAreas.clear();

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

  List<AreaModel> get visibleAreas {

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

  }

  List<DoctorLocationModel> get visibleDoctors {

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

  }

  List<BeatModel> get visibleBeats {

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

  }

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

      headquarterId:
      selectedHeadquarter.value!.id,

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

    Get.snackbar(

      "Success",

      "${beat.beatName} created successfully.",

      snackPosition: SnackPosition.BOTTOM,

    );

    cancelBeatCreation();

    update();

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

    cancelBeatCreation();

  }

  bool isAreaSelected(String areaId) {
    return selectedAreas.any(
          (area) => area.id == areaId,
    );
  }




}