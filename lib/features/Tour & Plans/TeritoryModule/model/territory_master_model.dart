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

    print("TerritoryMasterModel ===============================");
    print("TerritoryMasterModel Root Keys: ${json.keys.toList()}");

    print("TerritoryMasterModel Raw Areas: ${(json["areas"] as List?)?.length}");
    print("TerritoryMasterModel Raw Doctors: ${(json["doctors"] as List?)?.length}");
    print("TerritoryMasterModel Raw Beats: ${(json["beats"] as List?)?.length}");
    print("TerritoryMasterModel Raw BeatAreas: ${(json["beatAreas"] as List?)?.length}");

    return TerritoryMasterModel(
      areas: (json["areas"] as List? ?? [])
          .map((e) => AreaModel.fromJson(e))
          .toList(),

      doctors: (json["doctors"] as List? ?? [])
          .map((e) => DoctorLocationModel.fromJson(e))
          .toList(),

      beats: (json["beats"] as List? ?? [])
          .map((e) => BeatModel.fromJson(e))
          .toList(),

      beatAreas: (json["beatAreas"] as List? ?? [])
          .map((e) => BeatAreaModel.fromJson(e))
          .toList(),
    );
  }
}