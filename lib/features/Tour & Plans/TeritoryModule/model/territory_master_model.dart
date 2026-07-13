import 'area_model.dart';
import 'beat_area_model.dart';
import 'beat_model.dart';
import 'doctor_location_model.dart';

class TerritoryMasterModel {
  final List<AreaModel> areas;

  final List<DoctorLocationModel> doctors;

  final List<BeatModel> beats;

  final List<BeatAreaModel> beatAreas;

  TerritoryMasterModel({
    required this.areas,
    required this.doctors,
    required this.beats,
    required this.beatAreas,
  });

  factory TerritoryMasterModel.fromJson(
      Map<String, dynamic> json,
      ) {

    final data = json["data"];

    return TerritoryMasterModel(

      areas: [],

      doctors: [],

      beats: [],

      beatAreas: [],

    );
  }
}